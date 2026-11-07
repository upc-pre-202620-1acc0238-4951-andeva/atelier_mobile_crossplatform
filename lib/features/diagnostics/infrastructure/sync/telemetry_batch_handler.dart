import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';

/// `TELEMETRY_BATCH` (06 §3): reintentar es seguro porque el backend ignora las lecturas repetidas. Un 404
/// (el vehículo no tiene escáner instalado, H16) queda `FAILED` con el `message`.
class TelemetryBatchHandler implements OperationHandler {
  static const type = 'TELEMETRY_BATCH';

  final IotApi api;

  const TelemetryBatchHandler({required this.api});

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    final body = jsonDecode(operation.payload) as Map<String, dynamic>;
    return OperationResult.from(() => api.ingestTelemetry(body));
  }
}
