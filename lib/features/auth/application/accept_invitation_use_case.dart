import 'package:atelier_mobile_crossplatform/features/auth/domain/accept_invitation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

/// Acepta el token o el enlace completo del correo de invitación (H1).
class AcceptInvitationUseCase {
  final AuthRepository repository;

  const AcceptInvitationUseCase({required this.repository});

  Future<void> execute(AcceptInvitation request) {
    return repository.acceptInvitation(
      request.copyWith(token: AuthValidation.tokenFrom(request.token)),
    );
  }
}
