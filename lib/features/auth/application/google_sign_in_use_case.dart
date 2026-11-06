import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/google_id_token_provider.dart';

enum GoogleSignInOutcome { signedIn, cancelled, notConfigured, providerFailed }

class GoogleSignInUseCase {
  final GoogleIdTokenProvider provider;
  final AuthRepository repository;

  const GoogleSignInUseCase({required this.provider, required this.repository});

  /// El resultado solo describe a Google. Los errores del backend suben como en `SignInUseCase`.
  Future<GoogleSignInOutcome> execute() async {
    switch (await provider.request()) {
      case GoogleIdToken(:final value):
        await repository.signInWithGoogle(value);
        return GoogleSignInOutcome.signedIn;
      case GoogleIdTokenCancelled():
        return GoogleSignInOutcome.cancelled;
      case GoogleIdTokenNotConfigured():
        return GoogleSignInOutcome.notConfigured;
      case GoogleIdTokenFailed():
        return GoogleSignInOutcome.providerFailed;
    }
  }
}
