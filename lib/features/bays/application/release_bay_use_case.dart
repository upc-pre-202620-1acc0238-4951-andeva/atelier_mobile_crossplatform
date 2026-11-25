import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';

/// US40: libera la bahía que ocupa una orden (`operations:bays:reassign`). En línea.
class ReleaseBayUseCase {
  final BayRepository repository;

  const ReleaseBayUseCase({required this.repository});

  Future<void> execute(String workOrderId) => repository.releaseBay(workOrderId);
}
