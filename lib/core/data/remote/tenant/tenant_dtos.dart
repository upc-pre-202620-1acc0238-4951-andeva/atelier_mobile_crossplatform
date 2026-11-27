/// `TenantResource` de docs/api/iam.md (`GET/PUT /api/v1/tenants/current`).
class TenantDto {
  final String id;
  final String? name;
  final String? legalName;
  final String? taxId;
  final String? status;

  const TenantDto({required this.id, this.name, this.legalName, this.taxId, this.status});

  factory TenantDto.fromJson(Map<String, dynamic> json) {
    return TenantDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      legalName: json['legalName'] as String?,
      taxId: json['taxId'] as String?,
      status: json['status'] as String?,
    );
  }
}

/// `UpdateTenantProfileResource` de docs/api/iam.md.
class UpdateTenantProfileRequestDto {
  final String name;
  final String legalName;

  const UpdateTenantProfileRequestDto({required this.name, required this.legalName});

  Map<String, dynamic> toJson() => {'name': name, 'legalName': legalName};
}
