import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Vehículos con titularidad vigente del cliente (US11 E1). En línea.
class GetCustomerVehiclesUseCase {
  final ReceptionRepository repository;

  const GetCustomerVehiclesUseCase({required this.repository});

  Future<List<Vehicle>> execute(String customerId) {
    return repository.getCustomerVehicles(customerId);
  }
}
