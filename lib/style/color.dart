import 'package:flutter/material.dart';

const List<Color> textColor = [
  Colors.white,
  Color(0xffc4c4d8),
];

const List<Color> purple = [
  Color(0xff202021), //0
  Color(0xff4e419c), //1
  Color(0xff675db5), //2
  Color(0xff7976b8), //3
  Color(0xff8a88bd), //4
];

BoxDecoration borderDecoration = BoxDecoration(
  border: Border.all(
    color: purple[2],
    width: 2,
  ),
);
