import 'package:flutter/material.dart';
import 'package:runningdots/style/color.dart';
import 'package:runningdots/widget/buttons.dart';

class ComboButton extends StatelessWidget {
  Widget? widget;
  Function() function;
  late Function() iconFunction;

  ComboButton(this.function, this.iconFunction, Icon icon, String linkText,
      {super.key}) {
    widget = Row(
      children: [
        Expanded(child: MyButton(function, linkText)),
        MyButton.icon(
          iconFunction,
          icon,
          color: purple[2],
        )
      ],
    );
  }
  ComboButton.textField(this.function,
      TextEditingController textEditingController, String hintText, Icon icon,
      {super.key}) {
    widget = Row(
      children: [
        Expanded(
          child: MyTextField(
            textEditingController,
            hintText: hintText,
          ),
        ),
        MyButton.icon(
          function,
          icon,
          color: purple[2],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget!;
  }
}
