import 'package:flutter/material.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';

class InputText extends StatelessWidget {
  late String title;
  late Function() function;
  late Widget? widget;

  InputText(this.title, String linkText, this.function, {super.key}) {
    widget = MyButton(function, linkText);
  }
  InputText.number(this.title, TextEditingController textEditingController,
      {super.key}) {
    widget = MyTextField.number(textEditingController);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 3),
            child: Text(
              title,
              style: TextStyle(
                color: colorText[0],
                fontSize: 15,
              ),
            ),
          ),
          Container(decoration: borderDecoration, child: widget!),
        ],
      ),
    );
  }
}

class InputTextMutli extends StatelessWidget {
  final List<InputText> inputText;
  final String title;
  const InputTextMutli(this.title, this.inputText, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 3),
          child: Text(
            title,
            style: TextStyle(
              color: colorText[0],
              fontSize: 17,
            ),
          ),
        ),
        Row(
          children: [
            for (int i = 0; i < inputText.length - 1; i++)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: inputText[i],
                ),
              ),
            Expanded(
              child: inputText.last,
            ),
          ],
        ),
      ],
    );
  }
}
