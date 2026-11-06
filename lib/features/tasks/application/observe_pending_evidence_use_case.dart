import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Las fotos en cola de la tarea observadas en tiempo real.
class ObservePendingEvidenceUseCase {
  final TaskRepository repository;

  const ObservePendingEvidenceUseCase({required this.repository});

  Stream<List<PendingEvidence>> execute(TaskId id) =>
      repository.observePendingEvidence(id);
}
