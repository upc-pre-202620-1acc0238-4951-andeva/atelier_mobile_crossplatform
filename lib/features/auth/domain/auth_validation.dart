/// Restricciones de los modelos de request de docs/api/iam.md. Solo evitan una llamada inútil;
/// el backend vuelve a validar todo.
abstract final class AuthValidation {
  static const passwordMin = 8;
  static const passwordMax = 64;
  static const nameMax = 100;
  static const otpLength = 6;
  static const tokenMaxLength = 512;

  static final _phone = RegExp(r'^\+?[0-9]{9,15}$');
  static final _otp = RegExp('^[0-9]{$otpLength}\$');
  static final _tld = RegExp(r'^[\p{L}\p{N}]{2,}$', unicode: true);

  /// Una sola `@`, parte local y dominio sin puntos al borde ni dobles, etiquetas sin guion al borde
  /// y un TLD alfanumérico de 2 o más.
  static bool isEmail(String value) {
    final trimmed = value.trim();
    final at = trimmed.indexOf('@');
    if (at <= 0 || at != trimmed.lastIndexOf('@')) return false;
    final local = trimmed.substring(0, at);
    final domain = trimmed.substring(at + 1);
    if (!_isDotted(local) || !_isDotted(domain)) return false;
    final parts = domain.split('.');
    if (parts.length < 2) return false;
    if (parts.any((p) => p.trim().isEmpty || p.startsWith('-') || p.endsWith('-'))) {
      return false;
    }
    return _tld.hasMatch(parts.last);
  }

  static bool _isDotted(String part) {
    return part.trim().isNotEmpty &&
        !part.startsWith('.') &&
        !part.endsWith('.') &&
        !part.contains('..');
  }

  static bool isPassword(String value) {
    return value.length >= passwordMin && value.length <= passwordMax;
  }

  static bool isName(String value) {
    return value.trim().isNotEmpty && value.length <= nameMax;
  }

  static bool isPhone(String value) => _phone.hasMatch(value);

  static bool isOtp(String value) => _otp.hasMatch(value);

  /// Acepta el token directo o el enlace completo del correo (`…/auth/accept-invitation?token=…`
  /// o `…/auth/reset-password?token=…`): de una URL se toma `token`. Con `?token=` vacío o un
  /// enlace sin `token` devuelve cadena vacía, sin lanzar. Tope de [tokenMaxLength].
  static String tokenFrom(String input) {
    final text = input.trim();
    if (text.isEmpty) return '';
    final start = text.indexOf('?');
    final query = start < 0 ? '' : text.substring(start + 1).split('#').first;
    const key = 'token=';
    for (final pair in query.split('&')) {
      if (!pair.startsWith(key)) continue;
      final raw = pair.substring(key.length);
      String decoded;
      try {
        decoded = Uri.decodeQueryComponent(raw);
      } on ArgumentError {
        decoded = raw; // `%` malformado: que responda el backend.
      } on FormatException {
        decoded = raw;
      }
      return _cap(decoded.trim());
    }
    final lower = text.toLowerCase();
    if (start >= 0 && (lower.startsWith('http://') || lower.startsWith('https://'))) {
      return '';
    }
    return _cap(text);
  }

  static String _cap(String value) {
    return value.length > tokenMaxLength ? value.substring(0, tokenMaxLength) : value;
  }
}
