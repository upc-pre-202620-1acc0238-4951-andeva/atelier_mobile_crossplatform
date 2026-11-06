class TaskEvidence {
  final String id;
  final String imageUrl;
  final String? description;
  final DateTime? uploadedAt;

  const TaskEvidence({
    required this.id,
    required this.imageUrl,
    this.description,
    this.uploadedAt,
  });
}
