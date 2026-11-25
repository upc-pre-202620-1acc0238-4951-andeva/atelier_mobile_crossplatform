import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

/// US40: devuelve a servicio una bahía en mantenimiento (`operations:bays:manage`). En línea.
class RestoreBayUseCase {
  final BayRepository repository;

  const RestoreBayUseCase({required this.repository});

  Future<void> execute(String bayId) => repository.restoreBay(bayId);
}
