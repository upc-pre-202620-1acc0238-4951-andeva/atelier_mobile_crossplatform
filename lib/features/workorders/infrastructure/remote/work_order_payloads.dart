/// Payload de `ATTACH_INTAKE_IMAGE` en la cola: el id va en la ruta.
class AttachIntakeImagePayload {
  final String workOrderId;
  final String imageUrl;
  final String? description;

  const AttachIntakeImagePayload({
    required this.workOrderId,
    required this.imageUrl,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'workOrderId': workOrderId,
    'imageUrl': imageUrl,
    if (description != null) 'description': description,
  };

  factory AttachIntakeImagePayload.fromJson(Map<String, dynamic> json) {
    return AttachIntakeImagePayload(
      workOrderId: json['workOrderId'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Payload de `SUBMIT_PROPOSAL` en la cola: el id va en la ruta.
class SubmitProposalPayload {
  final String workOrderId;
  final String mechanicId;
  final String description;
  final String severity;
  final String imageUrl;
  final String? suggestedServiceId;

  const SubmitProposalPayload({
    required this.workOrderId,
    required this.mechanicId,
    required this.description,
    required this.severity,
    required this.imageUrl,
    this.suggestedServiceId,
  });

  Map<String, dynamic> toJson() => {
    'workOrderId': workOrderId,
    'mechanicId': mechanicId,
    'description': description,
    'severity': severity,
    'imageUrl': imageUrl,
    if (suggestedServiceId != null) 'suggestedServiceId': suggestedServiceId,
  };

  factory SubmitProposalPayload.fromJson(Map<String, dynamic> json) {
    return SubmitProposalPayload(
      workOrderId: json['workOrderId'] as String,
      mechanicId: json['mechanicId'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      imageUrl: json['imageUrl'] as String,
      suggestedServiceId: json['suggestedServiceId'] as String?,
    );
  }
}
