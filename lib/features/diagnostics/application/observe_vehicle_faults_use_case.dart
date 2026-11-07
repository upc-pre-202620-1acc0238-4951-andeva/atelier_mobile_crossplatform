import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';

class ObserveVehicleFaultsUseCase {
  final DiagnosticsRepository repository;

  const ObserveVehicleFaultsUseCase({required this.repository});

  Stream<List<VehicleFault>> execute(String vehicleId) {
    return repository.watchActiveFaults(vehicleId);
  }
}
