import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';

/// Foto de recepción en cola (US13, 06 §6). [localFilePath] existe hasta que se sube; luego vale
/// [imageUrl].
class PendingIntakePhoto {
  final String operationId;
  final String? localFilePath;
  final String imageUrl;
  final String? description;
  final String status;
  final String? lastErrorMessage;
  final DateTime capturedAt;

  const PendingIntakePhoto({
    required this.operationId,
    this.localFilePath,
    required this.imageUrl,
    this.description,
    required this.status,
    this.lastErrorMessage,
    required this.capturedAt,
  });
}

/// Propuesta capturada que espera enviarse con su foto (US14).
class PendingProposal {
  final String operationId;
  final String? localFilePath;
  final String imageUrl;
  final String description;
  final ProposalSeverity? severity;
  final String status;
  final String? lastErrorMessage;
  final DateTime capturedAt;

  const PendingProposal({
    required this.operationId,
    this.localFilePath,
    required this.imageUrl,
    required this.description,
    this.severity,
    required this.status,
    this.lastErrorMessage,
    required this.capturedAt,
  });
}
