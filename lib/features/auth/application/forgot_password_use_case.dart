import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  const ForgotPasswordUseCase({required this.repository});

  Future<String?> execute(String email) => repository.forgotPassword(email);
}
