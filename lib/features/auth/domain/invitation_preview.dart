/// Resultado de `GET /invitations/validate`: a qué taller y con qué rol invitan.
class InvitationPreview {
  final String email;
  final String tenantName;
  final String roleName;

  const InvitationPreview({
    required this.email,
    required this.tenantName,
    required this.roleName,
  });
}
