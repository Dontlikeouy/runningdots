import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';
import 'package:runningdots/widget/comboButtons.dart';

import 'fileMe.dart';

Future<int?> push(BuildContext context, Widget popUp) async {
  return await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => popUp),
  );
}

Widget createDescription(String description) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.only(bottom: 10),
    color: purple[1],
    alignment: Alignment.center,
    child: Text(
      description,
      style: TextStyle(
        color: textColor[0],
      ),
    ),
  );
}

Widget createPopUp(BuildContext context, String title, Widget mainWidget,
    [Widget? widget]) {
  return SafeArea(
    child: Scaffold(
      body: Container(
        color: purple[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: purple[0],
                border: Border(
                  top: BorderSide(
                    color: purple[1],
                    width: 5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor[0],
                        ),
                      ),
                    ),
                  ),
                  MyButton.icon(
                    () {
                      Navigator.pop(context);
                    },
                    Icon(
                      Icons.close,
                      color: purple[0],
                    ),
                    color: purple[1],
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: mainWidget,
              ),
            ),
            if (widget != null) widget
          ],
        ),
      ),
    ),
  );
}

Widget createInfo(String text) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 30,
      ),
      decoration: borderDecoration,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor[0],
          fontSize: 15,
        ),
      ),
    ),
  );
}

class PopUp extends StatelessWidget {
  final String title, description;
  final List<String> values;

  const PopUp(this.title, this.description, this.values, {super.key});

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      title,
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            createDescription(description),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < values.length; i++)
                  Container(
                    decoration: borderDecoration,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: MyButton(
                      () {
                        Navigator.pop(context, i);
                      },
                      values[i],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PopUpAdd extends StatefulWidget {
  final String title, hintText;
  List<String> values;
  PopUpAdd(this.title, this.hintText, this.values, {super.key});

  @override
  State<PopUpAdd> createState() => _PopUpAddState();
}

class _PopUpAddState extends State<PopUpAdd> {
  final TextEditingController newFile = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      widget.title,
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: borderDecoration,
              margin: const EdgeInsets.only(bottom: 10),
              child: ComboButton.textField(
                () async {
                  String tText = newFile.text.trim();

                  if (tText != '') {
                    if (RegExp(r'[\\/:*?"<>]').firstMatch(tText) != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PopUpInfo(
                            "Предупреждение",
                            'Имя файла не должно содеражать:\n/ \\ : * ? " < > ',
                          ),
                        ),
                      );
                      return;
                    }
                    if (existsFile(newFile.text) == true) {
                      String result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PopUpQuestion(
                                  "Предупреждение",
                                  "Данный файл существует. Пересоздать?"),
                            ),
                          ) ??
                          '';

                      if (result == 'Нет') {
                        return;
                      }
                    }

                    createFile(newFile.text);
                    newFile.value = const TextEditingValue(text: "");

                    setState(() {
                      widget.values = getFiles();
                    });
                  }
                },
                newFile,
                widget.hintText,
                Icon(
                  Icons.check,
                  color: purple[0],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.values.length; i++)
                  Container(
                    decoration: borderDecoration,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ComboButton(
                      () {
                        Navigator.pop(context, i);
                      },
                      () async {
                        String result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PopUpQuestion(
                                    "Предупреждение",
                                    "Данный файл будет удалён безвозратно. Удалить?"),
                              ),
                            ) ??
                            '';

                        if (result == 'Да') {
                          deleteFile(widget.values[i]);
                          setState(() {
                            widget.values.removeAt(i);
                          });
                        }
                      },
                      Icon(
                        Icons.delete,
                        color: purple[0],
                      ),
                      widget.values[i],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PopUpInfo extends StatelessWidget {
  final String title, text;
  const PopUpInfo(this.title, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      title,
      createInfo(text),
    );
  }
}

class PopUpQuestion extends StatelessWidget {
  final String title, text;
  const PopUpQuestion(this.title, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      title,
      createInfo(text),
      Container(
        decoration: BoxDecoration(
          color: purple[0],
          border: Border(
            top: BorderSide(
              color: purple[1],
              width: 5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: MyButton.fill(
                () {
                  Navigator.pop(context, "Нет");
                },
                "Нет",
                color: purple[1],
              ),
            ),
            Expanded(
              child: MyButton.fill(
                () {
                  Navigator.pop(context, "Да");
                },
                "Да",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyImage {
  String title;
  SvgPicture image;
  MyImage(this.title, this.image);
}

class PopUpImage extends StatefulWidget {
  final String title;
  final List<MyImage> card;
  final int startPoint;
  const PopUpImage(this.title, this.card, this.startPoint, {super.key});

  @override
  State<PopUpImage> createState() => _PopUpImageState();
}

class _PopUpImageState extends State<PopUpImage> {
  int now = 0;

  @override
  void initState() {
    super.initState();
    now = widget.startPoint;
  }

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      widget.title,
      Container(
        decoration: borderDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: purple[2],
                    width: 2,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  widget.card[now].title,
                  style: TextStyle(
                    color: textColor[1],
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: widget.card[now].image,
              ),
            )
          ],
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: purple[1],
          border: Border(
            top: BorderSide(
              color: purple[1],
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: MyButton.icon(
                () {
                  setState(() {
                    if (now - 1 >= 0) {
                      now--;
                    } else {
                      now = widget.card.length - 1;
                    }
                  });
                },
                Icon(
                  Icons.navigate_before,
                  color: purple[2],
                  size: 35,
                ),
                padding: 7,
                color: purple[0],
              ),
            ),
            Expanded(
              child: MyButton.fill(
                () {
                  Navigator.pop(context, now);
                },
                "Выбрать",
                colorText: textColor[1],
              ),
            ),
            Expanded(
              child: MyButton.icon(
                () {
                  setState(() {
                    if (now + 1 != widget.card.length) {
                      now++;
                    } else {
                      now = 0;
                    }
                  });
                },
                Icon(
                  Icons.navigate_next,
                  color: purple[2],
                  size: 35,
                ),
                padding: 7,
                color: purple[0],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopUpOneImage extends StatefulWidget {
  final String title;
  final Image image;

  const PopUpOneImage(this.title, this.image, {super.key});

  @override
  State<PopUpOneImage> createState() => _PopUpOneImageState();
}

class _PopUpOneImageState extends State<PopUpOneImage> {
  double scaleFactor = 1;

  @override
  Widget build(BuildContext context) {
    return createPopUp(
      context,
      widget.title,
      InteractiveViewer(
        scaleFactor: scaleFactor,
        child: FittedBox(
          fit: BoxFit.contain,
          child: widget.image,
        ),
      ),
    );
  }
}
