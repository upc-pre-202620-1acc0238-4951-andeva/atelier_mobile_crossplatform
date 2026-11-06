import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/public_endpoints.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/token_refresher.dart';
import 'package:http/http.dart' as http;

/// Agrega `Authorization` y `Accept-Language`, y reintenta una sola vez tras un 401.
class AuthenticatedClient extends http.BaseClient {
  static const _authorization = 'Authorization';
  static const _bearer = 'Bearer ';

  final http.Client inner;
  final SessionStore session;
  final TokenRefresher refresher;
  final Duration attemptTimeout;

  AuthenticatedClient({
    required this.inner,
    required this.session,
    required this.refresher,
    this.attemptTimeout = const Duration(seconds: 60), // Render despierta en frío.
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final isPublic = PublicEndpoints.isPublic(request.method, request.url);
    // Un token explícito se respeta: tras el login aún no está guardado (paso 2).
    final token = isPublic
        ? null
        : request.headers[_authorization]?.replaceFirst(_bearer, '') ??
              await session.getAuthToken();

    final first = await _attempt(_copy(request, token));
    if (first.statusCode != 401 || isPublic) return first; // Público: credenciales, no sesión.

    final fresh = await refresher.refreshIfStale(token);
    if (fresh == null) return first;
    await first.stream.drain<void>();
    return _attempt(_copy(request, fresh));
  }

  /// El timeout es por intento, no del flujo completo: si envolviera también el refresh, la UI
  /// vería "sin respuesta" mientras el `POST` reintentado aún puede llegar al backend (H28).
  Future<http.StreamedResponse> _attempt(http.Request request) async {
    final response = await inner.send(request).timeout(attemptTimeout);
    return http.StreamedResponse(
      response.stream.timeout(attemptTimeout),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  http.Request _copy(http.BaseRequest original, String? token) {
    if (original is! http.Request) {
      throw ArgumentError('Solo http.Request se puede reintentar');
    }
    final copy = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..headers['Accept-Language'] = 'es'
      ..followRedirects = original.followRedirects
      ..bodyBytes = original.bodyBytes;
    if (token != null) copy.headers[_authorization] = '$_bearer$token';
    return copy;
  }
}
