import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Observa el padrón de vehículos de la caché local del taller junto a su titular.
class ObserveWorkshopVehiclesUseCase {
  final ReceptionRepository repository;

  const ObserveWorkshopVehiclesUseCase({required this.repository});

  Stream<List<VehicleWithOwner>> execute() {
    return repository.observeWorkshopVehicles();
  }
}
