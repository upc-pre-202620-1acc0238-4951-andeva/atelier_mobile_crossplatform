import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/bluetooth_permission_gateway.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Android pide conectar y escanear; basta conectar para usar un adaptador emparejado. En Android 11 o menor el
/// sistema los da por concedidos. iOS tiene un único permiso.
class PermissionHandlerBluetoothGateway implements BluetoothPermissionGateway {
  const PermissionHandlerBluetoothGateway();

  @override
  Future<bool> request() async {
    if (Platform.isIOS) {
      return (await handler.Permission.bluetooth.request()).isGranted;
    }
    final statuses = await [
      handler.Permission.bluetoothConnect,
      handler.Permission.bluetoothScan,
    ].request();
    return statuses[handler.Permission.bluetoothConnect]?.isGranted ?? false;
  }
}
