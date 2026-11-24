import 'package:atelier_mobile_crossplatform/features/auth/domain/notification_permission_gateway.dart';

/// Si el teléfono deja mostrar notificaciones (banner "Notificaciones desactivadas" de la bandeja).
class IsNotificationPermissionGrantedUseCase {
  final NotificationPermissionGateway gateway;

  const IsNotificationPermissionGrantedUseCase({required this.gateway});

  Future<bool> execute() => gateway.isGranted();
}
