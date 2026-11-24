/// `UpdateCustomerContactResource` de docs/api/crm.md.
class UpdateCustomerContactRequestDto {
  final String? email;
  final String? phone;

  const UpdateCustomerContactRequestDto({this.email, this.phone});

  Map<String, dynamic> toJson() => {
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
  };
}
