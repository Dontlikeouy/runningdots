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
  MainInfoAboutMatrix mainInfo = MainInfoAboutMatrix();

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
                  mainInfo = MainInfoAboutMatrix.fromJson(
                    jsonDecode(tText),
                  );
                } else {
                  mainInfo = MainInfoAboutMatrix();
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
                    mainInfo = MainInfoAboutMatrix();
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
              for (var element in contentInputText.values) {
                if (element == "") {
                  push(
                    context,
                    const PopUpInfo(
                      "Оповещение",
                      "Одно из полей является пустым.",
                    ),
                  );
                  return;
                }
              }
              if (widthMatrix.text == "" || heightMatrix.text == "") return;
              if (contentInputText["ПоВертик"] == 'Пусто' &&
                  contentInputText["ПоГориз"] == 'Пусто') {
                if (mainInfo.location.isEmpty) {
                  mainInfo.location.add([]);
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
                if (mainInfo.location.isEmpty) {
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

              if (!mainInfo.pointOnPin.containsKey(contentInputText['Pin'])) {
                mainInfo.pointOnPin
                    .addAll({contentInputText['Pin']!: Point.empty()});
              }

              int widthMatrixInt = int.parse(widthMatrix.text),
                  heightMatrixInt = int.parse(heightMatrix.text);

              mainInfo.pointOnPin[contentInputText['Pin']]!.point2 =
                  widthMatrixInt * heightMatrixInt +
                      mainInfo.pointOnPin[contentInputText['Pin']]!.point2;

              mainInfo.pointOnPin[contentInputText['Pin']]!.point1 =
                  mainInfo.pointOnPin[contentInputText['Pin']]!.point2 -
                      (widthMatrixInt * heightMatrixInt - 1);

              matrixInfo = MatrixInfo(
                SizeMatrix(
                  int.parse(widthMatrix.text),
                  int.parse(heightMatrix.text),
                ),
                int.parse(contentInputText["Pin"]!),
                Point(mainInfo.pointOnPin[contentInputText['Pin']]!.point1,
                    mainInfo.pointOnPin[contentInputText['Pin']]!.point2),
                contentInputText["Вар"]!,
              );

              switch (contentInputText["ПоВертик"]) {
                case 'Сверху':
                  {
                    if (mainInfo.row - 1 < 0) {
                      mainInfo.location.insert(mainInfo.row, []);
                    } else {
                      mainInfo.row--;
                    }
                    break;
                  }
                case 'Снизу':
                  {
                    mainInfo.row++;

                    if (mainInfo.location.length <= mainInfo.row) {
                      mainInfo.location.add([]);
                      mainInfo.column = 0;
                    }

                    break;
                  }
              }

              switch (contentInputText["ПоГориз"]) {
                case 'Пусто':
                  {
                    mainInfo.location[mainInfo.row]
                        .insert(mainInfo.column, matrixInfo);

                    break;
                  }
                case 'Слева':
                  {
                    if (mainInfo.column - 1 < 0) {
                      mainInfo.location[mainInfo.row]
                          .insert(mainInfo.column, matrixInfo);
                    } else {
                      mainInfo.column--;
                      mainInfo.location[mainInfo.row]
                          .insert(mainInfo.column, matrixInfo);
                    }

                    break;
                  }
                case 'Справа':
                  {
                    mainInfo.location[mainInfo.row].add(matrixInfo);
                    mainInfo.column++;

                    break;
                  }
              }
              if (mainInfo.columnMax < mainInfo.location[mainInfo.row].length) {
                mainInfo.sizeMatrix.width += matrixInfo.sizeMatrix.width;
                mainInfo.columnMax = mainInfo.location[mainInfo.row].length;
              }
              if (mainInfo.rowMax < mainInfo.location.length) {
                mainInfo.sizeMatrix.height += matrixInfo.sizeMatrix.height;
                mainInfo.rowMax = mainInfo.location.length;
              }
              var w = mainInfo.sizeMatrix.width;
              var h = mainInfo.sizeMatrix.height;

              writeTextToFile(
                contentInputText["Файл"]!,
                jsonEncode(mainInfo.toJson()),
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
