import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/invalid_bay_input_exception.dart';

/// US40: saca una bahía de servicio con su motivo (`operations:bays:manage`). En línea.
class SetBayMaintenanceUseCase {
  static const reasonMax = 1000;

  final BayRepository repository;

  const SetBayMaintenanceUseCase({required this.repository});

  Future<void> execute(String bayId, String reason) {
    final trimmed = reason.trim();
    if (trimmed.isEmpty || trimmed.length > reasonMax) throw const InvalidBayInputException('reason');
    return repository.setMaintenance(bayId, trimmed);
  }
}
