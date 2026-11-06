import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_payload.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_api.dart';

class AttachTaskEvidenceHandler implements OperationHandler {
  static const type = 'ATTACH_TASK_EVIDENCE';

  final TaskApi api;

  const AttachTaskEvidenceHandler({required this.api});

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final payload = AttachTaskEvidencePayload.fromJson(
      jsonDecode(operation.payload) as Map<String, dynamic>,
    );
    final body = AttachTaskEvidenceRequestDto(
      imageUrl: payload.imageUrl,
      description: payload.description,
    );
    return OperationResult.from(() => api.attachEvidence(payload.taskId, body));
  }
}
