import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:runningdots/Bluetooth/Bluetooth.dart';
import 'package:runningdots/assets/names.dart';

class BluetoothAndroid implements Bluetooth {
  bool cancelToken = true;

  @override
  Stream findBluetoothDevice() async* {
    // if (await Permission.bluetooth.request().isGranted && await Permission.bluetoothConnect.request().isGranted && await Permission.bluetoothScan.request().isGranted) {
    //   if (await FlutterBluetoothSerial.instance.isEnabled == false && await FlutterBluetoothSerial.instance.requestEnable() == false) {
    //     throw (AppError.notConnectedBluetooth);
    //   }
    // } else {
    //   throw (AppError.notBluetoothPermissions);
    // }
    bool cancelToken = true;
    Set<String> macDevices = {};

    StreamController streamController = StreamController();

    streamController.onCancel = () {
      cancelToken = false;
      FlutterBluetoothSerial.instance.cancelDiscovery();
    };

    Future(() async {
      for (var element in await FlutterBluetoothSerial.instance.getBondedDevices()) {
        if (element.name != null && cancelToken) {
          macDevices.add(element.address);
          streamController.add(BluetoothInfo(name: element.name!, macAddress: element.address, isAuthenticated: element.isBonded, isConnected: element.isConnected));
        }
      }
    }).catchError((error) {
      streamController.addError(error);
    });

    Future(() async {
      while (cancelToken) {
        await for (var element in FlutterBluetoothSerial.instance.startDiscovery()) {
          if (element.device.name != null && !macDevices.contains(element.device.address)) {
            macDevices.add(element.device.address);
            streamController.add(BluetoothInfo(
              name: element.device.name!,
              macAddress: element.device.address,
              isAuthenticated: element.device.isBonded,
              isConnected: element.device.isConnected,
            ));
          }
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }).catchError((error) {
      streamController.addError(error);
    });

    yield* streamController.stream;
  }

  BluetoothConnection? bluetoothConnection;
  @override
  Future<void> connectBluetoothDevice(BluetoothInfo bluetoothInfo) async {
    if (bluetoothConnection != null) {
      throw (AppError.isInitializedDevice);
    }
    bluetoothConnection = await BluetoothConnection.toAddress(bluetoothInfo.macAddress);
  }

  @override
  Future<void> sendText(BluetoothInfo bluetoothInfo, String text) async {
    if (bluetoothConnection == null) {
      throw (AppError.isNotInitializedDevice);
    }
    bluetoothConnection!.output.add(latin1.encode(text));
  }

  @override
  Future<String> readText(BluetoothInfo bluetoothInfo) async {
    if (bluetoothConnection == null) {
      throw (AppError.isNotInitializedDevice);
    }
    await for (var text in bluetoothConnection!.input!) {
      return latin1.decode(text);
    }
    return "";
  }

  @override
  Future<void> disconnectBluetoothDevice() async {
    if (bluetoothConnection == null) {
      throw (AppError.isNotInitializedDevice);
    }
    bluetoothConnection!.close();
    bluetoothConnection = null;
  }
}
