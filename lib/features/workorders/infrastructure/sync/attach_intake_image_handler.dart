import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_payloads.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_request_dtos.dart';

/// El backend es idempotente por `imageUrl` (R4): reintentar no duplica la foto.
class AttachIntakeImageHandler implements OperationHandler {
  static const type = 'ATTACH_INTAKE_IMAGE';

  final WorkOrderApi api;

  const AttachIntakeImageHandler({required this.api});

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final payload = AttachIntakeImagePayload.fromJson(
      jsonDecode(operation.payload) as Map<String, dynamic>,
    );
    final body = AttachImageRequestDto(
      imageUrl: payload.imageUrl,
      description: payload.description,
    );
    return OperationResult.from(
      () => api.attachIntakeImage(payload.workOrderId, body),
    );
  }
}
