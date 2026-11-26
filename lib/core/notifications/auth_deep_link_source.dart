import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';

/// Lee los enlaces del sistema (App Links en Android, Universal Links en iOS) y los publica en el
/// [AuthDeepLinkInbox]. Equivale a `MainActivity.onCreate`/`onNewIntent` de la app nativa: el enlace
/// con el que se abrió la app y los que llegan después.
///
/// Android: `autoVerify` sobre `https://atelier.andeva.tech` (`AndroidManifest.xml`).
/// iOS: Associated Domains `applinks:atelier.andeva.tech` (`Runner.entitlements`); sin comprobar
/// porque no hay Mac, y exige publicar `apple-app-site-association` en el dominio.
class AuthDeepLinkSource {
  final AuthDeepLinkInbox inbox;
  final AppLinks _links;
  StreamSubscription<Uri>? _subscription;

  AuthDeepLinkSource({required this.inbox, AppLinks? links}) : _links = links ?? AppLinks();

  Future<void> start() async {
    // Primero se suscribe: un enlace que llegue mientras se lee el inicial no se pierde.
    _subscription = _links.uriLinkStream.listen(_onLink, onError: (_) {});
    final initial = await _links.getInitialLink();
    _initial = initial;
    inbox.postFromUri(initial);
  }

  Uri? _initial;

  /// Según la versión, el flujo repite el enlace inicial: se publica una sola vez.
  void _onLink(Uri uri) {
    if (_initial == uri) {
      _initial = null;
      return;
    }
    inbox.postFromUri(uri);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
