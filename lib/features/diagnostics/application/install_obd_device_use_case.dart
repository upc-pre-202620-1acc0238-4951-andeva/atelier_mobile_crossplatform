import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_validation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

class InstallObdDeviceUseCase {
  final DiagnosticsRepository repository;

  const InstallObdDeviceUseCase({required this.repository});

  Future<DeviceInstallation> execute({
    required String deviceId,
    required String vehicleId,
    int? currentOdometerKm,
  }) async {
    if (!DiagnosticsValidation.isOdometer(currentOdometerKm)) {
      throw const InvalidDiagnosticsInputException('currentOdometerKm');
    }
    return repository.installDevice(
      deviceId: deviceId,
      vehicleId: vehicleId,
      currentOdometerKm: currentOdometerKm,
    );
  }
}
