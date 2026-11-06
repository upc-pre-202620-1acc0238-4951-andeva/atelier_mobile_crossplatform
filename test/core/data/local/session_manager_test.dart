import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/jwt_claims.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../support/fake_session_store.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

String _jwt(Map<String, dynamic> payload) {
  final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return 'header.${encoded.replaceAll('=', '')}.firma';
}

AuthenticatedUserDto _user({String? json}) {
  return AuthenticatedUserDto.fromJson(jsonDecode(json ?? sessionJson()));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('JwtClaims', () {
    test('lee exp en milisegundos', () {
      expect(JwtClaims.expiresAtMillis(_jwt({'exp': 1000})), 1000000);
    });

    test('un token ilegible devuelve null', () {
      expect(JwtClaims.expiresAtMillis('no-es-jwt'), isNull);
      expect(JwtClaims.expiresAtMillis('a.b!.c'), isNull);
      expect(JwtClaims.expiresAtMillis(_jwt({'sub': 'u1'})), isNull);
      final notObject = base64Url.encode(utf8.encode('[1]'));
      expect(JwtClaims.expiresAtMillis('a.$notObject.c'), isNull);
    });
  });

  group('SessionManager', () {
    test('sin token no hay sesión', () async {
      expect(await SessionManager().getSession(), isNull);
    });

    test('guarda la respuesta completa y avisa', () async {
      final manager = SessionManager();
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.save(_user());
      await manager.updateAssignment('b1', 's1');

      final session = (await manager.getSession())!;
      expect(session.userId, 'u1');
      expect(session.fullName, 'Andrés');
      expect(session.tenantId, 't1');
      expect(session.membershipId, 'm1');
      expect(session.permissions, {'operations:tasks:read'});
      expect(session.plan!.tier, 'PRO');
      expect(session.plan!.aiDiagnosticsEnabled, isFalse);
      expect(session.branchId, 'b1');
      expect(session.shiftId, 's1');
      expect(await manager.getRefreshToken(), 'new-refresh');
      expect(notified, 2);
    });

    test('guarda token_expires_at del JWT', () async {
      final manager = SessionManager();
      await manager.save(_user(json: sessionJson(token: _jwt({'exp': 1000}))));
      expect(await manager.getTokenExpiresAt(), 1000000);

      await manager.save(_user());
      expect(await manager.getTokenExpiresAt(), isNull);
    });

    test('un plan null borra el anterior; sin plan no se oculta nada', () async {
      final manager = SessionManager();
      await manager.save(_user());
      final withoutPlan = jsonDecode(sessionJson())..remove('plan');
      await manager.save(_user(json: jsonEncode(withoutPlan)));
      expect((await manager.getSession())!.plan, isNull);
    });

    test('updateAssignment con null borra sede y turno', () async {
      final manager = SessionManager();
      await manager.save(_user());
      await manager.updateAssignment('b1', 's1');
      await manager.updateAssignment(null, null);
      final session = (await manager.getSession())!;
      expect(session.branchId, isNull);
      expect(session.shiftId, isNull);
    });

    test('clear borra todo y avisa', () async {
      final manager = SessionManager();
      await manager.save(_user());
      await manager.updateAssignment('b1', 's1');
      var notified = 0;
      manager.addListener(() => notified++);

      await manager.clear();

      expect(await manager.getAuthToken(), isNull);
      expect(await manager.getRefreshToken(), isNull);
      expect(await manager.getUserId(), isNull);
      expect(await manager.getSession(), isNull);
      expect(notified, 1);
    });

    test('clear conserva la marca de instalación: el siguiente arranque no '
        'cierra la sesión nueva', () async {
      final manager = SessionManager();
      await manager.clearIfReinstalled();
      await manager.save(_user());
      await manager.clear();
      await manager.save(_user());

      await manager.clearIfReinstalled();

      expect(await manager.getAuthToken(), 'new-token');
    });

    test('tras reinstalar limpia lo que dejó el Keychain', () async {
      FlutterSecureStorage.setMockInitialValues({'token': 'de-antes'});
      final manager = SessionManager();
      await manager.clearIfReinstalled();
      expect(await manager.getAuthToken(), isNull);
    });

    test('escribe primero el refresh y al final el token: un corte deja un '
        'refresh válido', () async {
      final storage = _MockSecureStorage();
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      final manager = SessionManager(
        secure: storage,
        preferences: SharedPreferencesAsync(),
      );

      await manager.save(_user());

      verifyInOrder([
        () => storage.write(key: 'refresh_token', value: 'new-refresh'),
        () => storage.write(key: 'token', value: 'new-token'),
      ]);
    });
  });
}
