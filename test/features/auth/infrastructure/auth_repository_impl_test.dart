import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/auth_refresh_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/accept_invitation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_errors.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invalid_invitation_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/auth_api.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../core/support/fake_session_store.dart';

class _MockRegistrar extends Mock implements DeviceTokenRegistrar {}

http.Response _error(
  int status, {
  String code = 'X',
  String message = 'Falló',
}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode({'code': code, 'message': message})),
    status,
  );
}

const _profile = '{"id":"e1","branchId":"b1","assignedShiftId":"s1"}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;
  late SessionManager session;
  late _MockRegistrar registrar;
  late List<String> calls;
  late int syncs;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    session = SessionManager();
    registrar = _MockRegistrar();
    calls = [];
    syncs = 0;
    when(() => registrar.registerCurrentToken()).thenAnswer((_) async {});
    when(() => registrar.clear()).thenAnswer((_) async {
      calls.add('device-token');
    });
  });
  tearDown(() => database.close());

  AuthRepositoryImpl repository(MockClientHandler handler) {
    final client = ApiClient(
      client: MockClient(handler),
      baseUrl: 'https://api.test',
    );
    return AuthRepositoryImpl(
      api: AuthApi(client: client),
      employeeApi: EmployeeApi(client: client),
      refreshApi: AuthRefreshApi(client: client),
      session: session,
      deviceTokens: registrar,
      cacheDao: database.cacheMaintenanceDao,
      pendingDao: database.pendingOperationDao,
      requestSync: () => syncs++,
    );
  }

  /// Sign-in correcto, con [profile] como respuesta del perfil laboral.
  MockClientHandler login(Future<http.Response> Function() profile) {
    return (request) async {
      if (request.url.path.endsWith('/auth/sign-in')) return sessionResponse();
      return profile();
    };
  }

  PendingOperationsCompanion operation(String id, String userId) {
    return PendingOperationsCompanion.insert(
      id: id,
      type: 'PROBE',
      payload: '{}',
      dedupeKey: id,
      userId: userId,
      tenantId: 't1',
      nextAttemptAt: 0,
      createdAt: 0,
    );
  }

  group('iniciar sesión', () {
    test(
      'pide la sede con el token recibido y la guarda con la sesión',
      () async {
        String? authorization;
        final repo = repository((request) async {
          if (request.url.path.contains('/hr/employees/membership/m1')) {
            authorization = request.headers['Authorization'];
          }
          return login(() async => http.Response(_profile, 200))(request);
        });

        await repo.signIn(' m@taller.pe ', 'clave');

        expect(authorization, 'Bearer new-token');
        final current = await session.getSession();
        expect(current!.branchId, 'b1');
        expect(current.shiftId, 's1');
        expect(current.needsBranchChoice, isFalse);
        verify(() => registrar.registerCurrentToken()).called(1);
        expect(syncs, 1);
      },
    );

    test('la primera lectura tras guardar ya trae la sede', () async {
      final seen = <String?>[];
      session.addListener(() async {
        final current = await session.getSession();
        if (current != null) seen.add(current.branchId);
      });

      await repository(login(() async => http.Response(_profile, 200)))
          .signIn('m@taller.pe', 'clave');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(seen, isNotEmpty);
      expect(seen, everyElement('b1'));
    });

    test('sin perfil laboral (404) se ofrece elegir sede', () async {
      await repository(login(() async => _error(404)))
          .signIn('m@taller.pe', 'clave');

      final current = await session.getSession();
      expect(current!.branchId, isNull);
      expect(current.needsBranchChoice, isTrue);
    });

    test('un 500 al pedir el perfil entra sin sede y sin elegir', () async {
      await repository(login(() async => _error(500)))
          .signIn('m@taller.pe', 'clave');

      final current = await session.getSession();
      expect(current!.branchId, isNull);
      expect(current.needsBranchChoice, isFalse);
    });

    test('sin red al pedir el perfil entra sin sede y sin elegir', () async {
      await repository(
        login(() async => throw const SocketException('sin red')),
      ).signIn('m@taller.pe', 'clave');

      final current = await session.getSession();
      expect(current!.branchId, isNull);
      expect(current.needsBranchChoice, isFalse);
    });

    test('una marca vieja de un login sin guardar no sobrevive', () async {
      await session.setBranchChoicePending(true);

      await repository(login(() async => _error(500)))
          .signIn('m@taller.pe', 'clave');

      expect((await session.getSession())!.needsBranchChoice, isFalse);
    });

    test(
      'sin membershipId no consulta el perfil y ofrece elegir sede',
      () async {
        final json = jsonDecode(sessionJson()) as Map<String, dynamic>;
        json.remove('membershipId');
        var profileCalls = 0;

        await repository((request) async {
          if (request.url.path.endsWith('/auth/sign-in')) {
            return http.Response.bytes(utf8.encode(jsonEncode(json)), 200);
          }
          profileCalls++;
          return http.Response(_profile, 200);
        }).signIn('m@taller.pe', 'clave');

        expect(profileCalls, 0);
        expect((await session.getSession())!.needsBranchChoice, isTrue);
      },
    );

    test('correo sin verificar conserva el code y no guarda sesión', () async {
      final repo = repository(
        (_) async => _error(403, code: emailNotVerifiedCode),
      );

      await expectLater(
        repo.signIn('m@taller.pe', 'clave'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            emailNotVerifiedCode,
          ),
        ),
      );
      expect(await session.getSession(), isNull);
      expect(syncs, 0);
    });

    test('credenciales inválidas (401) no guardan sesión', () async {
      final repo = repository((_) async => _error(401));

      await expectLater(
        repo.signIn('m@taller.pe', 'clave'),
        throwsA(isA<ApiException>()),
      );
      expect(await session.getSession(), isNull);
    });

    test('sin red falla como NetworkException', () async {
      final repo = repository(
        (_) async => throw const SocketException('sin red'),
      );

      await expectLater(
        repo.signIn('m@taller.pe', 'clave'),
        throwsA(isA<NetworkException>()),
      );
    });

    for (final failure in <Object>[
      const NetworkException(),
      const ApiException(httpStatus: 500, code: 'X', message: 'Falló'),
    ]) {
      test(
        'un fallo del token FCM (${failure.runtimeType}) no rompe el login',
        () async {
          when(() => registrar.registerCurrentToken()).thenThrow(failure);

          await repository(login(() async => http.Response(_profile, 200)))
              .signIn('m@taller.pe', 'clave');

          expect(await session.getSession(), isNotNull);
          expect(syncs, 1);
        },
      );
    }

    test('Google usa el mismo flujo', () async {
      Object? body;
      await repository((request) async {
        if (request.url.path.endsWith('/auth/google-sign-in')) {
          body = jsonDecode(request.body);
          return sessionResponse();
        }
        return http.Response(_profile, 200);
      }).signInWithGoogle('google-token');

      expect(body, {'idToken': 'google-token'});
      expect((await session.getSession())!.branchId, 'b1');
    });
  });

  group('invitación', () {
    test('valid = false falla como invitación inválida', () async {
      final repo = repository(
        (_) async => http.Response('{"valid":false}', 200),
      );

      await expectLater(
        repo.validateInvitation('t'),
        throwsA(isA<InvalidInvitationException>()),
      );
    });

    test('válida devuelve taller y rol, y envía el token', () async {
      Uri? url;
      final preview = await repository((request) async {
        url = request.url;
        return http.Response(
          '{"valid":true,"email":"a@b.pe","tenantName":"Taller","roleName":"Jefe"}',
          200,
        );
      }).validateInvitation(' t1 ');

      expect(url!.queryParameters['token'], 't1');
      expect(preview.tenantName, 'Taller');
      expect(preview.email, 'a@b.pe');
    });

    test('vencida (410) conserva el mensaje del backend', () async {
      final repo = repository(
        (_) async => _error(410, message: 'Invitación vencida'),
      );

      await expectLater(
        repo.validateInvitation('t'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.httpStatus, 'httpStatus', 410)
              .having((e) => e.message, 'message', 'Invitación vencida'),
        ),
      );
    });

    test('aceptar deja la sesión iniciada y omite el teléfono vacío', () async {
      Map<String, dynamic>? body;
      await repository((request) async {
        if (request.url.path.endsWith('/invitations/accept')) {
          body = jsonDecode(request.body);
          return http.Response.bytes(utf8.encode(sessionJson()), 201);
        }
        return http.Response(_profile, 200);
      }).acceptInvitation(
        const AcceptInvitation(
          token: 't',
          firstName: ' Ana ',
          lastName: ' Díaz ',
          password: 'clave1234',
          phone: '  ',
        ),
      );

      expect(body!['firstName'], 'Ana');
      expect(body!['lastName'], 'Díaz');
      expect(body!.containsKey('phone'), isFalse);
      expect(await session.getSession(), isNotNull);
    });
  });

  group('correo y contraseña', () {
    const ok = '{"message":"Listo","timestamp":"2026-10-20T15:04:05Z"}';

    test('verificar envía el OTP como token y devuelve el mensaje', () async {
      Object? body;
      final message = await repository((request) async {
        expect(request.url.path, '/api/v1/auth/verify-email');
        body = jsonDecode(request.body);
        return http.Response(ok, 200);
      }).verifyEmail(' m@taller.pe ', '123456');

      expect(body, {'email': 'm@taller.pe', 'token': '123456'});
      expect(message, 'Listo');
    });

    test('reenviar, olvidar y restablecer llaman a su ruta', () async {
      final paths = <String>[];
      final repo = repository((request) async {
        paths.add(request.url.path);
        return http.Response(ok, 200);
      });

      await repo.resendVerification('m@taller.pe');
      await repo.forgotPassword('m@taller.pe');
      await repo.resetPassword('t', 'clave1234');

      expect(paths, [
        '/api/v1/auth/resend-verification',
        '/api/v1/auth/forgot-password',
        '/api/v1/auth/reset-password',
      ]);
    });

    test('token de restablecimiento vencido (400) sube', () async {
      final repo = repository((_) async => _error(400));

      await expectLater(
        repo.resetPassword('t', 'clave1234'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('operaciones pendientes', () {
    test('con sesión, las del usuario; sin sesión, 0, como Android', () async {
      final dao = database.pendingOperationDao;
      await dao.enqueue(operation('mine', 'u1'));
      await dao.enqueue(operation('other', 'u2'));
      final repo = repository((_) async => http.Response('', 200));

      expect(await repo.pendingOperationCount(), 0);

      await session.save(
        AuthenticatedUserDto.fromJson(jsonDecode(sessionJson())),
      );

      expect(await repo.pendingOperationCount(), 1);
    });
  });

  group('cerrar sesión', () {
    setUp(() async {
      await session.save(
        AuthenticatedUserDto.fromJson(jsonDecode(sessionJson())),
      );
      await database.pendingOperationDao.enqueue(operation('op', 'u1'));
      await database
          .into(database.branches)
          .insert(
            BranchesCompanion.insert(
              id: 'b1',
              name: 'Sede',
              latitude: 0,
              longitude: 0,
              geofenceRadiusMeters: 50,
              isActive: true,
              syncedAt: 0,
            ),
          );
      await database
          .into(database.telemetryReadings)
          .insert(
            TelemetryReadingsCompanion.insert(
              id: 'r1',
              vehicleId: 'v1',
              timestamp: 0,
              engineTempCelsius: 90,
            ),
          );
    });

    Future<void> expectSignedOut() async {
      expect(await session.getSession(), isNull);
      expect(await session.getRefreshToken(), isNull);
      expect(await database.select(database.branches).get(), isEmpty);
      expect(
        await database.select(database.pendingOperations).get(),
        hasLength(1),
      );
      expect(
        await database.select(database.telemetryReadings).get(),
        hasLength(1),
      );
    }

    test('borra el token, revoca el refresh y limpia, en ese orden', () async {
      Object? body;
      await repository((request) async {
        calls.add('sign-out');
        body = jsonDecode(request.body);
        return http.Response('{"message":"ok"}', 200);
      }).signOut();

      expect(calls, ['device-token', 'sign-out']);
      expect(body, {'refreshToken': 'new-refresh'});
      await expectSignedOut();
    });

    test('sin red igual se sale', () async {
      when(() => registrar.clear()).thenThrow(const NetworkException());

      await repository((_) async => throw const SocketException('sin red'))
          .signOut();

      await expectSignedOut();
    });

    test('un 500 del backend no impide salir', () async {
      when(() => registrar.clear()).thenThrow(
        const ApiException(httpStatus: 500, code: 'X', message: 'Falló'),
      );

      await repository((_) async => _error(500)).signOut();

      await expectSignedOut();
    });

    test('un error inesperado también sale, y se propaga', () async {
      when(() => registrar.clear()).thenThrow(StateError('inesperado'));

      await expectLater(
        repository((_) async => http.Response('{}', 200)).signOut(),
        throwsStateError,
      );

      await expectSignedOut();
    });

    test('si el PUT rota el token, revoca el nuevo', () async {
      when(() => registrar.clear()).thenAnswer((_) async {
        await session.save(
          AuthenticatedUserDto.fromJson(
            jsonDecode(sessionJson(refresh: 'rotated')),
          ),
        );
      });
      Object? body;

      await repository((request) async {
        body = jsonDecode(request.body);
        return http.Response('{}', 200);
      }).signOut();

      expect(body, {'refreshToken': 'rotated'});
    });

    test('si el PUT cerró la sesión, no llama a sign-out', () async {
      when(() => registrar.clear()).thenAnswer((_) => session.clear());
      var signOuts = 0;

      await repository((_) async {
        signOuts++;
        return http.Response('{}', 200);
      }).signOut();

      expect(signOuts, 0);
      await expectSignedOut();
    });
  });
}
