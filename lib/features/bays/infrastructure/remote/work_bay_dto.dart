class WorkBayDto {
  final String id;
  final String? tenantId;
  final String? branchId;
  final String? name;
  final String? bayType;
  final String? status;
  final String? currentWorkOrderId;

  const WorkBayDto({
    required this.id,
    this.tenantId,
    this.branchId,
    this.name,
    this.bayType,
    this.status,
    this.currentWorkOrderId,
  });

  factory WorkBayDto.fromJson(Map<String, dynamic> json) {
    return WorkBayDto(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      branchId: json['branchId'] as String?,
      name: json['name'] as String?,
      bayType: json['bayType'] as String?,
      status: json['status'] as String?,
      currentWorkOrderId: json['currentWorkOrderId'] as String?,
    );
  }
}
