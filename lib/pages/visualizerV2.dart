// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:async/async.dart';
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

class Visualizer extends StatefulWidget {
  const Visualizer({super.key});

  @override
  State<Visualizer> createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer>
    with AutomaticKeepAliveClientMixin<Visualizer> {
  static BluetoothConnection? connection;

  MainMatrix mainInfo = MainMatrix();
  late FilePickerResult? filePickerResult;
  Map<String, String> contentInputText = {
    "Файл": "",
    "Изображение": "",
  };
  late img.Image image;
  int oldPin = 0, oldPoint = 0;
  int point = 0;
  List<int> output = [];
  List<int> degubInput = [];

  void compressFrame(
    int pin,
    int size, [
    img.Pixel? pixel,
  ]) {
    if (pin != oldPin) {
      output.add(pin);
      output.addAll(splitInt(size, 127, 0));
      oldPin = pin;
    }
    if (pixel != null) {
      if (pixel.r != 0 && pixel.g != 0 && pixel.b != 0) {
        output.add((((pixel.r / 255) * 100).round()) + 127);
        int result = point - oldPoint;
        if (result != 1) {
          output.addAll(splitInt(result));
        }
        output.add((((pixel.g / 255) * 100).round()) + 127);
        output.add((((pixel.g / 255) * 100).round()) + 127);
      }
    }
    output.add(253);

    // compress +=
    //     convertInt(((testValue.r / 255) * 100).round(), 127);
    // int main = testValue.point - oldPoint;
    // if (main != 1) {
    //   compress += convertInt(main);
    // }
    // oldPoint = testValue.point;
    // compress +=
    //     convertInt(((testValue.g / 255) * 100).round(), 127);
    // compress +=
    //     convertInt(((testValue.b / 255) * 100).round(), 127);

    // compress += String.fromCharCode(253);
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
              filePickerResult = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg', 'gif']);
              if (filePickerResult != null) {
                setState(
                  () {
                    contentInputText["Изображение"] =
                        filePickerResult!.files.last.name;
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
                    createSnackBar(
                        context, "Поле '${element.key}' не заполнено");

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

              if (await Permission.bluetooth.request().isGranted &&
                  await Permission.bluetoothConnect.request().isGranted &&
                  await Permission.bluetoothScan.request().isGranted) {
                if (await FlutterBluetoothSerial.instance.isEnabled == false) {
                  if (await FlutterBluetoothSerial.instance.requestEnable() ==
                      false) {
                    createSnackBar(context, "Необходимо включить Bluetooth");
                    return;
                  }
                }
                List<BluetoothDevice> bondedDevices =
                    await FlutterBluetoothSerial.instance.getBondedDevices();
                int? id = await push(
                  context,
                  PopUp(
                    "Bluetooth устройства",
                    "Выберите плату Arduino (HS-05)",
                    [
                      for (var item in bondedDevices)
                        if (item.name != null && item.name != "")
                          item.name!
                        else
                          item.address
                    ],
                  ),
                );
                if (id != null) {
                  if (connection != null && connection!.isConnected == true) {
                    connection!.close();
                  }
                  try {
                    createSnackBar(context,
                        "Идёт подключеник к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    connection = await BluetoothConnection.toAddress(
                        bondedDevices[id].address);
                  } catch (e) {
                    createSnackBar(context,
                        "Не удалось подключиться к ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    return;
                  }

                  createSnackBar(context,
                      "Подключение установлено с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                  //waitTask().timeout(const Duration(seconds: 10));
                  Timer? timer;
                  CancelableCompleter completer = CancelableCompleter();
                  late StreamSubscription<dynamic> read, write;
                  StreamController writeControl = StreamController();

                  read = connection!.input!.listen((Uint8List data) {
                    degubInput.addAll(data);
                    timer?.cancel();
                    timer = Timer(const Duration(seconds: 15), () {
                      print("object");
                      write.resume();
                      read.pause();

                      //completer.operation.cancel();

                      //connection!.close();
                    });
                  }, onDone: () {
                    createSnackBar(context,
                        "Подключение разорвано с ${bondedDevices[id].name ?? bondedDevices[id].address} ");
                    int a = output.toString().length;
                    int b = degubInput.toString().length;
                    debugPrint(
                        "Output - $a length. Input - $b length. Потеря - ${b - a}.");
                  });
                  read.pause();
                  Stream<int> timedCounter(Duration interval,
                      [int? maxCount]) async* {
                    int i = 0;
                    while (true) {
                      await Future.delayed(interval);
                      yield i++;
                      if (i == maxCount) break;
                    }
                  }

                  write = writeControl.stream.listen((date) {
                    connection?.output.add(Uint8List.fromList(date));
                  });

                  Set<int> allPin = mainInfo.pointOnPin.keys.toSet();
                  for (var pin in allPin) {
                    int size = mainInfo.pointOnPin[pin]!.end;
                    compressFrame(pin, size);
                  }
                  for (var i = 0; i < image.frames.length; i++) {
                    allPin = mainInfo.pointOnPin.keys.toSet();

                    img.Image frame = image.getFrame(i);
                    for (var column = 0;
                        column < mainInfo.location.length;
                        column++) {
                      for (var row = 0;
                          row < mainInfo.location[column].length;
                          row++) {
                        point = mainInfo.location[column][row].point.begin;
                        int pin = mainInfo.location[column][row].pin;
                        int size = mainInfo.pointOnPin[pin]!.end;
                        if (allPin.contains(pin)) {
                          allPin.remove(pin);
                        }
                        for (var y = 0; y < mainInfo.sizeMatrix.height; y++) {
                          if (y % 2 == 0) {
                            for (var x = mainInfo.sizeMatrix.width - 1;
                                x >= 0;
                                x--) {
                              compressFrame(pin, size, frame.getPixel(x, y));
                            }
                          } else {
                            for (var x = 0;
                                x < mainInfo.sizeMatrix.width;
                                x++) {
                              compressFrame(pin, size, frame.getPixel(x, y));
                            }
                          }
                          point++;
                        }
                      }
                    }
                    for (var pin in allPin) {
                      int size = mainInfo.pointOnPin[pin]!.end;
                      compressFrame(pin, size);
                    }
                    writeControl.add(output);
                    write.pause();
                    read.resume();
                  }

                  //timer.cancel();
                  // await Future.delayed(const Duration(seconds: 10));
                  //connection.output.add(Uint8List.fromList(utf8.encode(a)));

                  // if (lastPin == true) {
                  //   noCompress =
                  //       "P${testMatrix.pin}S${testMatrix.size}R${testValue.r}I${testValue.point}G${testValue.g}B${testValue.b}";

                  //   compress += convertInt(testMatrix.pin);
                  //   compress += convertInt(testMatrix.size, 127, 0);
                  //   // print("PIN = ${testMatrix.pin} ");
                  //   // print("SIZE = ${testMatrix.size} ");
                  // } else {
                  //   lastPin = false;
                  //   noCompress =
                  //       "R${testValue.r}I${testValue.point}G${testValue.g}B${testValue.b}";
                  // }

                  // // print("RED = ${testValue.r}");
                  // // print("POINT = ${testValue.point}");
                  // // print("GREEN = ${testValue.g}");
                  // // print("BLUE = ${testValue.b}");
                  // //print(noCompress);

                  // //to do : повторение pin и size . добавить if

                  // compress +=
                  //     convertInt(((testValue.r / 255) * 100).round(), 127);
                  // int main = testValue.point - oldPoint;
                  // if (main != 1) {
                  //   compress += convertInt(main);
                  // }
                  // oldPoint = testValue.point;
                  // compress +=
                  //     convertInt(((testValue.g / 255) * 100).round(), 127);
                  // compress +=
                  //     convertInt(((testValue.b / 255) * 100).round(), 127);

                  // compress += String.fromCharCode(253);
                  // Uint8List a = Uint8List.fromList([152]);
                  // var b = a.buffer;
                  //connection!.output.add(Uint8List.fromList(latin1.encode(a)));
                  // Timer timer = Timer(
                  //     const Duration(seconds: 10), () => print(DateTime.now()));

                  //timer.cancel();
                  // await Future.delayed(const Duration(seconds: 10));
                  //connection.output.add(Uint8List.fromList(utf8.encode(a)));
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

// 0 - 126
// 127 - 252
List<int> splitInt(int value, [int plus = 0, int? change]) {
  int length = value.toString().length;
  List<int> out = [];
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
    if (change != null && length <= 0) {
      out.add(result + change);
    } else {
      out.add(result + plus);
    }
  }
  return out;
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
