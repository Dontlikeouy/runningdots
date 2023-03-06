class SizeMatrix {
  int height = 0, width = 0;

  SizeMatrix(this.width, this.height);

  SizeMatrix.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    width = json['width'];
  }

  Map<String, int> toJson() => {
        'height': height,
        'width': width,
      };
}

class MatrixInfo {
  late SizeMatrix sizeMatrix;
  late int pin;
  late Point point;
  late String option;
  MatrixInfo(this.sizeMatrix, this.pin, this.point, this.option);

  MatrixInfo.fromJson(Map<String, dynamic> json) {
    pin = json['pin'];
    point = Point.fromJson(json['point']);
    sizeMatrix = SizeMatrix.fromJson(json['sizeMatrix']);
    option = json['option'];
  }

  Map<String, dynamic> toJson() => {
        'pin': pin,
        'point': point.toJson(),
        'sizeMatrix': sizeMatrix.toJson(),
        'option': option,
      };
}

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

class MainMatrix {
  Map<int, Point> pointOnPin = {};
  int row = 0, column = 0;
  int rowMax = 0, columnMax = 0;
  SizeMatrix sizeMatrix = SizeMatrix(0, 0);

  late List<List<MatrixInfo>> location = [];
  MainMatrix();
  MainMatrix.fromJson(Map<String, dynamic> json) {
    pointOnPin = <int, Point>{
      for (var element in (json['pointOnPin'] as Map).entries)
        int.parse(element.key): Point.fromJson(element.value),
    };

    for (int i = 0; i < (json['location'] as List).length; i++) {
      location.add([]);
      for (int j = 0; j < (json['location'][i] as List).length; j++) {
        location[i].add(MatrixInfo.fromJson(
            json['location'][i][j] as Map<String, dynamic>));
      }
    }
    sizeMatrix = SizeMatrix.fromJson(json['sizeMatrix']);
    row = json['row'];
    column = json['column'];
    rowMax = json['rowMax'];
    columnMax = json['columnMax'];
  }
  Map<String, dynamic> toJson() => {
        'pointOnPin': <String, dynamic>{
          for (var element in pointOnPin.entries)
            element.key.toString(): element.value.toJson()
        },
        'location': [
          for (int i = 0; i < location.length; i++)
            [
              for (int j = 0; j < location[i].length; j++)
                location[i][j].toJson()
            ]
        ],
        'sizeMatrix': sizeMatrix.toJson(),
        'row': row,
        'column': column,
        'rowMax': rowMax,
        'columnMax': columnMax,
      };
}
