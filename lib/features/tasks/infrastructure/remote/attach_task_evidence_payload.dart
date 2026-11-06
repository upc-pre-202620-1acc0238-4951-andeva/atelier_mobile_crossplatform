class AttachTaskEvidencePayload {
  final String taskId;
  final String imageUrl;
  final String? description;

  const AttachTaskEvidencePayload({
    required this.taskId,
    required this.imageUrl,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'imageUrl': imageUrl,
        if (description != null) 'description': description,
      };

  factory AttachTaskEvidencePayload.fromJson(Map<String, dynamic> json) {
    return AttachTaskEvidencePayload(
      taskId: json['taskId'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
    );
  }
}
