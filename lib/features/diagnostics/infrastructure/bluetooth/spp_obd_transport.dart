import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_transport.dart';
import 'package:flutter/services.dart';

/// Bluetooth clásico por el puente Kotlin (`ObdSppBridge.kt`). **Solo Android:** iOS no da acceso a SPP sin
/// MFi (H40). Los canales solo existen en el motor de la UI, nunca en el del worker.
class SppObdTransport implements ObdTransport {
  static const methodChannelName = 'com.andeva.atelier.mobile/obd_spp';
  static const eventChannelName = 'com.andeva.atelier.mobile/obd_spp/incoming';

  static const _methods = MethodChannel(methodChannelName);
  static const _events = EventChannel(eventChannelName);

  const SppObdTransport();

  @override
  Stream<String> get incoming {
    return _events.receiveBroadcastStream().map((chunk) => chunk as String);
  }

  /// Emparejados en los ajustes de Android. Lanza las excepciones de Bluetooth del dominio.
  Future<List<ObdAdapter>> bondedAdapters() async {
    final List<Object?>? devices;
    try {
      devices = await _methods.invokeListMethod<Object?>('bondedDevices');
    } on PlatformException catch (e) {
      throw _toDomain(e);
    }
    return [
      for (final device in devices ?? const <Object?>[])
        _adapter((device! as Map).cast<String, String>()),
    ];
  }

  ObdAdapter _adapter(Map<String, String> device) {
    return ObdAdapter(
      name: device['name'] ?? '',
      address: device['address'] ?? '',
      kind: device['type'] == 'ble' ? ObdAdapterKind.ble : ObdAdapterKind.classic,
    );
  }

  @override
  Future<void> connect(String address) async {
    try {
      await _methods.invokeMethod<void>('connect', {'address': address});
    } on PlatformException catch (e) {
      throw _toDomain(e);
    }
  }

  @override
  Future<void> send(String command) async {
    try {
      await _methods.invokeMethod<void>('send', {'command': '$command\r'});
    } on PlatformException {
      throw const ObdConnectionLostException();
    }
  }

  @override
  Future<void> disconnect() async {
    await _methods.invokeMethod<void>('disconnect');
  }

  static Exception _toDomain(PlatformException error) {
    return switch (error.code) {
      'PERMISSION_DENIED' => const BluetoothPermissionDeniedException(),
      'BLUETOOTH_DISABLED' => const BluetoothDisabledException(),
      'INVALID_ADDRESS' => const InvalidDiagnosticsInputException('address'),
      _ => const ObdAdapterUnreachableException(),
    };
  }
}
