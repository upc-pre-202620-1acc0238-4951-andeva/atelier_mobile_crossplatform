/// Permiso de notificaciones. Lo pide la UI tras el login, con explicación previa (04 §2).
abstract class NotificationPermissionGateway {
  /// `true` si quedó concedido.
  Future<bool> request();
}
