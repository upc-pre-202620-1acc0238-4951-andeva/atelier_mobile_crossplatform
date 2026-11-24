import 'dart:async';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:flutter/foundation.dart';

/// Estado de la sesión que decide el grafo de navegación (`SessionState` de Android).
sealed class SessionState {
  const SessionState();
}

/// Aún no se leyó la sesión: pantalla en blanco, sin spinner.
final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}

/// [needsBranchChoice]: cuenta que debe elegir o confirmar sede antes de entrar (A5b).
final class SessionSignedIn extends SessionState {
  final bool needsBranchChoice;

  const SessionSignedIn({this.needsBranchChoice = false});
}

/// Equivale a `AppNavHostViewModel`. Relee la sesión solo cuando `SessionManager` avisa: un `Future`
/// creado en `build` volvería al estado de carga con cualquier reconstrucción. Si el worker borra la
/// sesión (refresh fallido), el aviso de `LocalChangeNotifier` la trae de vuelta al login.
///
/// Los push y los enlaces de invitación llegan por sus buzones; este ViewModel solo los entrega cuando
/// la sesión permite abrirlos ([consumePush], [consumeAuthDeepLink]).
class AppNavHostViewModel extends ChangeNotifier {
  final SessionManager sessionManager;
  final PushInbox? pushInbox;
  final AuthDeepLinkInbox? authDeepLinks;

  AppNavHostViewModel({required this.sessionManager, this.pushInbox, this.authDeepLinks}) {
    sessionManager.addListener(_read);
    pushInbox?.addListener(_onInboxChanged);
    authDeepLinks?.addListener(_onInboxChanged);
    _read();
  }

  SessionState _sessionState = const SessionLoading();
  Session? _session;
  int _lastRead = 0;
  bool _disposed = false;

  SessionState get sessionState => _sessionState;

  /// La sesión leída; `null` sin sesión o mientras carga.
  Session? get session => _session;

  bool get _canOpenPush {
    final state = _sessionState;
    return state is SessionSignedIn && !state.needsBranchChoice;
  }

  bool get hasReadyPush => _canOpenPush && pushInbox?.pending != null;

  bool get hasReadyDeepLink => _sessionState is SessionSignedIn && authDeepLinks?.pending != null;

  /// El push pendiente, solo si hay sesión con sede resuelta. Si no, se queda esperando.
  PushDestination? consumePush() => _canOpenPush ? pushInbox?.consume() : null;

  /// El enlace de autenticación pendiente, solo con sesión (sin sesión lo consume el grafo de auth).
  AuthDeepLink? consumeAuthDeepLink() => _sessionState is SessionSignedIn ? authDeepLinks?.consume() : null;

  void _onInboxChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _read() async {
    final read = ++_lastRead;
    Session? session;
    try {
      session = await sessionManager.getSession();
    } on Exception catch (e) {
      // Almacenamiento seguro ilegible: mejor el login que un estado de carga para siempre.
      log('No se pudo leer la sesión: $e', name: 'AppNavHostViewModel');
    }
    // Dos avisos seguidos: solo vale la lectura más reciente.
    if (_disposed || read != _lastRead) return;
    _session = session;
    _sessionState = session == null
        ? const SessionSignedOut()
        : SessionSignedIn(needsBranchChoice: session.needsBranchChoice);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    sessionManager.removeListener(_read);
    pushInbox?.removeListener(_onInboxChanged);
    authDeepLinks?.removeListener(_onInboxChanged);
    super.dispose();
  }
}
