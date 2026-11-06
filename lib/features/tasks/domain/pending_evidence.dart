class PendingEvidence {
  final String operationId;
  final String? localFilePath;
  final String imageUrl;
  final String? description;
  final String status;
  final String? lastErrorMessage;
  final DateTime capturedAt;

  const PendingEvidence({
    required this.operationId,
    this.localFilePath,
    required this.imageUrl,
    this.description,
    required this.status,
    this.lastErrorMessage,
    required this.capturedAt,
  });
}
