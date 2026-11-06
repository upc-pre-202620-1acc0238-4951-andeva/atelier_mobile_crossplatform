/// Obtiene el `idToken` de Google. El plugin vive en infraestructura.
abstract class GoogleIdTokenProvider {
  Future<GoogleIdTokenResult> request();
}

sealed class GoogleIdTokenResult {
  const GoogleIdTokenResult();
}

class GoogleIdToken extends GoogleIdTokenResult {
  final String value;

  const GoogleIdToken(this.value);
}

class GoogleIdTokenCancelled extends GoogleIdTokenResult {
  const GoogleIdTokenCancelled();
}

class GoogleIdTokenNotConfigured extends GoogleIdTokenResult {
  const GoogleIdTokenNotConfigured();
}

class GoogleIdTokenFailed extends GoogleIdTokenResult {
  const GoogleIdTokenFailed();
}
