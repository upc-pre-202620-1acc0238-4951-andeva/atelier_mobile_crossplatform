import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/notification_permission_gateway.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

Future<bool> _requestSystemPermission() async {
  final status = await handler.Permission.notification.request();
  return status.isGranted || status.isProvisional;
}

class NotificationPermissionRequester implements NotificationPermissionGateway {
  final DeviceTokenRegistrar registrar;
  final Future<bool> Function() requestSystemPermission;

  const NotificationPermissionRequester({
    required this.registrar,
    this.requestSystemPermission = _requestSystemPermission,
  });

  /// En iOS `getToken` falla sin permiso (no hay APNs): el token del login pudo no enviarse.
  @override
  Future<bool> request() async {
    final granted = await requestSystemPermission();
    if (!granted) return false;
    try {
      await registrar.registerCurrentToken();
    } on ApiException catch (e) {
      log('No se registró el token: $e', name: 'NotificationPermission');
    } on NetworkException catch (e) {
      log('No se registró el token: $e', name: 'NotificationPermission');
    }
    return true;
  }
}
