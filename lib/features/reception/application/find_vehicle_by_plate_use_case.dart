import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Buscar la unidad por placa (US11 E1). `null` = primer ingreso (US11 E2). Sin red responde con la
/// caché si la placa ya se vio.
class FindVehicleByPlateUseCase {
  final ReceptionRepository repository;

  const FindVehicleByPlateUseCase({required this.repository});

  Future<VehicleWithOwner?> execute(String plate) async {
    if (!ReceptionValidation.isPlate(plate)) {
      throw const InvalidReceptionInputException('plate');
    }
    return repository.findVehicleByPlate(plate);
  }
}
