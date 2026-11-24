/// `MembershipResource` de docs/api/iam.md, con lo que usan las features. Sirve para resolver el
/// nombre (`employeeName`) de un colaborador a partir de su membresía.
class MembershipDto {
  final String id;
  final String? employeeName;
  final String? email;
  final String? status;

  const MembershipDto({
    required this.id,
    this.employeeName,
    this.email,
    this.status,
  });

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    return MembershipDto(
      id: json['id'] as String,
      employeeName: json['employeeName'] as String?,
      email: json['email'] as String?,
      status: json['status'] as String?,
    );
  }
}
