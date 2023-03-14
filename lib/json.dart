// class MatrixInfo {
//   late SizeMatrix sizeMatrix;
//   late int pin;
//   late Point point;
//   late String option;
//   MatrixInfo(this.sizeMatrix, this.pin, this.point, this.option);

//   MatrixInfo.fromJson(Map<String, dynamic> json) {
//     pin = json['pin'];
//     point = Point.fromJson(json['point']);
//     sizeMatrix = SizeMatrix.fromJson(json['sizeMatrix']);
//     option = json['option'];
//   }

//   Map<String, dynamic> toJson() => {
//         'pin': pin,
//         'point': point.toJson(),
//         'sizeMatrix': sizeMatrix.toJson(),
//         'option': option,
//       };
// }

import 'package:flutter/material.dart';

class Point {
  int begin = 0, end = 0;

  Point.empty();
  Point(this.begin, this.end);

  Point.fromJson(Map<String, dynamic> json) {
    begin = json['begin'];
    end = json['end'];
  }

  Map<String, int> toJson() => {
        'begin': begin,
        'end': end,
      };
}

class MatrixInfo {
  MatrixInfo(this.pin, this.point, this.option, this.width, this.height);
  MatrixInfo.fromJson(Map<String, dynamic> json) {
    pin = json['pin'];
    point = json['point'];
    height = json['height'];
    width = json['width'];
    option = json['option'];
  }

  Map<String, dynamic> toJson() => {
        'pin': pin,
        'point': point,
        'height': height,
        'width': width,
        'option': option,
      };
  int pin = 0;
  int point = 0;
  int height = 0, width = 0;
  String option = "";
}

class Coordinates {
  Coordinates(this.row, this.column,this.x,this.y);
  Coordinates.fromJson(Map<String, dynamic> json) {
    row = json['row'];
    column = json['column'];
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'column': column,
      };
  int x=0,y=0;
  int row = 0, column = 0;
}

class InfoPin {
  InfoPin();
  InfoPin.fromJson(Map<String, dynamic> json) {
    begin = json['begin'];
    end = json['end'];
    coordinates = [for (int i = 0; i < (json['location'] as List).length; i++) Coordinates.fromJson(json['coordinates'])];
  }

  Map<String, dynamic> toJson() => {
        'begin': begin,
        'end': end,
        'coordinates': [for (int i = 0; i < coordinates.length; i++) coordinates[i].toJson()],
      };
  List<Coordinates> coordinates = [];
  int begin = 0, end = 0;
}

class MainMatrix {
  int row = 0, column = 0;
  int height = 0, width = 0;
  int rowMax = 0, columnMax = 0;

  Map<int, InfoPin> infoPin = {};
  List<List<MatrixInfo>> location = [];

  MainMatrix();
  MainMatrix.fromJson(Map<String, dynamic> json) {
    row = json['row'];
    column = json['column'];
    height = json['height'];
    width = json['width'];
    rowMax = json['rowMax'];
    columnMax = json['columnMax'];

    infoPin = <int, InfoPin>{
      for (var element in (json['infoPin'] as Map).entries) int.parse(element.key): InfoPin.fromJson(element.value),
    };

    for (int i = 0; i < (json['location'] as List).length; i++) {
      location.add([]);
      for (int j = 0; j < (json['location'][i] as List).length; j++) {
        location[i].add(MatrixInfo.fromJson(json['location'][i][j] as Map<String, dynamic>));
      }
    }
  }
  Map<String, dynamic> toJson() => {
        'row': row,
        'column': column,
        'height': height,
        'width': width,
        'rowMax': rowMax,
        'columnMax': columnMax,

        'infoPin': <String, dynamic>{for (var element in infoPin.entries) element.key.toString(): element.value.toJson()},
        'location': [
          for (int i = 0; i < location.length; i++) [for (int j = 0; j < location[i].length; j++) location[i][j].toJson()]
        ],
      };
}

class ReplaceColor
{
  ReplaceColor(this.color);
  Color color;
  Color? replace;
}