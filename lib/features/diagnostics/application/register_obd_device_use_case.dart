import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

/// Da de alta un escáner OBD-II en el taller (`iot:devices:register`, en línea). El backend solo admite
/// `BLUETOOTH_BLE` en `ConnectionType` aunque el ELM327 físico hable Bluetooth clásico (H18).
class RegisterObdDeviceUseCase {
  static const allowedConnectionType = 'BLUETOOTH_BLE';

  final DiagnosticsRepository repository;

  const RegisterObdDeviceUseCase({required this.repository});

  Future<ObdDevice> execute({
    required String deviceIdentifier,
    String connectionType = allowedConnectionType,
    String? hardwareModel,
    String? firmwareVersion,
  }) async {
    final identifier = deviceIdentifier.trim();
    final type = connectionType.trim();
    if (identifier.isEmpty) {
      throw const InvalidDiagnosticsInputException('deviceIdentifier');
    }
    if (type != allowedConnectionType) {
      throw const InvalidDiagnosticsInputException('connectionType');
    }
    return repository.registerDevice(
      deviceIdentifier: identifier,
      connectionType: type,
      hardwareModel: hardwareModel,
      firmwareVersion: firmwareVersion,
    );
  }
}
