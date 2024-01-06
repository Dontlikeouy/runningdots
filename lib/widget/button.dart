import 'dart:ffi';

import 'package:flutter/material.dart';

/* 
1) Граница 
2) Закругления границы
3) Оглавление кнопки
4) Содержание кнопки
5) Будет ли меняться содержание при нажатии
6) Цвет кнопки

*/

class Button extends StatefulWidget {
  const Button({super.key, this.onTap});

  final Void Function()? onTap;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool isPressed = false;
  Duration duration = Duration(milliseconds: 200);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPressed = true;
        });
        Future.delayed(duration).then(
          (value) => setState(
            () {
              isPressed = false;
            },
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.cyan,
          child: AnimatedContainer(
            duration: duration,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: isPressed ? Color.fromARGB(100, 0, 0, 0) : Colors.transparent,
            ),
            child: Center(child: const Text("sad")),
          ),
        ),
      ),
    );
  }
}
