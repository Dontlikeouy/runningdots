import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:runningdots/assets/colors.dart';
import 'package:runningdots/assets/names.dart';
import 'package:runningdots/popup/popup.dart';
import 'package:runningdots/widget/button.dart';
import 'package:runningdots/Bluetooth/Bluetooth.dart';

class Visualizer extends StatefulWidget {
  const Visualizer({super.key});
  @override
  State<Visualizer> createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  IconData? checkIcon = Icons.check;
  FilePickerResult? filePickerResult;
  String pathSelectedFile = AppTextDefault.pathSelectedFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Button - choose image
          Button(
            title: const Text(AppTextDefault.titleChooseImage),
            onTap: () async {
              filePickerResult = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['png'],
              );
              if (filePickerResult != null) {
                setState(
                  () {
                    pathSelectedFile = filePickerResult!.files.first.path!;
                  },
                );
              }
            },
            childPadding: const EdgeInsets.all(10),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            child: Text(
              pathSelectedFile,
            ),
          ),

          const SizedBox(height: 15),

          //Button - translate images
          /*
                          img.Image? animation = img.decodePng(File('lib/assets/2023-09-2020-17-08-ezgif.com-video-to-apng-converter.png').readAsBytesSync());
                for (var frame in animation!.frames) {
                  img.Pixel pixel = frame!.getPixel(20, 20);
                  print("${pixel.r} ${pixel.g} ${pixel.b}");
                }
           */
          Button(
            backgroundColor: AppColors.primary,
            onTap: () async {
              Bluetooth bluetooth = Bluetooth.create();
              try {
                List<BluetoothInfo> devices = <BluetoothInfo>[];
                StreamBuilder? streamBuilder;

                if (!context.mounted) return;
                BluetoothInfo? bluetoothInfo = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PopUp(
                      title: const Center(child: Text("data")),
                      upperElement: Container(
                        margin: const EdgeInsets.only(top: 1),
                        child: const LinearProgressIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.background,
                          minHeight: 2,
                        ),
                      ),
                      child: streamBuilder ??
                          (streamBuilder = StreamBuilder(
                            stream: bluetooth.findBluetoothDevice(),
                            builder: (context, AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.hasError) {
                                print(snapshot.error ?? "error");
                                Future(() {
                                  Navigator.of(context).pop();
                                });
                                return Container();
                              } else if (snapshot.hasData) {
                                if (snapshot.data is BluetoothInfo) {
                                  devices.add(snapshot.data as BluetoothInfo);
                                  return ListView.builder(
                                    itemCount: devices.length,
                                    itemBuilder: (context, index) {
                                      return Button(
                                        onTap: () => Navigator.pop(context, devices[index]),
                                        childPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(devices[index].name),
                                                Text(
                                                  devices[index].macAddress,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            ),
                                            devices[index].isAuthenticated ? const Icon(Icons.link, color: Colors.white) : Container(),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              }
                              return Container();
                            },
                          )),
                    ),
                  ),
                );

                if (bluetoothInfo == null) return;
                await bluetooth.connectBluetoothDevice(bluetoothInfo);
                try {
                  await bluetooth.sendText(bluetoothInfo, "some text");
                  print(await bluetooth.readText(bluetoothInfo));
                } catch (e) {
                  print(e.toString());
                }
                await bluetooth.disconnectBluetoothDevice();
              } catch (e) {
                print(e.toString());
              }
            },
            borderRadius: BorderRadius.circular(10),
            childPadding: const EdgeInsets.all(10),
            child: const Center(
              child: Text(
                "Передать",
                style: TextStyle(
                  color: AppColors.background,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          //CheckBox - saveDevice
          InkWell(
            borderRadius: BorderRadius.circular(3),
            onTap: () {
              setState(() {
                if (checkIcon == null) {
                  checkIcon = Icons.check;
                } else {
                  checkIcon = null;
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Запомнить устройство?",
                  style: TextStyle(color: AppColors.primary),
                ),
                const SizedBox(width: 5),
                Button(
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  childPadding: const EdgeInsets.all(5),
                  child: Icon(
                    checkIcon,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Button(
          //   backgroundColor: AppColors.primary,
          //   childPadding: EdgeInsets.all(30),
          //   onTap: () {
          //     bluetooth.findBluetoothDevice().listen((device) {
          //       print(device.name);
          //       if (device.name == "HC-05") {
          //         bluetooth.connectBluetoothDevice(device, device.isAuthenticated ? null : "1234");
          //         bluetooth.sendText(device, '\$');
          //         bluetooth.readText(device).listen((text) {
          //           print(text);
          //           bluetooth.disconnectBluetoothDevice();
          //         });
          //       }
          //     }).onDone(() {
          //       print("done");
          //     });
          //   },
          // ),

          //APNG
          // Container(
          //   child: Image.asset('lib/assets/clock.png'),
          // )
        ],
      ),
    );
  }
}
