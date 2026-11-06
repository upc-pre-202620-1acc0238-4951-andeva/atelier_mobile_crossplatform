import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:http/http.dart' as http;

/// Hace de almacenamiento compartido entre "motores" en las pruebas.
class FakeSessionStore implements SessionStore {
  String? token;
  String? refreshToken;
  int? expiresAt;
  String? userId;
  AuthenticatedUserDto? saved;
  int clears = 0;

  FakeSessionStore({
    this.token = 'old-token',
    this.refreshToken = 'old-refresh',
    this.expiresAt,
    this.userId = 'u1',
  });

  @override
  Future<String?> getAuthToken() async => token;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<int?> getTokenExpiresAt() async => expiresAt;

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<void> save(AuthenticatedUserDto user) async {
    saved = user;
    token = user.token;
    refreshToken = user.refreshToken;
  }

  @override
  Future<void> clear() async {
    clears++;
    token = null;
    refreshToken = null;
    userId = null;
  }
}

String sessionJson({String token = 'new-token', String refresh = 'new-refresh'}) {
  return '{"userId":"u1","email":"m@taller.pe","fullName":"Andrés","token":"$token",'
      '"tokenType":"Bearer","permissions":["operations:tasks:read"],'
      '"refreshToken":"$refresh","membershipId":"m1",'
      '"activeTenant":{"id":"t1","name":"Taller","taxId":"20123456789"},'
      '"plan":{"planName":"Pro","tier":"PRO","status":"ACTIVE","accessGranted":true,'
      '"iotTelemetryEnabled":true,"aiDiagnosticsEnabled":false}}';
}

http.Response sessionResponse() {
  return http.Response.bytes(utf8.encode(sessionJson()), 200);
}
