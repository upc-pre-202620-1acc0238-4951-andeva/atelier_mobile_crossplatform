import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_validation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

class UninstallObdDeviceUseCase {
  final DiagnosticsRepository repository;

  const UninstallObdDeviceUseCase({required this.repository});

  Future<DeviceInstallation> execute(
    String installationId, {
    int? finalOdometerKm,
  }) async {
    if (!DiagnosticsValidation.isOdometer(finalOdometerKm)) {
      throw const InvalidDiagnosticsInputException('finalOdometerKm');
    }
    return repository.uninstallDevice(
      installationId,
      finalOdometerKm: finalOdometerKm,
    );
  }
}
