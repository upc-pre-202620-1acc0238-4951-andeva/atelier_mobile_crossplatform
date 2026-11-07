import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Alta del vehículo con su titular (US11 E2, US44 E2). La placa se envía normalizada. En línea.
class RegisterVehicleUseCase {
  final ReceptionRepository repository;

  const RegisterVehicleUseCase({required this.repository});

  Future<Vehicle> execute(NewVehicle vehicle) async {
    final String? invalid;
    if (!ReceptionValidation.isPlate(vehicle.plate)) {
      invalid = 'plate';
    } else if (!ReceptionValidation.isBrandOrModel(vehicle.brand)) {
      invalid = 'brand';
    } else if (!ReceptionValidation.isBrandOrModel(vehicle.model)) {
      invalid = 'model';
    } else if (!ReceptionValidation.isOptionalVin(vehicle.vin)) {
      invalid = 'vin';
    } else if (!ReceptionValidation.isOptionalYear(vehicle.year)) {
      invalid = 'year';
    } else {
      invalid = null;
    }
    if (invalid != null) throw InvalidReceptionInputException(invalid);
    return repository.registerVehicle(vehicle);
  }
}
