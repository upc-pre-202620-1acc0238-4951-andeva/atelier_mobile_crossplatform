import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';

class DiscardPendingOperationUseCase {
  final PendingOperationRepository repository;

  const DiscardPendingOperationUseCase({required this.repository});

  Future<bool> execute(String id) => repository.discard(id);
}
