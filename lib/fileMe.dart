import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';

String dir = '';
RegExp exp = RegExp("");

Future<void> getPath() async {
  String reg = r'([^\/:*?"<>].*).json$';
  if (Platform.isAndroid) {
    final directory = await getExternalStorageDirectory();
    //Permission.storage.request();

    dir = '${directory?.path}/';
    reg = 'files/$reg';
  } else {
    dir = '${Directory.current.path}\\files\\';
    reg = r'files\\' + reg;
  }
  exp = RegExp(reg);
}

List<String> getFiles() {
  if (Directory(dir).existsSync() == false) {
    Directory(dir).createSync();
  }
  List<String> tempList = [];
  for (var entity
      in Directory(dir).listSync(recursive: true, followLinks: false)) {
    String? a = exp.firstMatch(entity.path)?[1];
    if (a != null) {
      tempList.add(a);
    }
  }
  return tempList;
}

void writeTextToFile(String nameFile, String text) {
  try {
    String dirFile = '$dir$nameFile.json';
    File(dirFile).writeAsString(text);
  } catch (e) {
    return;
  }
}

String readTextInFile(String nameFile) {
  try {
    String dirFile = '$dir$nameFile.json';
    return File(dirFile).readAsStringSync();
  } catch (e) {
    return "";
  }
}

void createFile(String nameFile) {
  String dirFile = '$dir$nameFile.json';
  File(dirFile).createSync();
}

bool existsFile(String nameFile) {
  return File('$dir$nameFile.json').existsSync();
}

void deleteFile(String nameFile) {
  try {
    String dirFile = '$dir$nameFile.json';
    File(dirFile).deleteSync();
  } catch (e) {
    return;
  }
}

List<Image> resizeImage(String pathImg, String nameImg, int width, int height) {
  String typeImg = nameImg.split('.').last.toLowerCase();
  img.Image? image;
  List<Image> images = [];
  switch (typeImg) {
    case 'png':
      image = img.decodePng(File(pathImg).readAsBytesSync());

      break;
    case 'jpg':
      image = img.decodeJpg(File(pathImg).readAsBytesSync());

      break;
    case 'gif':
      image = img.decodeGif(File(pathImg).readAsBytesSync());

      break;
    default:
  }
  image = img.copyResize(image!, width: width, height: height);
  Stopwatch stopwatch = Stopwatch();
  stopwatch.start();
  test2(image);
  stopwatch.stop();
  print(
      "Elapsed ${stopwatch.elapsed} Microseconds: ${stopwatch.elapsedMicroseconds} Milliseconds: ${stopwatch.elapsedMilliseconds} Ticks: ${stopwatch.elapsedTicks}");

  switch (typeImg) {
    case 'png':
      images.add(Image.memory(img.encodePng(image)));
      break;

    case 'jpg':
      images.add(Image.memory(img.encodeJpg(image)));

      break;

    default:
      //'gif'
      images.add(Image.memory(img.encodeGif(image)));

      break;
  }
  image = img.copyResize(image, width: 1000);
  switch (typeImg) {
    case 'png':
      images.add(Image.memory(img.encodePng(image)));
      break;

    case 'jpg':
      images.add(Image.memory(img.encodeJpg(image)));

      break;

    default:
      //'gif'
      images.add(Image.memory(img.encodeGif(image)));

      break;
  }
  return images;
}

void test(img.Image image) {
  Iterator<img.Pixel> item = image.getRange(0, 0, 33, 32);
  while (item.moveNext()) {
    print(
        "X:${item.current.x} Y:${item.current.y} - R:${item.current.r} G:${item.current.g} B:${item.current.b}");
  }
}

int point = 0;

void test2(img.Image image) {
  int w = 16, h = 16;
  point = 0;
  for (var i = 0; i < image.frames.length; i++) {
    img.Image imageT = image.getFrame(i);
    for (var y = 0; y < h; y++) {
      if (y % 2 == 0) {
        for (var x = w - 1; x >= 0; x--) {
          determinePoint(imageT, x, y);
        }
      } else {
        for (var x = 0; x < w; x++) {
          determinePoint(imageT, x, y);
        }
      }
    }
  }
}

void determinePoint(img.Image image, int x, int y) {
  var item = image.getPixel(x, y);
  print(
      "Point:$point X:${item.current.x} Y:${item.current.y} - R:${item.current.r} G:${item.current.g} B:${item.current.b}");
  point++;
}
