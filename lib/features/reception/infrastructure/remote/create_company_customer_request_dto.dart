class CreateCompanyCustomerRequestDto {
  final String companyName;
  final String taxId;
  final String? email;
  final String? phone;

  const CreateCompanyCustomerRequestDto({
    required this.companyName,
    required this.taxId,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'taxId': taxId,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
  };
}
