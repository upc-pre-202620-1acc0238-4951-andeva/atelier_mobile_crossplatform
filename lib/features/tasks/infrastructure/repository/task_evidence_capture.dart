import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_payload.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/sync/attach_task_evidence_handler.dart';

class TaskEvidenceCapture {
  static const target = 'TASK_EVIDENCE';

  static String evidencePrefix(String taskId) => 'TASK_EVIDENCE:$taskId:';

  static String evidenceDedupeKey(String taskId, String photoId) =>
      '${evidencePrefix(taskId)}$photoId';

  final PhotoCapture photoCapture;

  const TaskEvidenceCapture({required this.photoCapture});

  Future<void> capture({
    required String taskId,
    required String workOrderId,
    required File photo,
    required String description,
  }) async {
    await photoCapture.capture(
      photoPath: photo.path,
      target: target,
      storagePath: (tenantId, photoId) => StoragePaths.taskEvidence(
        tenantId,
        workOrderId,
        taskId,
        photoId,
      ),
      attachType: AttachTaskEvidenceHandler.type,
      attachDedupeKey: (photoId) => evidenceDedupeKey(taskId, photoId),
      attachPayload: (imageUrl) => AttachTaskEvidencePayload(
        taskId: taskId,
        imageUrl: imageUrl,
        description: description,
      ).toJson(),
    );
  }
}
