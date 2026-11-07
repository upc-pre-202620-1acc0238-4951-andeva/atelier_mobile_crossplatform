import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';

class RefreshVehicleFaultsUseCase {
  final DiagnosticsRepository repository;

  const RefreshVehicleFaultsUseCase({required this.repository});

  Future<void> execute(String vehicleId) => repository.refreshActiveFaults(vehicleId);
}
