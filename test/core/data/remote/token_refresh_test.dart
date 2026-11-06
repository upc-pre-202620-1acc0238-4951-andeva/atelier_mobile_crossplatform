import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/authenticated_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/public_endpoints.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/token_refresher.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/fake_session_store.dart';

const _baseUrl = 'https://api.test';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;
  late CrossIsolateLock lock;
  late FakeSessionStore session;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    lock = CrossIsolateLock(database: database);
    session = FakeSessionStore();
  });
  tearDown(() => database.close());

  TokenRefresher refresher(http.Client client, {CrossIsolateLock? using}) {
    return TokenRefresher(
      session: session,
      lock: using ?? lock,
      refreshClient: client,
      baseUrl: _baseUrl,
      lockRetryDelay: const Duration(milliseconds: 5),
    );
  }

  ApiClient api(MockClientHandler handler, {Duration? timeout}) {
    final mock = MockClient(handler);
    return ApiClient(
      client: AuthenticatedClient(
        inner: mock,
        session: session,
        refresher: refresher(mock),
        attemptTimeout: timeout ?? const Duration(seconds: 5),
      ),
      baseUrl: _baseUrl,
    );
  }

  bool isRefresh(http.Request request) =>
      request.url.path == '/api/v1/auth/refresh';

  group('AuthenticatedClient', () {
    test('agrega cabeceras; 401 renueva y repite con el token nuevo', () async {
      final authorizations = <String?>[];
      final client = api((request) async {
        if (isRefresh(request)) return sessionResponse();
        authorizations.add(request.headers['Authorization']);
        expect(request.headers['Accept-Language'], 'es');
        return request.headers['Authorization'] == 'Bearer new-token'
            ? http.Response('{"ok":true}', 200)
            : http.Response('{"code":"UNAUTHORIZED","message":"x"}', 401);
      });

      expect((await client.get('/api/v1/tasks/my'))['ok'], isTrue);
      expect(authorizations, ['Bearer old-token', 'Bearer new-token']);
    });

    test('el refresh guarda la respuesta completa, con plan y permisos', () async {
      final client = api((request) async {
        if (isRefresh(request)) return sessionResponse();
        return request.headers['Authorization'] == 'Bearer new-token'
            ? http.Response('{}', 200)
            : http.Response('{}', 401);
      });

      await client.get('/api/v1/tasks/my');

      expect(session.saved!.plan!.tier, 'PRO');
      expect(session.saved!.permissions, ['operations:tasks:read']);
      expect(session.refreshToken, 'new-refresh');
    });

    test('refresh rechazado borra la sesión y sube el 401', () async {
      final client = api((request) async => http.Response('{}', 401));

      await expectLater(
        client.get('/api/v1/tasks/my'),
        throwsA(isA<ApiException>().having((e) => e.httpStatus, 'status', 401)),
      );
      expect(session.clears, 1);
    });

    test('sin red en el refresh se conserva la sesión', () async {
      final client = api((request) async {
        if (isRefresh(request)) throw const SocketException('sin red');
        return http.Response('{}', 401);
      });

      await expectLater(
        client.get('/api/v1/tasks/my'),
        throwsA(isA<ApiException>()),
      );
      expect(session.clears, 0);
      expect(session.token, 'old-token');
    });

    test('dos 401 a la vez hacen un solo refresh', () async {
      var refreshes = 0;
      final client = api((request) async {
        if (isRefresh(request)) {
          refreshes++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return sessionResponse();
        }
        return request.headers['Authorization'] == 'Bearer new-token'
            ? http.Response('{}', 200)
            : http.Response('{}', 401);
      });

      await Future.wait([
        client.get('/api/v1/a'),
        client.get('/api/v1/b'),
        client.get('/api/v1/c'),
      ]);
      expect(refreshes, 1);
    });

    test('las rutas públicas no llevan token ni disparan refresh', () async {
      var calls = 0;
      final client = api((request) async {
        calls++;
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('{"code":"X","message":"Credenciales"}', 401);
      });

      await expectLater(
        client.post('/api/v1/auth/sign-in', body: {}),
        throwsA(isA<ApiException>()),
      );
      expect(calls, 1);
      expect(session.clears, 0);
    });

    test('respeta un Authorization explícito (token aún sin guardar)', () async {
      session.token = null;
      late String? sent;
      final client = api((request) async {
        sent = request.headers['Authorization'];
        return http.Response('{}', 200);
      });

      await client.get(
        '/api/v1/hr/employees/membership/m1',
        headers: {'Authorization': 'Bearer recien-recibido'},
      );
      expect(sent, 'Bearer recien-recibido');
    });

    test('un intento colgado es NetworkException', () async {
      final client = api(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(
        client.get('/api/v1/x'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('el timeout no cubre el refresh: el reintento aún responde', () async {
      final client = api((request) async {
        if (isRefresh(request)) {
          await Future<void>.delayed(const Duration(milliseconds: 150));
          return sessionResponse();
        }
        return request.headers['Authorization'] == 'Bearer new-token'
            ? http.Response('{"ok":true}', 200)
            : http.Response('{}', 401);
      }, timeout: const Duration(milliseconds: 100));

      expect((await client.get('/api/v1/x'))['ok'], isTrue);
    });
  });

  test('PublicEndpoints', () {
    bool public(String method, String path) =>
        PublicEndpoints.isPublic(method, Uri.parse('$_baseUrl$path'));

    expect(public('POST', '/api/v1/auth/sign-in'), isTrue);
    expect(public('GET', '/api/v1/invitations/validate'), isTrue);
    expect(public('GET', '/api/v1/billing/plans'), isTrue);
    expect(public('POST', '/api/v1/billing/plans'), isFalse);
    expect(public('PUT', '/api/v1/users/me/device-token'), isFalse);
  });

  group('ensureFresh', () {
    final now = DateTime.utc(2026, 11, 5);

    test('con margen no llama al backend', () async {
      session.expiresAt = now
          .add(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      final client = MockClient((_) async => fail('no debe renovar'));
      expect(await refresher(client).ensureFresh(now), 'old-token');
    });

    test('a punto de vencer renueva', () async {
      session.expiresAt = now
          .add(const Duration(seconds: 30))
          .millisecondsSinceEpoch;
      final client = MockClient((_) async => sessionResponse());
      expect(await refresher(client).ensureFresh(now), 'new-token');
    });

    test('sin sesión devuelve null', () async {
      session.token = null;
      final client = MockClient((_) async => fail('no debe renovar'));
      expect(await refresher(client).ensureFresh(now), isNull);
    });
  });

  test('un 200 ilegible no borra la sesión ni revienta', () async {
    final client = MockClient((_) async => http.Response('<html>', 200));
    expect(await refresher(client).refreshIfStale('old-token'), isNull);
    expect(session.clears, 0);
  });

  group('dos motores', () {
    late Directory directory;
    late AppDatabase uiDatabase;
    late AppDatabase workerDatabase;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('atelier_refresh_');
      final file = File('${directory.path}/db.sqlite');
      AppDatabase open() => AppDatabase(
        NativeDatabase.createInBackground(
          file,
          setup: AppDatabase.configureConnection,
        ),
      );
      uiDatabase = open();
      await uiDatabase.customSelect('SELECT 1').get();
      workerDatabase = open();
    });

    tearDown(() async {
      await uiDatabase.close();
      await workerDatabase.close();
      await directory.delete(recursive: true);
    });

    test('refresh simultáneo: una sola rotación y nadie cierra la sesión', () async {
      var valid = 'old-refresh';
      var rotations = 0;
      final server = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        // Como el backend: reusar un refreshToken ya rotado responde 401.
        if (!request.body.contains('"$valid"')) {
          return http.Response('{}', 401);
        }
        rotations++;
        valid = 'new-refresh';
        return sessionResponse();
      });

      final results = await Future.wait([
        refresher(
          server,
          using: CrossIsolateLock(database: uiDatabase),
        ).refreshIfStale('old-token'),
        refresher(
          server,
          using: CrossIsolateLock(database: workerDatabase),
        ).refreshIfStale('old-token'),
      ]);

      expect(results, ['new-token', 'new-token']);
      expect(rotations, 1);
      expect(session.clears, 0);
    });
  });

  group('un refresh en curso no pisa la sesión', () {
    test('cerrar sesión durante el POST: no la resucita', () async {
      final server = MockClient((_) async {
        await session.clear();
        return sessionResponse();
      });

      expect(await refresher(server).refreshIfStale('old-token'), isNull);
      expect(session.saved, isNull);
      expect(session.token, isNull);
      expect(session.refreshToken, isNull);
    });

    test('otro login durante el POST: no lo pisa', () async {
      final server = MockClient((_) async {
        session.token = 'other-user-token';
        session.refreshToken = 'other-user-refresh';
        return sessionResponse();
      });

      expect(await refresher(server).refreshIfStale('old-token'), isNull);
      expect(session.saved, isNull);
      expect(session.token, 'other-user-token');
      expect(session.refreshToken, 'other-user-refresh');
    });

    test('un 401 tardío no borra la sesión de otro login', () async {
      final server = MockClient((_) async {
        session.token = 'other-user-token';
        return http.Response('{}', 401);
      });

      expect(await refresher(server).refreshIfStale('old-token'), isNull);
      expect(session.clears, 0);
      expect(session.token, 'other-user-token');
    });
  });
}
