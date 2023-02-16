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
                    getFiles(),
                  ),
                ),
              );
              List<String> files = getFiles();
              if (id != null) {
                String tText = readTextInFile(files[id]);
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
                  if (existsFile(contentInputText["Файл"]!) == false) {
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
          MyButton.fill(
            () {
              for (var element in contentInputText.entries) {
                if (element.value == "") {
                  createSnackBar(context, "Поле '${element.key}' не заполнено");
                  return;
                }
              }
              if (widthMatrix.text == "" || heightMatrix.text == "") return;
              if (contentInputText["ПоВертик"] == 'Пусто' &&
                  contentInputText["ПоГориз"] == 'Пусто') {
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
              if (!mainMatrix.pointOnPin.containsKey(pin)) {
                mainMatrix.pointOnPin.addAll({pin: Point.empty()});
              }

              int widthMatrixInt = int.parse(widthMatrix.text),
                  heightMatrixInt = int.parse(heightMatrix.text);

              mainMatrix.pointOnPin[pin]!.end =
                  widthMatrixInt * heightMatrixInt +
                      mainMatrix.pointOnPin[pin]!.end;

              mainMatrix.pointOnPin[pin]!.begin =
                  mainMatrix.pointOnPin[pin]!.end -
                      (widthMatrixInt * heightMatrixInt - 1);

              matrixInfo = MatrixInfo(
                SizeMatrix(
                  int.parse(widthMatrix.text),
                  int.parse(heightMatrix.text),
                ),
                pin,
                Point(mainMatrix.pointOnPin[pin]!.begin,
                    mainMatrix.pointOnPin[pin]!.end),
                contentInputText["Вар"]!,
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
                    mainMatrix.location[mainMatrix.row]
                        .insert(mainMatrix.column, matrixInfo);

                    break;
                  }
                case 'Слева':
                  {
                    if (mainMatrix.column - 1 < 0) {
                      mainMatrix.location[mainMatrix.row]
                          .insert(mainMatrix.column, matrixInfo);
                    } else {
                      mainMatrix.column--;
                      mainMatrix.location[mainMatrix.row]
                          .insert(mainMatrix.column, matrixInfo);
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
              if (mainMatrix.columnMax <
                  mainMatrix.location[mainMatrix.row].length) {
                mainMatrix.sizeMatrix.width += matrixInfo.sizeMatrix.width;
                mainMatrix.columnMax =
                    mainMatrix.location[mainMatrix.row].length;
              }
              if (mainMatrix.rowMax < mainMatrix.location.length) {
                mainMatrix.sizeMatrix.height += matrixInfo.sizeMatrix.height;
                mainMatrix.rowMax = mainMatrix.location.length;
              }
              writeTextToFile(
                contentInputText["Файл"]!,
                jsonEncode(mainMatrix.toJson()),
              );
            },
            "Сохранить/Добавить",
            color: purple[1],
          ),
        ],
      ),
    );
  }
}
