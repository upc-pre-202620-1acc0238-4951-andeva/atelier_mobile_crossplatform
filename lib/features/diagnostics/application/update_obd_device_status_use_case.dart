import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

/// Cambia el estado operativo de un escáner OBD-II (`iot:devices:register`, en línea).
class UpdateObdDeviceStatusUseCase {
  final DiagnosticsRepository repository;

  const UpdateObdDeviceStatusUseCase({required this.repository});

  Future<ObdDevice> execute(String deviceId, DeviceStatus status) {
    return repository.updateDeviceStatus(deviceId, status);
  }
}
