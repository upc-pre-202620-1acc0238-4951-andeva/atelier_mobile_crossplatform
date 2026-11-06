import 'package:atelier_mobile_crossplatform/features/auth/domain/notification_permission_gateway.dart';

class RequestNotificationPermissionUseCase {
  final NotificationPermissionGateway gateway;

  const RequestNotificationPermissionUseCase({required this.gateway});

  Future<bool> execute() => gateway.request();
}
