import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

/// Acepta el token o el enlace completo del correo de restablecimiento (H1).
class ResetPasswordUseCase {
  final AuthRepository repository;

  const ResetPasswordUseCase({required this.repository});

  Future<String?> execute(String token, String newPassword) {
    return repository.resetPassword(
      AuthValidation.tokenFrom(token),
      newPassword,
    );
  }
}
