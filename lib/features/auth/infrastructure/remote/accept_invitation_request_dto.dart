class AcceptInvitationRequestDto {
  final String token;
  final String firstName;
  final String lastName;
  final String password;
  final String? phone;

  const AcceptInvitationRequestDto({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'firstName': firstName,
    'lastName': lastName,
    'password': password,
    if (phone != null) 'phone': phone,
  };
}
