import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';

/// Algo capturado sin red que aún no llegó al backend. [type] es el tipo de la cola
/// (`CLOCK_IN`, `UPLOAD_FILE`…) y [lastErrorMessage] el `message` del backend.
class PendingOperation {
  final String id;
  final String type;
  final PendingOperationStatus status;
  final int attempts;
  final String? lastErrorMessage;
  final DateTime createdAt;
  final String? dependsOn;

  const PendingOperation({
    required this.id,
    required this.type,
    required this.status,
    required this.attempts,
    required this.lastErrorMessage,
    required this.createdAt,
    required this.dependsOn,
  });
}
