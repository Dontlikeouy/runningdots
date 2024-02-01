class AppName {
  static const String title = "RunningDots";
}

class AppPage {
  static const String visualizer = "Визуализатор";
}

class AppTextDefault {
  static const String pathSelectedFile = "Путь..";
  static const String titleChooseImage = "Изображение: APNG ( .png ).";
}

class AppError {
  //----------------             BLUETOOTH             ----------------//

  static const String invalidParameter = "Параметр pbtsp или pbtdi имеет значение NULL.";
  static const String revisionMismatch = "Структура, на которую указывает pbtsp или pbtdi , имеет неправильный размер.";
  static const String invalidHandle = "Дескриптор недействителен.";
  static const String noMoreItems = "Больше устройств нет.";
  static const String outofMemory = "Недостаточно памяти.";
  static const String deviceNotConnected = "Устройство не подключено.";
  static const String waitTimeout = "Время ожидания операции истекло.";
  static const String genFailure = "Устройство, подключенное к системе, не работает.";
  static const String notAuthenticated = "Запрашиваемая операция не была выполнена, так как пользователь не прошел проверку подлинности.";
  static const String notEnoughMemory = "Недостаточно памяти.";
  static const String reqNotAccept = "К удаленному компьютеру невозможно установить больше подключений.";
  static const String accessDenied = "Отказано в доступе.";
  static const String notReady = "Устройство не готово.";
  static const String vcDisconnected = "Сеанс был отменен.";
  static const String isNotInitializedDevice = "Устройство не подключено.";
  static const String isInitializedDevice = "Устройство уже было подключено";
  static const String notConnected = "Не удалось подключится к устройству";
  static const String cancelled = "Операция была отменена пользователем.";
  static const String notAvailableBluetooth = "Bluetooth недоступен.";
  static const String socketNotInitialized = "Socket не инициализирован.";
  static const String invalidSend = "Не удалось отправить отправляет данные на устройство.";
  static const String invalidRead = "Не удалось отправить получить данные из устройства.";
  static const String dataNotRetrieved = "Не удалось получить данные от устройства.";
  static const String failedDisconnect = "Не удалось отключить устройство.";
  static const String notConnectedBluetooth = "Необходимо включить Bluetooth";
  static const String notBluetoothPermissions = "Нет необходимых разрешений для взаимодействия с Bluetooth";
}

class BluetoothError implements Exception {
  final String message;
  BluetoothError(this.message);
  @override
  String toString() => "BluetoothError: $message";
}
