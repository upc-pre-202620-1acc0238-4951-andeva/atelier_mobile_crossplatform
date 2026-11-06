import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository repository;

  const VerifyEmailUseCase({required this.repository});

  Future<String?> execute(String email, String code) =>
      repository.verifyEmail(email, code);
}
