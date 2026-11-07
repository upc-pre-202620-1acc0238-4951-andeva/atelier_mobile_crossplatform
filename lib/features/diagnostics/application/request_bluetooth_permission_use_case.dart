import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/bluetooth_permission_gateway.dart';

class RequestBluetoothPermissionUseCase {
  final BluetoothPermissionGateway gateway;

  const RequestBluetoothPermissionUseCase({required this.gateway});

  Future<bool> execute() => gateway.request();
}
