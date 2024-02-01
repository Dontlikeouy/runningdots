import 'dart:async';
import 'dart:io';

import 'package:runningdots/assets/names.dart';

import 'BluetoothAndroid.dart';
import 'BluetoothWin.dart';

class BluetoothInfo {
  String name;
  String macAddress;
  bool isAuthenticated;
  bool isConnected ;

  //--- ONLY WINDOWS ---//
  int? connectAddress;

  BluetoothInfo({
    required this.name,
    required this.macAddress,
    required this.isAuthenticated,
    required this.isConnected,
    this.connectAddress,
  });
}

interface class Bluetooth {
  static Bluetooth create() {
    if (Platform.isWindows) {
      return BluetoothWin();
    } else if (Platform.isAndroid) {
      return BluetoothAndroid();
    }
    throw ('No supported platform');
  }

  Stream findBluetoothDevice() async* {}
  Future<void> connectBluetoothDevice(BluetoothInfo bluetoothInfo) async {}
  Future<void> sendText(BluetoothInfo bluetoothInfo, String text) async {}
  Future<String> readText(BluetoothInfo bluetoothInfo) async {
    return "";
  }

  Future<void> disconnectBluetoothDevice() async {}
}
