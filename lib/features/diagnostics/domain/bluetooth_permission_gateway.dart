/// Permiso de Bluetooth para el escáner. Lo pide la UI al abrir el diagnóstico (04 §6).
abstract class BluetoothPermissionGateway {
  /// `true` si quedó concedido.
  Future<bool> request();
}
