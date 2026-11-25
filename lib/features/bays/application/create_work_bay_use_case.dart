import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/invalid_bay_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';

/// US40: registra una bahía física en la sede (`operations:bays:manage`). En línea.
class CreateWorkBayUseCase {
  static const nameMax = 100;

  final BayRepository repository;

  const CreateWorkBayUseCase({required this.repository});

  Future<void> execute(String name, BayType type) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > nameMax) throw const InvalidBayInputException('name');
    return repository.createBay(trimmed, type);
  }
}
