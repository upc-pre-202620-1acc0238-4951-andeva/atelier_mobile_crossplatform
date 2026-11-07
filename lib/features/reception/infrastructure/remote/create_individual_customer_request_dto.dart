class CreateIndividualCustomerRequestDto {
  final String firstName;
  final String lastName;
  final String taxId;
  final String? email;
  final String? phone;

  const CreateIndividualCustomerRequestDto({
    required this.firstName,
    required this.lastName,
    required this.taxId,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'taxId': taxId,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
  };
}
