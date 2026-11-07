import 'dart:developer';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_foreground_controller.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart' as handler;

/// Foreground service `connectedDevice` (04 §4). Sin `callback`: la sesión sigue en el motor de la UI, donde
/// están los plugins de Bluetooth, y el servicio solo mantiene vivo el proceso. No protege a la Activity: si se
/// destruye, la sesión muere con su motor y lo guardado sale en el siguiente `startStreaming`.
/// iOS no lo necesita: usa `bluetooth-central`.
class ObdSessionServiceController implements ObdForegroundController {
  static const _serviceId = 8001;
  static const _channelId = 'diagnostics';

  final String channelName;
  final String notificationTitle;

  const ObdSessionServiceController({
    required this.channelName,
    required this.notificationTitle,
  });

  /// Desde API 34 el tipo `connectedDevice` exige `BLUETOOTH_CONNECT` concedido: sin él no se arranca.
  @override
  Future<void> start() async {
    if (!Platform.isAndroid) return;
    try {
      if (!await handler.Permission.bluetoothConnect.isGranted) return;
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: _channelId,
          channelName: channelName,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.nothing(),
          allowAutoRestart: false,
        ),
      );
      if (await FlutterForegroundTask.isRunningService) return;
      final result = await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: const [ForegroundServiceTypes.connectedDevice],
        notificationTitle: notificationTitle,
        notificationText: '',
      );
      if (result is ServiceRequestFailure) {
        log('No arrancó: ${result.error}', name: 'ObdSessionServiceController');
      }
    } on Exception catch (e) {
      log('No arrancó: $e', name: 'ObdSessionServiceController');
    }
  }

  @override
  Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await FlutterForegroundTask.stopService();
    } on Exception catch (e) {
      log('No se detuvo: $e', name: 'ObdSessionServiceController');
    }
  }
}
