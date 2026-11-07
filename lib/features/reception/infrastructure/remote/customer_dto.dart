/// `CustomerResource` de docs/api/crm.md.
class CustomerDto {
  final String id;
  final String? type;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? displayName;
  final String? taxId;
  final String? email;
  final String? phone;
  final String? status;

  const CustomerDto({
    required this.id,
    this.type,
    this.firstName,
    this.lastName,
    this.companyName,
    this.displayName,
    this.taxId,
    this.email,
    this.phone,
    this.status,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      id: json['id'] as String,
      type: json['type'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      companyName: json['companyName'] as String?,
      displayName: json['displayName'] as String?,
      taxId: json['taxId'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
    );
  }
}
