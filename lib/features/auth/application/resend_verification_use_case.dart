import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class ResendVerificationUseCase {
  final AuthRepository repository;

  const ResendVerificationUseCase({required this.repository});

  Future<String?> execute(String email) => repository.resendVerification(email);
}
