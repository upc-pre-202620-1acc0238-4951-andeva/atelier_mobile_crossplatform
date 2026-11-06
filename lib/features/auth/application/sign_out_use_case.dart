import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase({required this.repository});

  Future<void> execute() => repository.signOut();
}
