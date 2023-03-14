// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';
import 'package:runningdots/widget/inputText.dart';
import 'package:runningdots/popUpsV2.dart';

import '../fileMe.dart';
import '../json.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, String> contentInputText = {
    "Файл": "",
    "Pin": "",
    "ПоВертик": "Пусто",
    "ПоГориз": "Пусто",
    "Вар": "4",
  };
  TextEditingController widthMatrix = TextEditingController(text: "");
  TextEditingController heightMatrix = TextEditingController(text: "");
  int point1 = 0, point2 = -1;
  MainMatrix mainMatrix = MainMatrix();
  late MatrixInfo matrixInfo;
  bool palette = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputText(
            "Файл",
            contentInputText["Файл"]!,
            () async {
              int? id = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PopUpAdd(
                    "Выбор/создание файла настроек",
                    "Добавить новый файл",
                    getJson(),
                  ),
                ),
              );
              List<String> files = getJson();
              if (id != null) {
                String tText = readJson(files[id]);
                if (tText != '') {
                  // try {
                  mainMatrix = MainMatrix.fromJson(
                    jsonDecode(tText),
                  );
                } else {
                  mainMatrix = MainMatrix();
                }

                setState(
                  () {
                    contentInputText["Pin"] = "";
                    widthMatrix.text = "";
                    heightMatrix.text = "";

                    contentInputText["Файл"] = files[id];
                  },
                );
              } else if (id == null) {
                if (contentInputText["Файл"] != "") {
                  if (existsJson(contentInputText["Файл"]!) == false) {
                    contentInputText["Файл"] = "";
                    mainMatrix = MainMatrix();
                    setState(() {
                      contentInputText["Файл"] = "";
                    });
                  }
                }
              }
            },
          ),
          InputText(
            "Pin",
            contentInputText["Pin"]!,
            () async {
              List<String> pin = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];
              int? id = await push(
                context,
                PopUp(
                  "Выбор Pin",
                  "Порт на плате arduino к которому подключена матрица",
                  pin,
                ),
              );
              if (id != null) {
                setState(
                  () {
                    contentInputText["Pin"] = pin[id];
                  },
                );
              }
            },
          ),
          InputTextMutli(
            "Размер",
            [
              InputText.number(
                "Ширина",
                widthMatrix,
              ),
              InputText.number(
                "Высота",
                heightMatrix,
              ),
            ],
          ),
          InputTextMutli(
            "Расположение",
            [
              InputText(
                "По вертикали",
                contentInputText["ПоВертик"]!,
                () async {
                  List<String> vertical = ['Пусто', 'Снизу', 'Сверху'];

                  int? id = await push(
                    context,
                    PopUp(
                      "Расположение по вертикали",
                      "Расположение относительно предыдущей матрицы по вертикали.",
                      vertical,
                    ),
                  );
                  if (id != null) {
                    setState(
                      () {
                        contentInputText["ПоВертик"] = vertical[id];
                      },
                    );
                  }
                },
              ),
              InputText(
                "По горизонтали",
                contentInputText["ПоГориз"]!,
                () async {
                  List<String> horizontal = ['Пусто', 'Слева', 'Справа'];

                  int? id = await push(
                    context,
                    PopUp(
                      "Расположение по горизонтали",
                      "Расположение относительно предыдущей матрицы по горизонтали.",
                      horizontal,
                    ),
                  );
                  if (id != null) {
                    setState(
                      () {
                        contentInputText["ПоГориз"] = horizontal[id];
                      },
                    );
                  }
                },
              ),
            ],
          ),
          InputText(
            "Вариант расположения",
            contentInputText["Вар"]!,
            () async {
              List<MyImage> option = [
                for (int i = 1; i <= 8; i++)
                  MyImage(
                    i.toString(),
                    SvgPicture.asset(
                      fit: BoxFit.contain,
                      'assets/$i.svg',
                    ),
                  ),
              ];

              int? id = await push(
                context,
                PopUpImage(
                  "Вариант расположения начальной точки",
                  option,
                  int.parse(contentInputText["Вар"]!) - 1,
                ),
              );
              if (id != null) {
                setState(
                  () {
                    contentInputText["Вар"] = option[id].title;
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
                if (widthMatrix.text == "" || heightMatrix.text == "") return;
                if (contentInputText["ПоВертик"] == 'Пусто' && contentInputText["ПоГориз"] == 'Пусто') {
                  if (mainMatrix.location.isEmpty) {
                    mainMatrix.location.add([]);
                  } else {
                    push(
                      context,
                      const PopUpInfo(
                        "Оповещение",
                        "Невозможно использовать значение 'Пусто' в обоих полях, т.к. начальная матрица бьла задана.",
                      ),
                    );
                    return;
                  }
                } else {
                  if (mainMatrix.location.isEmpty) {
                    push(
                      context,
                      const PopUpInfo(
                        "Оповещение",
                        "Невозможно использовать другие значния, кроме значение 'Пусто' в обоих полях, т.к. начальная матрица не задана.",
                      ),
                    );
                    return;
                  }
                }
                int pin = int.parse(contentInputText['Pin']!);
                if (!mainMatrix.infoPin.containsKey(pin)) {
                  mainMatrix.infoPin.addAll({pin: InfoPin()});
                }
                int width = int.parse(widthMatrix.text);
                int height = int.parse(heightMatrix.text);

                mainMatrix.infoPin[pin]!.end = width * height + mainMatrix.infoPin[pin]!.end;

                mainMatrix.infoPin[pin]!.begin = mainMatrix.infoPin[pin]!.end - (width * height);

                matrixInfo = MatrixInfo(
                  pin,
                  mainMatrix.infoPin[pin]!.begin,
                  contentInputText["Вар"]!,
                  int.parse(widthMatrix.text),
                  int.parse(heightMatrix.text),
                );

                switch (contentInputText["ПоВертик"]) {
                  case 'Сверху':
                    {
                      if (mainMatrix.row - 1 < 0) {
                        mainMatrix.location.insert(mainMatrix.row, []);
                      } else {
                        mainMatrix.row--;
                      }
                      break;
                    }
                  case 'Снизу':
                    {
                      mainMatrix.row++;

                      if (mainMatrix.location.length <= mainMatrix.row) {
                        mainMatrix.location.add([]);
                        mainMatrix.column = 0;
                      }

                      break;
                    }
                }

                switch (contentInputText["ПоГориз"]) {
                  case 'Пусто':
                    {
                      mainMatrix.location[mainMatrix.row].insert(mainMatrix.column, matrixInfo);

                      break;
                    }
                  case 'Слева':
                    {
                      if (mainMatrix.column - 1 < 0) {
                        mainMatrix.location[mainMatrix.row].insert(mainMatrix.column, matrixInfo);
                      } else {
                        mainMatrix.column--;
                        mainMatrix.location[mainMatrix.row].insert(mainMatrix.column, matrixInfo);
                      }

                      break;
                    }
                  case 'Справа':
                    {
                      mainMatrix.location[mainMatrix.row].add(matrixInfo);
                      mainMatrix.column++;

                      break;
                    }
                }
                if (mainMatrix.columnMax < mainMatrix.location[mainMatrix.row].length) {
                  mainMatrix.width += matrixInfo.width;
                  mainMatrix.columnMax = mainMatrix.location[mainMatrix.row].length;
                }
                if (mainMatrix.rowMax < mainMatrix.location.length) {
                  mainMatrix.height += matrixInfo.height;
                  mainMatrix.rowMax = mainMatrix.location.length;
                }
                writeJson(
                  contentInputText["Файл"]!,
                  jsonEncode(mainMatrix.toJson()),
                );
                createSnackBar(context, "Матрица добавлена");
              },
              "Сохранить/Добавить",
              color: purple[1],
            ),
          ),
          MyButton.fill(
            () async {
              if (palette == true) {
                createSnackBar(
                  context,
                  "Палитра создается..",
                );
              }
              palette = true;
              if (mainMatrix.location.isEmpty) {
                createSnackBar(
                  context,
                  "Невозможно добавить палитру пинов, т.к. матрица не бьла задана.",
                );
                return;
              }
              String result = await push(
                context,
                const PopUpQuestion("Оповещение", "Добавление палитры пинов должно происходить после настройки матрицы.\nДобавить палитру?"),
              );

              createSnackBar(
                context,
                "Палитра создается..",
              );
              if (result == "Да") {
                for (var pin in mainMatrix.infoPin.keys) {
                  mainMatrix.infoPin[pin]?.coordinates = [];
                }
                int x = 0, y = 0, height = 0, width = 0;
                for (int column = 0; column < mainMatrix.location.length; column++) {
                  for (int row = 0; row < mainMatrix.location[column].length; row++) {
                    height = mainMatrix.location[column][row].height;
                    width = mainMatrix.location[column][row].width;
                    int pin = mainMatrix.location[column][row].pin;
                    mainMatrix.infoPin[pin]?.coordinates.add(Coordinates(row, column, x, y));
                    x += width;
                  }
                  x = 0;
                  y += height;
                }
              }
              writeJson(
                contentInputText["Файл"]!,
                jsonEncode(mainMatrix.toJson()),
              );
              createSnackBar(
                context,
                "Палитра создана.",
              );
              palette = false;
            },
            "Добавить палитру пинов",
            color: purple[1],
          )
        ],
      ),
    );
  }
}
