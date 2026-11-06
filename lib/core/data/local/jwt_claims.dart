import 'dart:convert';

/// Lee claims del JWT sin verificar la firma (eso lo hace el backend).
class JwtClaims {
  /// `exp` del token en epoch ms, o `null` si el token no se puede leer.
  static int? expiresAtMillis(String token) {
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(token.split('.')[1])),
      );
      final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'] as num?;
      return exp == null ? null : exp.toInt() * 1000;
    } on FormatException {
      return null;
    } on RangeError {
      return null; // Sin las tres partes del JWT.
    } on TypeError {
      return null; // El payload no es un objeto, o `exp` no es un número.
    }
  }
}
