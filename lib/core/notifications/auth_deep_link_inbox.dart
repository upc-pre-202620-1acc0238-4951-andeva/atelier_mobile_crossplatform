import 'package:flutter/foundation.dart';

/// Enlace web entrante de autenticación. Solo aceptar invitación (US01): el de restablecer
/// contraseña (US05) no se porta.
sealed class AuthDeepLink {
  final String token;

  const AuthDeepLink(this.token);

  @override
  bool operator ==(Object other) =>
      other is AuthDeepLink && other.runtimeType == runtimeType && other.token == token;

  @override
  int get hashCode => Object.hash(runtimeType, token);
}

final class AcceptInvitationDeepLink extends AuthDeepLink {
  const AcceptInvitationDeepLink(super.token);
}

/// Buzón de enlaces de autenticación. Quien reciba el enlace del sistema (App Links en Android,
/// Universal Links en iOS: un plugin de la capa de plataforma) lo publica con [postFromUri], y
/// la navegación lo consume. Si ya hay sesión activa, la navegación lo descarta y avisa.
class AuthDeepLinkInbox extends ChangeNotifier {
  static const expectedHost = 'atelier.andeva.tech';
  static const maxTokenLength = 512;

  AuthDeepLink? _pending;

  AuthDeepLink? get pending => _pending;

  /// `false` si [uri] no es un enlace de autenticación nuestro.
  bool postFromUri(Uri? uri) {
    final link = parseUri(uri);
    if (link == null) return false;
    _pending = link;
    notifyListeners();
    return true;
  }

  AuthDeepLink? consume() {
    final link = _pending;
    _pending = null;
    if (link != null) notifyListeners();
    return link;
  }

  /// Solo `https` y el host esperado: cualquier otro esquema o host se ignora. El token se
  /// recorta a [maxTokenLength]; sin token queda vacío y la pantalla lo pide.
  static AuthDeepLink? parseUri(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme.toLowerCase() != 'https') return null;
    if (uri.host.toLowerCase() != expectedHost) return null;
    var token = (uri.queryParameters['token'] ?? '').trim();
    if (token.length > maxTokenLength) token = token.substring(0, maxTokenLength);
    if (uri.path.startsWith('/auth/accept-invitation')) {
      return AcceptInvitationDeepLink(token);
    }
    return null;
  }
}
