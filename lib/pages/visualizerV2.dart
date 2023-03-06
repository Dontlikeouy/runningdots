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
  int oldPoint = 0;
  bool isLastRGB = false, isNewMatrix = false;
  int point = 0;
  String output = "";

  Completer completer = Completer();
  late StreamSubscription read;
  bool close = false;

  Future<void> compressFrame(
    img.Pixel pixel,
  ) async {
    if (!(pixel.r <= 20 && pixel.g <= 20 && pixel.b <= 20) && pixel.a != 0) {
      await addToOutput((((pixel.r / 255) * 100).round()) + 128);
      if (isNewMatrix == true) {
        await addToOutput(254);
        isNewMatrix = false;
      }
      //print("$point - $oldPoint");
      int result = point - oldPoint;
      oldPoint = point;
      if (result != 1) {
        await splitInt(result);
      }
      await addToOutput((((pixel.g / 255) * 100).round()) + 128);

      await addToOutput((((pixel.b / 255) * 100).round()) + 128);
    }
  }

  Future<void> check([int charlimit = 399]) async {
    if (output.length >= charlimit) {
      await Future(() => completer.future);
      close = false;
      output += String.fromCharCode(32);

      connection?.output.add(latin1.encode(output.substring(0, charlimit + 1)));

      completer = Completer();
      //await Future.delayed(const Duration(microseconds: 900));
      output = output.substring(charlimit + 1, output.length);
    }
  }

  Future<void> addToOutput(int value) async {
    //output.addAll(Uint8List.fromList(latin1.encode(String.fromCharCode(value))));
    output += String.fromCharCode(value);
    await check();
  }

// 32 - не считатется
// по 126 символов на два диапозона
// 0 - 127
// 128 - 253

  Future<void> splitInt(int value, [Part part = Part.first, Part? changeTo]) async {
    int length = value.toString().length;
    int result = 0;
    while (length > 0) {
      if (length > 2) {
        result = value ~/ pow(10, length - 3).toInt();

        if (result <= 126) {
          value = value % pow(10, length - 3).toInt();
          length -= 3;
        } else {
          result = value ~/ pow(10, length - 2).toInt();
          value = value % pow(10, length - 2).toInt();
          length -= 2;
        }
      } else {
        result = value;
        length = 0;
      }

      if (part == Part.first) {
        if (result >= 32 && result <= 126) {
          result++;
        }
      } else {
        result += 128;
      }

      if (changeTo != null) {
        part = changeTo;
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

                if (id != null) {
                  try {
                    createSnackBar(context, "Идёт подключеник к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    connection = await BluetoothConnection.toAddress(bondedDevices[id].address);
                  } catch (e) {
                    createSnackBar(context, "Не удалось подключиться к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    return;
                  }

                  createSnackBar(context, "Подключение установлено с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  oldPin = null;
                  oldPoint = 0;
                  isLastRGB = false;
                  isNewMatrix = false;
                  point = 0;
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
                  if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted == false) {
                    createSnackBar(context, "Не удалось получить разрешение.");
                    return;
                  }

                  try {
                    await addToOutput(255);
                    Directory savePath = Directory(contentInputText["Папка с изображениями"]!);
                    int cointItem = await savePath.list(recursive: false, followLinks: false).length;
                    List<img.Image?> frame1 = [];
                    for (var i = 1; i <= cointItem; i++) {
                      frame1.add(img.decodePng(await File("${savePath.path}/$i.png").readAsBytes()));
                    }

                    for (var i = 1; i <= cointItem; i++) {
                      img.Image? frame = frame1[i];

                      if (frame != null) {
                        int x = 0;
                        int y = 0;
                        int height = 0;
                        int width = 0;

                        for (int column = 0; column < mainInfo.location.length; column++) {
                          for (int row = 0; row < mainInfo.location[column].length; row++) {
                            oldPoint = 0;
                            point = mainInfo.location[column][row].point.begin;
                            int pin = mainInfo.location[column][row].pin;
                            int size = mainInfo.pointOnPin[pin]!.end;
                            height = mainInfo.location[column][row].sizeMatrix.height;
                            width = mainInfo.location[column][row].sizeMatrix.width;
                            if (pin != oldPin || oldPin == null) {
                              if (oldPin != null) {
                                await addToOutput(254);
                              }
                              await splitInt(pin);
                              await splitInt(size, Part.second, Part.first);
                              oldPin = pin;
                            }

                            for (int nY = y; nY < y + height; nY++) {
                              if (nY % 2 == 0) {
                                for (int nX = x + width - 1; nX >= x; nX--) {
                                  await compressFrame(frame.getPixel(nX, nY));

                                  point++;
                                }
                              } else {
                                for (int nX = x; nX < x + width; nX++) {
                                  await compressFrame(frame.getPixel(nX, nY));

                                  point++;
                                }
                              }
                            }

                            isNewMatrix = true;
                            x += width;
                          }
                          x = 0;
                          y += height;
                        }

                        await addToOutput(254);
                        // for (var pin in allPin) {
                        //   int size = mainInfo.pointOnPin[pin]!.end;
                        //   await compressFrame(pin, size);
                        //   await addToOutput(254);
                        // }
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
          )
        ],
      ),
    );
  }
}






