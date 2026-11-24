/// Permiso de notificaciones. Lo pide la UI tras el login, con explicación previa (04 §2).
abstract class NotificationPermissionGateway {
  /// `true` si quedó concedido. Si el sistema ya no deja preguntar (denegado para siempre), abre los
  /// ajustes de notificaciones de la app y devuelve `false`.
  Future<bool> request();

  /// `true` si ya está concedido, sin preguntar.
  Future<bool> isGranted();
}
