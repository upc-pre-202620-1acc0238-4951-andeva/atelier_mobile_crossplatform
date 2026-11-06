import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';

class ObservePendingOperationsUseCase {
  final PendingOperationRepository repository;

  const ObservePendingOperationsUseCase({required this.repository});

  Stream<List<PendingOperation>> execute() => repository.watchAll();
}
