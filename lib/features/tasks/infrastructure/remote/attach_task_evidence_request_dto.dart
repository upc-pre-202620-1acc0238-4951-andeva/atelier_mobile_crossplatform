class AttachTaskEvidenceRequestDto {
  final String imageUrl;
  final String? description;

  const AttachTaskEvidenceRequestDto({
    required this.imageUrl,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'imageUrl': imageUrl,
        if (description != null) 'description': description,
      };
}
