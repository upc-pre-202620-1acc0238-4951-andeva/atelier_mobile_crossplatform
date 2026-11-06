import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invitation_preview.dart';

/// Acepta el token o el enlace completo del correo de invitación (H1).
class ValidateInvitationUseCase {
  final AuthRepository repository;

  const ValidateInvitationUseCase({required this.repository});

  Future<InvitationPreview> execute(String token) {
    return repository.validateInvitation(AuthValidation.tokenFrom(token));
  }
}
