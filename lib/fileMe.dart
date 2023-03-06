import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

String dir = '';
RegExp exp = RegExp("");

Future<void> getGlobalPath() async {
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

List<String> getJson() {
  if (Directory(dir).existsSync() == false) {
    Directory(dir).createSync();
  }
  List<String> tempList = [];
  for (var entity in Directory(dir).listSync(recursive: false, followLinks: false)) {
    String? a = exp.firstMatch(entity.path)?[1];
    if (a != null) {
      tempList.add(a);
    }
  }
  return tempList;
}

void writeJson(String nameFile, String text) {
  try {
    String dirFile = '$dir$nameFile.json';
    File(dirFile).writeAsString(text);
  } catch (e) {
    return;
  }
}

String readJson(String nameFile) {
  try {
    String dirFile = '$dir$nameFile.json';
    return File(dirFile).readAsStringSync();
  } catch (e) {
    return "";
  }
}

void createJson(String nameFile) {
  String dirFile = '$dir$nameFile.json';
  File(dirFile).createSync();
}

bool existsJson(String nameFile) {
  return File('$dir$nameFile.json').existsSync();
}

void deleteJson(String nameFile) {
  try {
    String dirFile = '$dir$nameFile.json';
    File(dirFile).deleteSync();
  } catch (e) {
    return;
  }
}

Future<bool> resizeImage(String folder, String pathImg, int width, int height) async {
  try {
    String name;
    img.Image? image = img.decodePng( await File(pathImg).readAsBytes());

    image = img.copyResize(image!, width: width, height: height);

    Directory dirDownload;

    if (Platform.isAndroid) {
      name = pathImg.split('/').last;
      dirDownload = await Directory('$folder/ResizeRunningDots').create();
    } else {
      name = pathImg.split('\\').last;

      dirDownload = await Directory("$folder/ResizeRunningDots").create();
    }
    await File("${dirDownload.path}/$name").writeAsBytes(img.encodePng(image));

    return true;
  } catch (e) {
    return false;
  }
}
