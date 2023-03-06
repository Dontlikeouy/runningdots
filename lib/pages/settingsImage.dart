// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:runningdots/widget/buttons.dart';
import '../fileMe.dart';
import '../json.dart';
import '../popUpsV2.dart';
import '../style/color.dart';
import '../widget/inputText.dart';

class SettingsImage extends StatefulWidget {
  const SettingsImage({super.key});

  @override
  State<SettingsImage> createState() => _SettingsImageState();
}

class _SettingsImageState extends State<SettingsImage> with AutomaticKeepAliveClientMixin<SettingsImage> {
  Map<String, String> contentInputText = {
    "Файл": "",
    "Папка с изображениями": "",
  };
  bool wait = false;
  late FilePickerResult? filePickerResult;
  MainMatrix mainInfo = MainMatrix();
  @override
  get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
              if (tText == "") {
                createSnackBar(context, "Ошибка файл является пустым");
                return;
              }
              try {
                mainInfo = MainMatrix.fromJson(
                  jsonDecode(tText),
                );
              } catch (e) {
                createSnackBar(context, "Ошибка при считывание файла настроек");
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
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: MyButton.fill(
            () async {
              if (wait == true) {
                createSnackBar(context, "В данный момент изображения обрабатываются..");
                return;
              }
              wait = true;
              for (var element in contentInputText.entries) {
                if (element.value == "") {
                  createSnackBar(context, "Поле '${element.key}' не заполнено");
                  return;
                }
              }
              if (Platform.isAndroid && await Permission.manageExternalStorage.isDenied == true) {
                await Permission.manageExternalStorage.request();
              }
              try {
                createSnackBar(context, "Изображения обрабатываются..");
                Directory savePath = Directory(contentInputText["Папка с изображениями"]!);
                if (await Directory("${savePath.path}/ResizeRunningDots").exists() == true) {
                  await Directory("${savePath.path}/ResizeRunningDots").delete(recursive: true);
                }
                await for (var entity in savePath.list(recursive: false, followLinks: false)) {
                  if (entity.path.split(".").last == "png") {
                    var result = await resizeImage(
                      savePath.path,
                      entity.path,
                      mainInfo.sizeMatrix.width,
                      mainInfo.sizeMatrix.height,
                    );
                    if (result == false) {
                      createSnackBar(context, "Не удалость сохранить\n${entity.path}");
                      throw ("error");
                    }
                  }
                }
                if (Platform.isAndroid) {
                  push(
                    context,
                    PopUpInfo("Оповещение", "Файлы сохранены в\n${savePath.path}/ResizeRunningDots"),
                  );
                } else {
                  push(
                    context,
                    PopUpInfo("Оповещение", "Файлы сохранены в\n${savePath.path}\\ResizeRunningDots"),
                  );
                }
              } catch (e) {
                createSnackBar(context, "Произошла ошибка при обработке изображений\n$e ");
              }
              wait = false;
            },
            "Изменить размер изображения",
            color: purple[1],
          ),
        ),
      ]),
    );
  }
}
