import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/invalid_task_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_validation.dart';

/// Foto de desmontaje o montaje (US28 E1/E2). Funciona sin red por la cola.
class AttachTaskEvidenceUseCase {
  final TaskRepository repository;

  const AttachTaskEvidenceUseCase({required this.repository});

  Future<void> execute(
    TaskId id,
    String workOrderId,
    File photo,
    EvidenceKind kind, {
    String? note,
  }) {
    final description = kind.describe(note);
    if (!TaskValidation.isEvidenceDescription(description)) {
      throw const InvalidTaskInputException('description');
    }
    return repository.attachEvidence(id, workOrderId, photo, description);
  }
}
