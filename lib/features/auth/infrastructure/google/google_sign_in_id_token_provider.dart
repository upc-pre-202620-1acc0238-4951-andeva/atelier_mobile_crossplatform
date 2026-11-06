import 'dart:developer';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/auth/domain/google_id_token_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// `idToken` de Google (docs/04-mobile-integration.md §1): el `serverClientId` es el Web client ID,
/// el mismo que acepta el backend. En iOS está sin comprobar (falta una Mac y el URL scheme).
class GoogleSignInIdTokenProvider implements GoogleIdTokenProvider {
  final String webClientId;
  final String iosClientId;

  Future<void>? _initialized; // La API 7 exige inicializar una sola vez.

  GoogleSignInIdTokenProvider({
    required this.webClientId,
    required this.iosClientId,
  });

  @override
  Future<GoogleIdTokenResult> request() async {
    if (webClientId.isEmpty || (Platform.isIOS && iosClientId.isEmpty)) {
      return const GoogleIdTokenNotConfigured();
    }
    try {
      await (_initialized ??= GoogleSignIn.instance.initialize(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
      ));
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      return idToken == null
          ? const GoogleIdTokenFailed()
          : GoogleIdToken(idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const GoogleIdTokenCancelled();
      }
      log('Google rechazó el acceso: $e', name: 'GoogleSignIn');
      return const GoogleIdTokenFailed();
    }
  }
}
