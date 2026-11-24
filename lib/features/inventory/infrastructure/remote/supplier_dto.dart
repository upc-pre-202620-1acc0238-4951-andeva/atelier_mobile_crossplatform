/// `SupplierResource` de docs/api/inventory.md.
class SupplierDto {
  final String id;
  final String? tenantId;
  final String? businessName;
  final String? taxId;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final bool? active;

  const SupplierDto({
    required this.id,
    this.tenantId,
    this.businessName,
    this.taxId,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.active,
  });

  factory SupplierDto.fromJson(Map<String, dynamic> json) {
    return SupplierDto(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String?,
      businessName: json['businessName'] as String?,
      taxId: json['taxId'] as String?,
      contactName: json['contactName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      active: json['active'] as bool?,
    );
  }
}
