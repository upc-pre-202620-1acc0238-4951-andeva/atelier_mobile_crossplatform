import 'dart:async';
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

    test(
      'un plan null borra el anterior; sin plan no se oculta nada',
      () async {
        final manager = SessionManager();
        await manager.save(_user());
        final withoutPlan = jsonDecode(sessionJson())..remove('plan');
        await manager.save(_user(json: jsonEncode(withoutPlan)));
        expect((await manager.getSession())!.plan, isNull);
      },
    );

    test('updateAssignment con null borra sede y turno', () async {
      final manager = SessionManager();
      await manager.save(_user());
      await manager.updateAssignment('b1', 's1');
      await manager.updateAssignment(null, null);
      final session = (await manager.getSession())!;
      expect(session.branchId, isNull);
      expect(session.shiftId, isNull);
    });

    group('elegir sede (H33)', () {
      late SessionManager session;

      setUp(() async {
        session = SessionManager();
        await session.save(_user());
      });

      test('pendiente: pide elegir hasta tener sede', () async {
        await session.setBranchChoicePending(true);
        expect((await session.getSession())!.needsBranchChoice, isTrue);

        await session.selectBranch('elegida');

        final chosen = await session.getSession();
        expect(chosen!.branchId, 'elegida');
        expect(chosen.needsBranchChoice, isFalse);
      });

      test('"elegir después" entra sin sede y no vuelve a pedirla', () async {
        await session.setBranchChoicePending(true);

        await session.dismissBranchChoice();

        final current = await session.getSession();
        expect(current!.branchId, isNull);
        expect(current.needsBranchChoice, isFalse);
      });

      test('la asignada reemplaza a la elegida y quita la marca', () async {
        await session.setBranchChoicePending(true);
        await session.selectBranch('elegida');

        await session.updateAssignment('asignada', 's1');
        expect((await session.getSession())!.branchId, 'asignada');

        await session.updateAssignment(null, null);
        expect((await session.getSession())!.branchId, isNull);
      });

      test('un perfil sin sede (404) conserva la elegida', () async {
        await session.selectBranch('elegida');

        await session.updateAssignment(null, null);

        expect((await session.getSession())!.branchId, 'elegida');
      });

      test('cada cambio avisa, para que AppRoot cambie de pantalla', () async {
        var notifications = 0;
        session.addListener(() => notifications++);

        await session.setBranchChoicePending(true);
        await session.selectBranch('elegida');
        await session.dismissBranchChoice();

        expect(notifications, 3);
      });

      test('clear borra sede elegida y marca', () async {
        await session.selectBranch('elegida');
        await session.setBranchChoicePending(true);

        await session.clear();
        await session.save(_user());

        final current = await session.getSession();
        expect(current!.branchId, isNull);
        expect(current.needsBranchChoice, isFalse);
      });
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

  group('switchOn', () {
    test('cambia de consulta solo si cambia la clave y cancela la anterior', () async {
      final manager = SessionManager();
      final queries = <String?>[];
      var cancelled = 0;
      final seen = <String>[];
      final subscription = manager
          .switchOn<String?, String>((session) => session?.userId, (user) {
            queries.add(user);
            final controller = StreamController<String>(
              onCancel: () => cancelled++,
            );
            controller.add('filas de $user');
            return controller.stream;
          })
          .listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      expect(seen, ['filas de null']);

      await manager.save(_user());
      await pumpEventQueue();
      expect(seen.last, 'filas de u1');
      expect(cancelled, 1);

      await manager.updateAssignment('b1', 's1');
      await pumpEventQueue();
      expect(queries, [null, 'u1'], reason: 'el usuario no cambió');

      await subscription.cancel();
      expect(cancelled, 2);
    });
  });

  group('watchSession', () {
    test('emite al suscribirse y en cada cambio', () async {
      final manager = SessionManager();
      final seen = <String?>[];
      final subscription = manager.watchSession().listen(
        (session) => seen.add(session?.userId),
      );
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      expect(seen, [null]);

      await manager.save(_user());
      await pumpEventQueue();
      expect(seen, [null, 'u1']);

      await manager.clear();
      await pumpEventQueue();
      expect(seen, [null, 'u1', null]);
    });

    test('de dos avisos seguidos vale la última lectura', () async {
      final manager = SessionManager();
      await manager.save(_user());
      final seen = <String?>[];
      final subscription = manager.watchSession().listen(
        (session) => seen.add(session?.userId),
      );
      addTearDown(subscription.cancel);
      await pumpEventQueue();
      seen.clear();

      unawaited(manager.clear());
      manager.reload();
      await pumpEventQueue();

      expect(seen.last, isNull);
    });

    test('cancelar quita el listener y descarta la lectura en curso', () async {
      final manager = _ObservableManager();
      var delivered = 0;
      final subscription = manager.watchSession().listen((_) => delivered++);
      await subscription.cancel();
      await pumpEventQueue();

      expect(delivered, 0);
      expect(manager.listening, isFalse);
    });

    test('si no puede leer el almacenamiento emite null', () async {
      final storage = _MockSecureStorage();
      when(() => storage.read(key: 'token'))
          .thenThrow(Exception('Keychain bloqueado'));
      final manager = SessionManager(
        secure: storage,
        preferences: SharedPreferencesAsync(),
      );

      expect(await manager.watchSession().first, isNull);
    });
  });
}

class _ObservableManager extends SessionManager {
  bool get listening => hasListeners;
}
