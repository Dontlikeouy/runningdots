import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:runningdots/assets/names.dart';
import 'package:win32/win32.dart';
import 'package:win32/winsock2.dart';
import 'package:runningdots/Bluetooth/Bluetooth.dart';

final _bthprops = DynamicLibrary.open('bthprops.cpl');

// ignore: non_constant_identifier_names
final _BluetoothAuthenticateDevice = _bthprops.lookupFunction<
    Uint32 Function(Int32 hwndParent, Int32 hRadio, Pointer<BLUETOOTH_DEVICE_INFO> pbtbi, Pointer<Utf16> pszPasskey, Uint32 ulPasskeyLength),
    int Function(int hwndParent, int hRadio, Pointer<BLUETOOTH_DEVICE_INFO> pbtbi, Pointer<Utf16> pszPasskey, int ulPasskeyLength)>('BluetoothAuthenticateDevice');

// ignore: non_constant_identifier_names
int BluetoothAuthenticateDevice(int hwndParent, int hRadio, Pointer<BLUETOOTH_DEVICE_INFO> pbtbi, Pointer<Utf16> pszPasskey, int ulPasskeyLength) =>
    _BluetoothAuthenticateDevice(hwndParent, hRadio, pbtbi, pszPasskey, ulPasskeyLength);

String _convertBluetoothAddress(BLUETOOTH_ADDRESS address) {
  final bytes = address.rgBytes;
  final buffer = StringBuffer();
  for (var idx = 0; idx < 6; idx++) {
    buffer.write(bytes[idx].toRadixString(16).padLeft(2, '0').toUpperCase());
    if (idx < 5) buffer.write(':');
  }
  return buffer.toString();
}

class BluetoothWin implements Bluetooth {
  int? connectSocket;

  @override
  Stream findBluetoothDevice() async* {
    final ReceivePort mainPort = ReceivePort();
    final ReceivePort errorPort = ReceivePort();

    StreamController streamController = StreamController();
    errorPort.listen((message) {
      streamController.addError((message as List)[0]);
    });
    mainPort.listen((message) {
      streamController.add(message);
    });

    Isolate isolate = await Isolate.spawn(_findBluetoothDevice, mainPort.sendPort, onError: errorPort.sendPort);
    streamController.onCancel = () {
      isolate.kill();
    };

    yield* streamController.stream;
  }

  @override
  Future<void> connectBluetoothDevice(BluetoothInfo bluetoothInfo) async {
    if (connectSocket != null) {
      throw (AppError.isInitializedDevice);
    }

    connectSocket = await Isolate.run(() => _connectBluetoothDevice(bluetoothInfo), debugName: "_connectBluetoothDevice");
  }

  @override
  Future<void> sendText(BluetoothInfo bluetoothInfo, String text) async {
    if (connectSocket == null) {
      throw (AppError.isNotInitializedDevice);
    }
    await Isolate.run(() => _sendText(bluetoothInfo, text, connectSocket!), debugName: "_sendText");
  }

  @override
  Future<String> readText(BluetoothInfo bluetoothInfo) async {
    if (connectSocket == null) {
      throw (AppError.isNotInitializedDevice);
    }
    return await Isolate.run(() => _readText(bluetoothInfo, connectSocket!), debugName: "_readText");
  }

  @override
  Future<void> disconnectBluetoothDevice() async {
    if (connectSocket == null) {
      throw (AppError.isNotInitializedDevice);
    }
    await Isolate.run(() => _disconnectBluetoothDevice(connectSocket!), debugName: "_disconnectBluetoothDevice");
    connectSocket = null;
  }
}

Future<void> _findBluetoothDevice(SendPort sendPort) async {
  final deviceSearchParams = calloc<BLUETOOTH_DEVICE_SEARCH_PARAMS>()
    ..ref.dwSize = sizeOf<BLUETOOTH_DEVICE_SEARCH_PARAMS>()
    ..ref.fReturnConnected = TRUE
    ..ref.fReturnAuthenticated = TRUE
    ..ref.fReturnRemembered = TRUE
    ..ref.fReturnUnknown = TRUE
    ..ref.fIssueInquiry = TRUE
    ..ref.cTimeoutMultiplier = 5;

  final info = calloc<BLUETOOTH_DEVICE_INFO>()..ref.dwSize = sizeOf<BLUETOOTH_DEVICE_INFO>();

  Set<String> macDevices = {};
  int firstDevice = 0;

  while (true) {
    firstDevice = 0;
    while ((firstDevice = firstDevice = BluetoothFindFirstDevice(deviceSearchParams, info)) == 0) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    switch (firstDevice) {
      //ERROR_INVALID_PARAMETER
      case 87:
        {
          throw BluetoothError(AppError.invalidParameter);
        }
      //ERROR_REVISION_MISMATCH
      case 1306:
        {
          throw BluetoothError(AppError.revisionMismatch);
        }
    }

    int nextDevice = 1;

    do {
      String mac = _convertBluetoothAddress(info.ref.Address);
      if (!macDevices.contains(mac)) {
        macDevices.add(mac);
        sendPort.send(BluetoothInfo(
          name: info.ref.szName,
          macAddress: _convertBluetoothAddress(info.ref.Address),
          isAuthenticated: info.ref.fAuthenticated == 0 ? false : true,
          isConnected: info.ref.fConnected == 0 ? false : true,
          connectAddress: info.ref.Address.ullLong,
        ));
      }
      await Future.delayed(const Duration(milliseconds: 100));
    } while (BluetoothFindNextDevice(firstDevice, info) == 1);

    switch (nextDevice) {
      //ERROR_NO_MORE_ITEMS
      case 258:
        {
          throw BluetoothError(AppError.noMoreItems);
        }
      //ERROR_OUTOFMEMORY
      case 14:
        {
          throw BluetoothError(AppError.outofMemory);
        }
      //ERROR_INVALID_HANDLE
      case 6:
        {
          throw BluetoothError(AppError.outofMemory);
        }
    }
  }
}

Future<int> _connectBluetoothDevice(BluetoothInfo bluetoothInfo) async {
  Pointer<BLUETOOTH_DEVICE_INFO> info = calloc<BLUETOOTH_DEVICE_INFO>()
    ..ref.dwSize = sizeOf<BLUETOOTH_DEVICE_INFO>()
    ..ref.Address.ullLong = bluetoothInfo.connectAddress ?? 0;

  int result = 0;

  //Authenticate
  if (!bluetoothInfo.isAuthenticated) {
    // result = BluetoothAuthenticateDeviceEx(0, 0, info, nullptr, 0);
    result = BluetoothAuthenticateDevice(0, 0, info, nullptr, 0);
    await Future.delayed(const Duration(seconds: 5));
  }

  switch (result) {
    //ERROR_DEVICE_NOT_CONNECTED
    case 1167:
      {
        throw BluetoothError(AppError.deviceNotConnected);
      }
    //WAIT_TIMEOUT
    case 258:
      {
        throw BluetoothError(AppError.waitTimeout);
      }
    //ERROR_GEN_FAILURE
    case 31:
      {
        throw BluetoothError(AppError.genFailure);
      }
    //ERROR_NOT_AUTHENTICATED
    case 1244:
      {
        throw BluetoothError(AppError.notAuthenticated);
      }
    //ERROR_NOT_ENOUGH_MEMORY
    case 8:
      {
        throw BluetoothError(AppError.notEnoughMemory);
      }
    //ERROR_REQ_NOT_ACCEP
    case 71:
      {
        throw BluetoothError(AppError.reqNotAccept);
      }
    //ERROR_ACCESS_DENIED
    case 5:
      {
        throw BluetoothError(AppError.accessDenied);
      }
    //ERROR_NOT_READY
    case 21:
      {
        throw BluetoothError(AppError.notReady);
      }
    //ERROR_VC_DISCONNECTED
    case 240:
      {
        throw BluetoothError(AppError.vcDisconnected);
      }
    //ERROR_CANCELLED
    case 1223:
      {
        throw BluetoothError(AppError.cancelled);
      }
    //ERROR_INVALID_PARAMETER
    case 87:
      {
        throw BluetoothError(AppError.invalidParameter);
      }
  }

  // From the socket documentation
  // ignore: constant_identifier_names
  const BTHPROTO_RFCOMM = 3;

  //Get GUID
  Pointer<Uint32> serviceInOut = calloc<Uint32>();
  result = BluetoothEnumerateInstalledServices(0, info, serviceInOut, nullptr);

  Pointer<GUID> guid = calloc<GUID>(serviceInOut.value);
  result = BluetoothEnumerateInstalledServices(0, info, serviceInOut, guid);
  //Create socket
  int connectSocket = socket(AF_BTH, SOCK_STREAM, BTHPROTO_RFCOMM);
  if (result == -1) {
    //INVALID_SOCKET
    throw BluetoothError("${AppError.notConnected} ${bluetoothInfo.name}.");
  }

  // SerialPortServiceClass_UUID '{00001101-0000-1000-8000-00805F9B34FB}'
  // RFCOMM_PROTOCOL_UUID '{00000003-0000-1000-8000-00805F9B34FB}'
  final address = calloc<SOCKADDR_BTH>()
    ..ref.addressFamily = AF_BTH
    ..ref.btAddr = bluetoothInfo.connectAddress ?? 0
    ..ref.serviceClassId.setGUID(guid.toDartGuid().toString())
    ..ref.port = 0;

  //Connection
  Pointer<SOCKADDR> name = (address as Pointer<SOCKADDR>);
  result = connect(connectSocket, name, (sizeOf<SOCKADDR_BTH>()));
  if (result == -1) {
    //ERROR_CONNECT
    throw BluetoothError("${AppError.notConnected} ${bluetoothInfo.name}.");
  }
  return connectSocket;
}

Future<void> _sendText(BluetoothInfo bluetoothInfo, String text, int connectSocket) async {
  //Send to a Bluetooth Device
  final result = send(connectSocket, text.toNativeUtf8(), text.length, 0);
  if (result == -1) {
    //SOCKET_ERROR
    throw BluetoothError(AppError.invalidSend);
  }
}

Future<String> _readText(BluetoothInfo bluetoothInfo, int connectSocket) async {
  //Receiving data from a Bluetooth Device
  Pointer<Utf8> buffer = calloc<Uint8>(256).cast();
  int result = recv(connectSocket, buffer, 256, 0);
  if (result == -1) {
    //SOCKET_ERROR
    throw BluetoothError(AppError.invalidRead);
  }
  return buffer.toDartString();
}

@override
Future<void> _disconnectBluetoothDevice(int connectSocket) async {
  final result = closesocket(connectSocket);
  if (result == -1) {
    //SOCKET_ERROR
    throw BluetoothError(AppError.failedDisconnect);
  }
}
