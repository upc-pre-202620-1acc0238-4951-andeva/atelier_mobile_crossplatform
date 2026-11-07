/// `taxId` obligatorio (docs/03-traceability.md US44 E1).
class AffiliateCustomerRequestDto {
  final String email;
  final String taxId;
  final String? phone;

  const AffiliateCustomerRequestDto({
    required this.email,
    required this.taxId,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'taxId': taxId,
    if (phone != null) 'phone': phone,
  };
}
