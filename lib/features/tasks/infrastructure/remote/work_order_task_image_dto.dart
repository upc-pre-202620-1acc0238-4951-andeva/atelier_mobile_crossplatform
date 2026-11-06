class WorkOrderTaskImageDto {
  final String id;
  final String? taskId;
  final String imageUrl;
  final String? description;
  final String? uploadedAt;

  const WorkOrderTaskImageDto({
    required this.id,
    this.taskId,
    required this.imageUrl,
    this.description,
    this.uploadedAt,
  });

  factory WorkOrderTaskImageDto.fromJson(Map<String, dynamic> json) {
    return WorkOrderTaskImageDto(
      id: json['id'] as String,
      taskId: json['taskId'] as String?,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
    );
  }
}
