import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';

class RetryPendingOperationUseCase {
  final PendingOperationRepository repository;

  const RetryPendingOperationUseCase({required this.repository});

  Future<bool> execute(String id) => repository.retry(id);
}
