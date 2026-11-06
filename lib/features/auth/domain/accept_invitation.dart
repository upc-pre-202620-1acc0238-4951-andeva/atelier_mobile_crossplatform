/// Datos para `POST /invitations/accept` (`AcceptInvitationResource`).
class AcceptInvitation {
  final String token;
  final String firstName;
  final String lastName;
  final String password;
  final String? phone;

  const AcceptInvitation({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.phone,
  });

  AcceptInvitation copyWith({String? token}) {
    return AcceptInvitation(
      token: token ?? this.token,
      firstName: firstName,
      lastName: lastName,
      password: password,
      phone: phone,
    );
  }
}
