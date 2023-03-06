// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
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

class _VisualizerState extends State<Visualizer> with AutomaticKeepAliveClientMixin<Visualizer> {
  static BluetoothConnection? connection;

  MainMatrix mainInfo = MainMatrix();
  late FilePickerResult? filePickerResult;
  Map<String, String> contentInputText = {
    "Файл": "",
    "Изображение": "",
  };
  late img.Image image;
  int oldPin = 0, oldPoint = 0;
  bool isLastRGB = false;
  int point = 0;
  String output = "";
  Timer? timer;

  Completer completer = Completer();
  late StreamSubscription read;
  bool close = false;

  Future<void> compressFrame(
    int pin,
    int size, [
    img.Pixel? pixel,
  ]) async {
    if (pin != oldPin) {
      if (isLastRGB == true) {
        await addToOutput(254);
      }
      await splitInt(pin);
      await splitInt(size, Part.second, Part.first);
      oldPin = pin;
    }

    if (pixel != null) {
      isLastRGB = true;
      if (!(pixel.r == 0 && pixel.g == 0 && pixel.b == 0)) {
        await addToOutput((((pixel.r / 255) * 100).round()) + 128);
        //print("$point - $oldPoint");
        int result = point - oldPoint;
        oldPoint = point;
        //if (result != 1) {
        await splitInt(point);
        //}
        await addToOutput((((pixel.g / 255) * 100).round()) + 128);
        await addToOutput((((pixel.b / 255) * 100).round()) + 128);
      }
    } else {
      isLastRGB = false;
    }
  }

  Future<void> check([int charlimit = 90]) async {
    if (output.length >= charlimit) {
      close = false;
      output += String.fromCharCode(32);
      timer = Timer(const Duration(minutes: 15), () {
        print("timeout");
        connection?.close();
        completer.complete();
        close = true;
      });

      read.resume();
      connection?.output.add(latin1.encode(output.substring(0, charlimit + 1)));
      await Future(() => completer.future);
      output = output.substring(charlimit + 1, output.length);
      completer = Completer();
      if (close == true) {
        throw ("timeout");
      }
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
                  getFiles(),
                ),
              );
              List<String> files = getFiles();

              if (id != null) {
                String tText = readTextInFile(files[id]);
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
            "Изображение: 'png', 'jpg', 'gif'",
            contentInputText["Изображение"]!,
            () async {
              filePickerResult = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png', 'jpg', 'gif']);
              if (filePickerResult != null) {
                setState(
                  () {
                    contentInputText["Изображение"] = filePickerResult!.files.last.name;
                  },
                );
              }
            },
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: MyButton.fill(
              () {
                for (var element in contentInputText.entries) {
                  if (element.value == "") {
                    createSnackBar(context, "Поле '${element.key}' не заполнено");
                    return;
                  }
                }

                NewImage result = resizeImage(
                  filePickerResult!.files.first.path!,
                  filePickerResult!.files.first.name,
                  mainInfo.sizeMatrix.width,
                  mainInfo.sizeMatrix.height,
                );
                image = result.image;
                push(
                  context,
                  PopUpOneImage(
                    "Предпросмотр изображения",
                    result.adaptedImage,
                  ),
                );
              },
              "Предпросмотр",
              color: purple[1],
            ),
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
                  if (connection != null && connection!.isConnected == true) {
                    connection!.close();
                  }
                  try {
                    createSnackBar(context, "Идёт подключеник к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    connection = await BluetoothConnection.toAddress(bondedDevices[id].address);
                  } catch (e) {
                    createSnackBar(context, "Не удалось подключиться к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    return;
                  }

                  createSnackBar(context, "Подключение установлено с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  oldPin = 0;
                  oldPoint = 0;
                  isLastRGB = false;
                  point = 0;
                  output = "";
                  Timer? timer2;
                  read = connection!.input!.listen((Uint8List data) {
                    for (var element in data) {
                      print("$element - ${String.fromCharCode(element)}");
                    }

                    // timer2?.cancel();
                    // timer2 = Timer(
                    //   const Duration(milliseconds: 15),
                    //   () {
                    timer?.cancel();
                    completer.complete();
                    read.pause();
                    //   },
                    // );
                  }, onDone: () {
                    createSnackBar(context, "Подключение разорвано с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  }, onError: (error) {
                    createSnackBar(context, "Произошла ошибка при считывании - подключение разорвано с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  });

                  try {
                    Set<int> allPin = mainInfo.pointOnPin.keys.toSet();
                    await addToOutput(255);

                    for (var i = 0; i < image.frames.length; i++) {
                      allPin = mainInfo.pointOnPin.keys.toSet();

                      img.Image frame = image.getFrame(i);

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

                          if (allPin.contains(pin)) {
                            allPin.remove(pin);
                          }
                          for (int nY = y; nY < y + height; nY++) {
                            if (nY % 2 == 0) {
                              for (int nX = x + width - 1; nX >= x; nX--) {
                                await compressFrame(pin, size, frame.getPixel(nX, nY));
                                await addToOutput(254);

                                point++;
                              }
                            } else {
                              for (int nX = x; nX < x + width; nX++) {
                                await compressFrame(pin, size, frame.getPixel(nX, nY));
                                await addToOutput(254);

                                point++;
                              }
                            }
                          }

                          await addToOutput(254);
                          x += width;
                        }
                        x = 0;
                        y += height;
                      }

                      for (var pin in allPin) {
                        int size = mainInfo.pointOnPin[pin]!.end;
                        await compressFrame(pin, size);
                        await addToOutput(254);
                      }
                    }
                    await check(output.length);
                  } catch (timeout) {
                    createSnackBar(context, "Устройство ${bondedDevices[id].name ?? bondedDevices[id].address} не отвечает");
                  }
                  timer?.cancel();
                  read.resume();
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

bool cancelled = false;
CancelableFuture(Duration duration, void Function() callback) {
  Future<void>.delayed(duration, () {
    if (!cancelled) {
      callback();
    }
  });
}

void cancel() {
  cancelled = true;
}

Future<dynamic> _myFuture() async {
  await Future.delayed(const Duration(seconds: 10));
  return;
}

void determinePoint(img.Image frame, int x, int y) {
  img.Pixel pixel = frame.getPixel(x, y);
}




// void _sendMessage(String text) async {
//   text = text.trim();

//   connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
//   await connection!.output.allSent;

//   connection.input.listen((Uint8List data) {
//     print('Data incoming: ${ascii.decode(data)}');
//     connection.output.add(data); // Sending data

//     if (ascii.decode(data).contains('!')) {
//       connection.finish(); // Closing connection
//       print('Disconnecting by local host');
//     }
//   }).onDone(() {
//     print('Disconnected by remote request');
//   });
// }
