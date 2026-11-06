import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';

class ObservePendingOperationCountUseCase {
  final PendingOperationRepository repository;

  const ObservePendingOperationCountUseCase({required this.repository});

  Stream<int> execute() => repository.watchCount();
}
