import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:runningdots/style/color.dart';

class MyTextField extends StatelessWidget {
  String? hintText;
  bool inputNumber = false;
  TextEditingController textEditingController;
  MyTextField(this.textEditingController, {this.hintText, super.key});
  MyTextField.number(this.textEditingController, {this.hintText, super.key}) {
    inputNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: inputNumber == true ? TextInputType.number : null,
      inputFormatters: inputNumber == true
          ? [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              TextInputFormatter.withFunction(
                (oldValue, newValue) => newValue.copyWith(
                  text: newValue.text,
                ),
              ),
            ]
          : null,
      autofocus: false,
      autocorrect: false,
      controller: textEditingController,
      decoration: InputDecoration(
        isCollapsed: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 15,
        ),
        focusColor: Colors.grey,
      ),
      style: TextStyle(
        color: colorText[0],
        fontSize: 15,
      ),
    );
  }
}

enum ColorButton {
  purple,
  darkPurlpe,
  transparent,
}

class MyButton extends StatelessWidget {
  Color color;
  Function() function;
  Widget? widget;

  MyButton(this.function, String linkText, {this.color = Colors.transparent, super.key}) {
    widget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Text(
        linkText,
        style: TextStyle(
          fontSize: 15,
          color: colorText[0],
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
  MyButton.fill(this.function, String text, {this.color = Colors.transparent, final Color? textColor, super.key}) {
    widget = Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          color: textColor ?? colorText[0],
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
  MyButton.icon(this.function, Icon icon, {this.color = Colors.transparent, double padding = 10, super.key}) {
    widget = Padding(
      padding: EdgeInsets.all(padding),
      child: icon,
    );
  }
  MyButton.iconsvg(this.function, SvgPicture icon, {this.color = Colors.transparent, double padding = 10, super.key}) {
    widget = Padding(
      padding: EdgeInsets.all(padding),
      child: icon,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      child: InkWell(onTap: function, child: widget),
    );
  }
}
