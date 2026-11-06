/// `InvitationValidationResource` de docs/api/iam.md.
class InvitationValidationDto {
  final bool valid;
  final String? email;
  final String? tenantName;
  final String? roleName;

  const InvitationValidationDto({
    required this.valid,
    required this.email,
    required this.tenantName,
    required this.roleName,
  });

  factory InvitationValidationDto.fromJson(Map<String, dynamic> json) {
    return InvitationValidationDto(
      valid: json['valid'] as bool,
      email: json['email'] as String?,
      tenantName: json['tenantName'] as String?,
      roleName: json['roleName'] as String?,
    );
  }
}
