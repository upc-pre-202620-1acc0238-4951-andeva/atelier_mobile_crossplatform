/// Restricciones de los modelos de request de docs/api/iam.md. Solo evitan una llamada inútil;
/// el backend vuelve a validar todo.
abstract final class AuthValidation {
  static const passwordMin = 8;
  static const passwordMax = 64;
  static const nameMax = 100;
  static const otpLength = 6;

  static final _phone = RegExp(r'^\+?[0-9]{9,15}$');
  static final _otp = RegExp('^[0-9]{$otpLength}\$');

  static bool isEmail(String value) {
    final at = value.indexOf('@');
    return at >= 0 && value.substring(at + 1).contains('.');
  }

  static bool isPassword(String value) {
    return value.length >= passwordMin && value.length <= passwordMax;
  }

  static bool isName(String value) {
    return value.trim().isNotEmpty && value.length <= nameMax;
  }

  static bool isPhone(String value) => _phone.hasMatch(value);

  static bool isOtp(String value) => _otp.hasMatch(value);

  /// Sin deep link (H1), el colaborador pega el token o el enlace completo del correo
  /// (`…/auth/accept-invitation?token=…`): de una URL se toma `token`.
  static String tokenFrom(String input) {
    final text = input.trim();
    final start = text.indexOf('?');
    if (start < 0) return text;
    final query = text.substring(start + 1).split('#').first;
    const key = 'token=';
    for (final pair in query.split('&')) {
      if (!pair.startsWith(key)) continue;
      final raw = pair.substring(key.length);
      try {
        return Uri.decodeQueryComponent(raw);
      } on ArgumentError {
        return raw; // `%` malformado: que responda el backend.
      } on FormatException {
        return raw;
      }
    }
    return text;
  }
}
