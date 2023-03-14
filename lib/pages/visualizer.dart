// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';
import 'package:image/image.dart' as img;

import '../fileMe.dart';
import '../json.dart';
import '../popUpsV2.dart';
import '../widget/inputText.dart';

enum Part {
  first,
  second,
}

class Visualizer extends StatefulWidget {
  const Visualizer({super.key});

  @override
  State<Visualizer> createState() => _VisualizerState();
}

class Disconnect implements Exception {}

class _VisualizerState extends State<Visualizer> with AutomaticKeepAliveClientMixin<Visualizer> {
  static BluetoothConnection? connection;

  MainMatrix mainInfo = MainMatrix();
  late FilePickerResult? filePickerResult;
  Map<String, String> contentInputText = {
    "Файл": "",
    "Папка с изображениями": "",
  };
  int? oldPin = 0;
  String output = "";

  Completer completer = Completer();
  late StreamSubscription read;
  bool close = false;

  Future<void> check([int charlimit = 299]) async {
    if (output.length >= charlimit) {
      await Future(() => completer.future);
      close = false;
      output += String.fromCharCode(255);

      connection?.output.add(latin1.encode(output.substring(0, charlimit + 1)));

      completer = Completer();
      output = output.substring(charlimit + 1, output.length);
    }
  }

  Future<void> addToOutput(int value) async {
    output += String.fromCharCode(value);
    await check();
  }

  int oldPoint = 0;
  Future<void> compressFrame(
    int point,
    img.Pixel pixel,
  ) async {
    if (!(pixel.r <= 20 && pixel.g <= 20 && pixel.b <= 20) && pixel.a != 0) {
      int result = point - oldPoint;
      oldPoint = point;
      await splitInt(result);

      await splitInt(pixel.r.toInt());

      await splitInt(pixel.g.toInt());

      await splitInt(pixel.b.toInt());
    }
  }

// по 125 символов на два диапозона
// 0 - 125
// 126 - 251
// 253 - show
// 254 - clear
// 255 - end translate
  Future<void> splitInt(int value) async {
    int length = value.toString().length;
    int result = 0;

    while (length > 0) {
      if (result <= 125) {
        result = value;
        length = 0;
      } else {
        result = value ~/ pow(10, length - 2);

        if (result <= 125) {
          value = value % pow(10, length - 2).toInt();
          length -= 3;
        } else {
          result = result ~/ 10;
          value = value % pow(10, length - 3).toInt();
          length -= 2;
        }
      }

      if (length == 0) {
        result += 126;
      }

      await addToOutput(result);
    }
  }

  @override
  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputText(
            "Файл",
            contentInputText["Файл"]!,
            () async {
              int? id = await push(
                context,
                PopUp(
                  "Выбор файла настроек",
                  "Файл настроек",
                  getJson(),
                ),
              );
              List<String> files = getJson();

              if (id != null) {
                String tText = readJson(files[id]);
                if (tText != "") {
                  mainInfo = MainMatrix.fromJson(
                    jsonDecode(tText),
                  );
                } else {
                  push(
                    context,
                    const PopUpInfo(
                      "Оповещение",
                      "Не удалось считать файл настроек",
                    ),
                  );
                  return;
                }
                setState(
                  () {
                    contentInputText["Файл"] = files[id];
                  },
                );
              }
            },
          ),
          InputText(
            "Папка с изображениями 'png'",
            contentInputText["Папка с изображениями"]!,
            () async {
              String? dir = await FilePicker.platform.getDirectoryPath();
              if (dir != null) {
                setState(() {
                  contentInputText["Папка с изображениями"] = dir;
                });
              }
            },
          ),
          MyButton.fill(
            () async {
              for (var element in contentInputText.entries) {
                if (element.value == "") {
                  createSnackBar(context, "Поле '${element.key}' не заполнено");

                  return;
                }
              }

              if (await Permission.bluetooth.request().isGranted && await Permission.bluetoothConnect.request().isGranted && await Permission.bluetoothScan.request().isGranted) {
                if (await FlutterBluetoothSerial.instance.isEnabled == false) {
                  if (await FlutterBluetoothSerial.instance.requestEnable() == false) {
                    createSnackBar(context, "Необходимо включить Bluetooth");
                    return;
                  }
                }
                List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
                int? id = await push(
                  context,
                  PopUp(
                    "Bluetooth устройства",
                    "Выберите плату Arduino (HS-05)",
                    [
                      for (var item in bondedDevices)
                        if (item.name != null && item.name != "") item.name! else item.address
                    ],
                  ),
                );
                if (id != null) {
                  if (connection?.isConnected == true) {
                    String result = await push(
                      context,
                      const PopUpQuestion("Оповещение", "В данный момент передается изображение на матрицу. Прервать?"),
                    );
                    if (result == "Да") {
                      connection!.close();
                    }
                    return;
                  }
                  if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted == false) {
                    createSnackBar(context, "Не удалось получить разрешение.");
                    return;
                  }
                  try {
                    createSnackBar(context, "Идёт подключеник к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    connection = await BluetoothConnection.toAddress(bondedDevices[id].address);
                  } catch (e) {
                    createSnackBar(context, "Не удалось подключиться к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    return;
                  }

                  createSnackBar(context, "Подключение установлено с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  output = "";
                  completer = Completer();
                  completer.complete();

                  read = connection!.input!.listen((Uint8List data) {
                    completer.complete();
                  }, onDone: () {
                    createSnackBar(context, "Передача завершена с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  }, onError: (error) {
                    createSnackBar(context, "Произошла ошибка при считывании - подключение разорвано с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  });

                  try {
                    await addToOutput(254);
                    Directory savePath = Directory(contentInputText["Папка с изображениями"]!);
                    int cointItem = await savePath.list(recursive: false, followLinks: false).length;

                    for (var i = 1; i <= cointItem; i++) {
                      img.Image? frame = img.decodePng(await File("${savePath.path}/$i.png").readAsBytes());

                      if (frame != null) {
                        for (var pin in mainInfo.infoPin.keys) {
                          for (var coordinates in mainInfo.infoPin[pin]!.coordinates) {
                            int point = mainInfo.location[coordinates.column][coordinates.row].point;
                            int height = mainInfo.location[coordinates.column][coordinates.row].height;
                            int width = mainInfo.location[coordinates.column][coordinates.row].width;
                            int x = coordinates.x;
                            int y = coordinates.y;
                            for (int sY = y; sY < y + height; sY++) {
                              if (sY % 2 == 0) {
                                for (int sX = x + width - 1; sX >= x; sX--) {
                                  await compressFrame(point, frame.getPixel(sX, sY));
                                  point++;
                                }
                              } else {
                                for (int sX = x; sX < x + width; sX++) {
                                  await compressFrame(point, frame.getPixel(sX, sY));
                                  point++;
                                }
                              }
                            }
                          }
                          await addToOutput(254);
                        }
                      }
                    }
                    if (output.isNotEmpty) {
                      await check(output.length);
                    }
                  } catch (e) {
                    createSnackBar(context, "Произошла ошибка при передачи данных на ${bondedDevices[id].name ?? bondedDevices[id].address}\n$e");
                  }

                  connection?.close();
                }
              }
            },
            "Передать изображение на матрицу",
            color: purple[1],
          ),
          MyButton.fill(
            () {
              List<ReplaceColor> palette = [
                ReplaceColor(
                  const Color(0xff675db5),
                ),
              ];
              push(
                context,
                PopUpColor("Палитра цветов", palette),
              );
            },
            "Создать палитру цветов",
          )
        ],
      ),
    );
  }
}
