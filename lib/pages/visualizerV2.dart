import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';
import 'dart:typed_data';

import '../fileMe.dart';
import '../json.dart';
import '../popUpsV2.dart';
import '../widget/inputText.dart';

class Visualizer extends StatefulWidget {
  const Visualizer({super.key});

  @override
  State<Visualizer> createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  MainInfoAboutMatrix mainInfo = MainInfoAboutMatrix();
  late FilePickerResult? filePickerResult;
  Map<String, String> contentInputText = {
    "ФайлН": "",
    "Изоб": "",
  };
  late Image image;
  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    // if (isConnected) {
    //   isDisconnecting = true;
    //   connection?.dispose();
    //   connection = null;
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputText(
            "Файл",
            contentInputText["ФайлН"]!,
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
                  mainInfo = MainInfoAboutMatrix.fromJson(
                    jsonDecode(tText),
                  );
                } else {
                  // ignore: use_build_context_synchronously
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
                    contentInputText["ФайлН"] = files[id];
                  },
                );
              }
            },
          ),
          InputText(
            "Изображение: 'png', 'jpg', 'gif'",
            contentInputText["Изоб"]!,
            () async {
              filePickerResult = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg', 'gif']);
              if (filePickerResult != null) {
                setState(
                  () {
                    contentInputText["Изоб"] =
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
                if (contentInputText["Изоб"] != '' &&
                    contentInputText["ФайлН"] != '') {
                  List<Image> result = resizeImage(
                    filePickerResult!.files.first.path!,
                    filePickerResult!.files.first.name,
                    mainInfo.sizeMatrix.width,
                    mainInfo.sizeMatrix.height,
                  );
                  image = result[0];
                  push(
                    context,
                    PopUpOneImage(
                      "Предпросмотр изображения",
                      result[1],
                    ),
                  );
                }
              },
              "Предпросмотр",
              color: purple[1],
            ),
          ),
          MyButton.fill(
            () async {
              if (await Permission.bluetooth.request().isGranted &&
                  await Permission.bluetoothConnect.request().isGranted &&
                  await Permission.bluetoothScan.request().isGranted) {
                if (await FlutterBluetoothSerial.instance.isEnabled == false) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                }

                List<BluetoothDevice> bondedDevices =
                    await FlutterBluetoothSerial.instance.getBondedDevices();
                // ignore: use_build_context_synchronously
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
                  String a = "";
                  for (var i = 0; i < 1000; i++) {
                    a += "a";
                  }
                  try {
                    Stopwatch stopwatch = Stopwatch()..start();
                    BluetoothConnection connection =
                        await BluetoothConnection.toAddress(
                            bondedDevices[id].address);

                    //1683
                    // 	  String substr = input.substring(i,i+2);
                    // 7
                    //   char ch = FromHex(substr);
                    // 8
                    //   converted += ch;

                    connection.input!.listen(
                      (Uint8List data) {
                        print('result: ${ask.decode(data).trim()}');
                      },
                      // Closing connection
                    );
                    String a = String.fromCharCode(255);
                    int b = a.codeUnitAt(0);
                    connection.output.add(Uint8List.fromList([b]));
                    await Future.delayed(const Duration(seconds: 5));
                    for (var i = 128; i < 255; i++) {
                      String a = String.fromCharCode(i);
                      int b = a.codeUnitAt(0);
                      print("$i: $a - $b");


                      connection.output.add(Uint8List.fromList(utf8.encode(a)));
                      await Future.delayed(const Duration(seconds: 5));

                      //Timer _discoverableTimeoutTimer =Timer(Duration(days: ), () { });
                    }
                  } catch (e) {
                    // ignore: use_build_context_synchronously

                    push(
                      context,
                      const PopUpInfo(
                          "Ошибка", "Не удалось связаться с платой"),
                    );
                  }
                }
                //НА МОМЕНТЕ READ МОЖЕТ ОШИБКА
                //Uint8List.fromList(utf8.encode("$text\r\n"))
                // connection.input!.listen(_onDataReceived)
                // .then((_connection) {
                //   print('Connected to the device');
                //   connection = _connection;
                //   setState(() {
                //     isConnecting = false;
                //     isDisconnecting = false;
                //   });
                // _discoverableTimeoutTimer = null;
                // _discoverableTimeoutSecondsLeft = 0;
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
