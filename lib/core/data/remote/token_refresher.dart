import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:http/http.dart' as http;

/// Renueva el token una sola vez aunque varias peticiones reciban 401 a la vez.
///
/// El refresh rota el `refreshToken` (docs/api/README.md §2): reusar el anterior devuelve 401 y
/// cerraría la sesión. Dentro de un motor basta compartir el `Future`; entre motores, el bloqueo.
class TokenRefresher {
  static const _lease = Duration(seconds: 90);
  static const _expiryMargin = Duration(seconds: 60);

  final SessionStore session;
  final CrossIsolateLock lock;
  final http.Client refreshClient; // Sin AuthenticatedClient: si no, entraría en bucle.
  final String baseUrl;
  final Duration lockRetryDelay;

  TokenRefresher({
    required this.session,
    required this.lock,
    required this.refreshClient,
    required this.baseUrl,
    this.lockRetryDelay = const Duration(milliseconds: 500),
  });

  Future<String?>? _inFlight;

  /// Devuelve un token distinto de [staleToken], renovándolo si hace falta. `null` si no hay
  /// sesión, si el refresh fue rechazado (la sesión se borra) o si no hay red.
  Future<String?> refreshIfStale(String? staleToken) {
    return _inFlight ??= _refresh(
      staleToken,
    ).whenComplete(() => _inFlight = null);
  }

  /// Renueva antes de que venza. Lo usa la cola antes de enviar (04 §5).
  Future<String?> ensureFresh([DateTime? now]) async {
    final token = await session.getAuthToken();
    if (token == null) return null;
    final expiresAt = await session.getTokenExpiresAt();
    if (expiresAt == null) return token;
    final millis = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return expiresAt - millis > _expiryMargin.inMilliseconds
        ? token
        : refreshIfStale(token);
  }

  Future<String?> _refresh(String? staleToken) async {
    // Se espera tanto como dura el lease: con Render en frío, el otro motor puede tardar 60 s.
    final attempts = _lease.inMilliseconds ~/ lockRetryDelay.inMilliseconds;
    for (var i = 0; i < attempts; i++) {
      if (await lock.tryAcquire(CrossIsolateLock.tokenRefresh, _lease)) {
        try {
          return await _refreshHoldingLock(staleToken);
        } finally {
          await lock.release(CrossIsolateLock.tokenRefresh);
        }
      }
      await Future<void>.delayed(lockRetryDelay);
    }
    return null; // Se conserva la sesión; se reintenta luego.
  }

  Future<String?> _refreshHoldingLock(String? staleToken) async {
    final current = await session.getAuthToken();
    if (current == null) return null;
    if (staleToken != null && current != staleToken) return current; // Otro ya renovó.

    final refreshToken = await session.getRefreshToken();
    if (refreshToken == null) return null;

    final http.Response response;
    try {
      response = await refreshClient
          .post(
            Uri.parse('$baseUrl/api/v1/auth/refresh'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept-Language': 'es',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 60));
    } on Exception {
      return null; // Sin red: se conserva la sesión.
    }

    // Bajo el bloqueo nadie más renueva: si cambió, se cerró sesión o entró otro usuario durante el
    // POST. Guardar resucitaría o pisaría la sesión, y un 401 (refresh ya revocado) borraría la nueva.
    // shortcut: queda una ventana de milisegundos entre esta lectura y el save, y el refresh
    // rotado de ese caso vence solo a los 30 días; cerrarla exigiría que el sign-out esperara el bloqueo.
    if (await session.getAuthToken() != current) return null;

    if (response.statusCode == 200) {
      // Completa, no solo los tokens: `plan` y permisos se actualizan en cada refresh (06 §5).
      final AuthenticatedUserDto user;
      try {
        user = AuthenticatedUserDto.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
        );
      } on FormatException {
        return null;
      } on TypeError {
        return null;
      }
      await session.save(user);
      return user.token;
    }
    if (response.statusCode == 401) await session.clear();
    return null;
  }
}
