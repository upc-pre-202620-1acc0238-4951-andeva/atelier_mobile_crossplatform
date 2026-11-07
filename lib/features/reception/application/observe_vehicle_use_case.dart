import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

class ObserveVehicleUseCase {
  final ReceptionRepository repository;

  const ObserveVehicleUseCase({required this.repository});

  Stream<Vehicle?> execute(String id) => repository.observeVehicle(id);
}
