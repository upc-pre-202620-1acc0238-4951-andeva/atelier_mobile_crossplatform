import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';

class GetActiveInstallationUseCase {
  final DiagnosticsRepository repository;

  const GetActiveInstallationUseCase({required this.repository});

  /// `null` si el vehículo no tiene escáner instalado.
  Future<DeviceInstallation?> execute(String vehicleId) {
    return repository.getActiveInstallation(vehicleId);
  }
}
