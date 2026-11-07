import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_payloads.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_request_dtos.dart';

/// El backend es idempotente por `imageUrl` (R4): reintentar no duplica la propuesta.
class SubmitProposalHandler implements OperationHandler {
  static const type = 'SUBMIT_PROPOSAL';

  final WorkOrderApi api;

  const SubmitProposalHandler({required this.api});

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final payload = SubmitProposalPayload.fromJson(
      jsonDecode(operation.payload) as Map<String, dynamic>,
    );
    final body = SubmitProposalRequestDto(
      mechanicId: payload.mechanicId,
      description: payload.description,
      severity: payload.severity,
      imageUrl: payload.imageUrl,
      suggestedServiceId: payload.suggestedServiceId,
    );
    return OperationResult.from(
      () => api.submitProposal(payload.workOrderId, body),
    );
  }
}
