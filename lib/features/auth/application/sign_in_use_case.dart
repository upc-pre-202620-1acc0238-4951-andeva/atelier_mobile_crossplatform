import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase({required this.repository});

  Future<void> execute(String email, String password) =>
      repository.signIn(email, password);
}
