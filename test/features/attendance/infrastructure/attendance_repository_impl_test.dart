import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_in_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_out_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/attendance_test_env.dart';

const _location = DeviceLocation(
  latitude: -12.0464,
  longitude: -77.0428,
  accuracyMeters: 10,
  isMock: false,
);

const _branchesPath = '/api/v1/branches';
const _shiftPath = '/api/v1/hr/work-shifts/s1';
const _profilePath = '/api/v1/hr/employees/membership/m1';

void main() {
  late AttendanceTestEnv env;

  setUp(() async {
    env = AttendanceTestEnv.create();
    await env.signIn();
  });
  tearDown(() => env.close());

  Future<TodayAttendance> today() => env.repository.watchToday().first;

  Future<void> saveAttendance({
    String id = 'a1',
    String clockIn = '2026-10-24T13:00:00Z',
    String? clockOut,
  }) async {
    await env.cache.save(
      AttendanceDto.fromJson(
        attendanceJson(id: id, clockIn: clockIn, clockOut: clockOut),
      ),
      'm1',
    );
  }

  group('marcaciones', () {
    test('ingreso con red se registra sin hora del dispositivo', () async {
      env.responses['POST $clockInPath'] = (_) => json(attendanceJson(), 201);

      final outcome = await env.repository.clockIn('b1', 's1', _location);

      expect(outcome, isA<Recorded>());
      final body = env.requested('POST', clockInPath).single.body;
      expect(body, contains('"branchId":"b1"'));
      expect(body, isNot(contains('clockInTime')));
      expect(await today(), isA<ClockedIn>());
      expect(await env.pending(), isEmpty);
    });

    test('un error de negocio sube con su message y no se encola', () async {
      env.responses['POST $clockInPath'] = (_) =>
          apiError(422, 'Estás a 350 m de la sede');

      await expectLater(
        env.repository.clockIn('b1', 's1', _location),
        throwsA(
          isA<ApiException>()
              .having((e) => e.httpStatus, 'httpStatus', 422)
              .having((e) => e.message, 'message', 'Estás a 350 m de la sede'),
        ),
      );
      expect(await env.pending(), isEmpty);
    });

    test('sin red se encola con la hora y la clave del día de Lima', () async {
      env.connectivity.online = false;

      expect(
        await env.repository.clockIn('b1', 's1', _location),
        isA<Queued>(),
      );
      expect(
        await env.repository.clockIn('b1', 's1', _location),
        isA<AlreadyQueued>(),
      );

      final operation = (await env.pending()).single;
      expect(operation.type, ClockInHandler.type);
      expect(operation.dedupeKey, 'CLOCK_IN:m1:2026-10-24');
      expect(
        operation.payload,
        contains('"clockInTime":"2026-10-24T14:00:00.000Z"'),
      );
      expect(env.requests, isEmpty);
      expect(await today(), isA<ClockInQueued>());
    });

    test('la clave usa el día de Lima, no el UTC', () async {
      env.connectivity.online = false;
      env.clock = DateTime.utc(2026, 10, 25, 2); // 21:00 del 24 en Lima.

      await env.repository.clockIn('b1', 's1', _location);

      expect((await env.pending()).single.dedupeKey, 'CLOCK_IN:m1:2026-10-24');
    });

    test('si la llamada se corta se encola', () async {
      env.responses['POST $clockInPath'] = offline;

      expect(
        await env.repository.clockIn('b1', 's1', _location),
        isA<Queued>(),
      );
      expect((await env.pending()).single.type, ClockInHandler.type);
    });

    test('la salida va detrás del ingreso en cola aunque haya red', () async {
      env.connectivity.online = false;
      await env.repository.clockIn('b1', 's1', _location);
      env.connectivity.online = true;

      expect(await env.repository.clockOut(), isA<Queued>());

      final operations = await env.pending();
      final clockIn = operations.firstWhere(
        (o) => o.type == ClockInHandler.type,
      );
      final clockOut = operations.firstWhere(
        (o) => o.type == ClockOutHandler.type,
      );
      expect(clockOut.dependsOn, clockIn.id);
      expect(clockOut.dedupeKey, 'CLOCK_OUT:m1:2026-10-24');
      expect(
        clockOut.payload,
        contains('"clockOutTime":"2026-10-24T14:00:00.000Z"'),
      );
      expect(env.requests, isEmpty);
      expect(await today(), isA<ClockOutQueued>());
    });

    test('salida con red cierra la jornada abierta de la caché', () async {
      await saveAttendance();
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T22:00:00Z'));

      final outcome = await env.repository.clockOut() as Recorded;

      expect(outcome.attendance.workedMinutes, 480);
      expect(
        env.requested('POST', clockOutPath).single.body,
        contains('"attendanceId":"a1"'),
      );
      expect(await today(), isA<Completed>());
    });

    test('descargo sin red se encola con el id y sin espacios', () async {
      env.connectivity.online = false;

      expect(
        await env.repository.submitJustification(
          AttendanceId('a1'),
          '  Tráfico  ',
        ),
        isA<Queued>(),
      );

      final operation = (await env.pending()).single;
      expect(operation.type, 'SUBMIT_JUSTIFICATION');
      expect(operation.dedupeKey, 'JUSTIFICATION:a1');
      expect(jsonDecode(operation.payload), {
        'attendanceId': 'a1',
        'reason': 'Tráfico',
      });
    });

    test('sin membershipId no se puede marcar', () async {
      await env.signIn(membershipId: null);
      await env.session.clear();

      await expectLater(
        env.repository.clockOut(),
        throwsA(isA<MissingAssignmentException>()),
      );
    });
  });

  group('ingreso en cola de otro día', () {
    test('la salida de madrugada espera al ingreso de anoche', () async {
      await env.seedOperation(
        id: 'anoche',
        type: ClockInHandler.type,
        dedupeKey: 'CLOCK_IN:m1:2026-10-23',
      );

      expect(await today(), isA<ClockInQueued>());
      expect(await env.repository.clockOut(), isA<Queued>());

      final clockOut = (await env.pending()).firstWhere(
        (o) => o.type == ClockOutHandler.type,
      );
      expect(clockOut.dependsOn, 'anoche');
      expect(env.requests, isEmpty);
    });

    test('un FAILED de otro día no estorba', () async {
      await env.seedOperation(
        id: 'vieja',
        type: ClockInHandler.type,
        dedupeKey: 'CLOCK_IN:m1:2026-10-10',
        status: 'FAILED',
      );
      await saveAttendance();
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T14:00:00Z'));

      expect(await env.repository.clockOut(), isA<Recorded>());
      expect(env.requested('POST', clockOutPath), hasLength(1));
    });

    test('un FAILED de otro día deja marcar ingreso hoy', () async {
      await env.seedOperation(
        id: 'vieja',
        type: ClockInHandler.type,
        dedupeKey: 'CLOCK_IN:m1:2026-10-10',
        status: 'FAILED',
      );

      expect(await today(), isA<NotClockedIn>());
    });

    test('el ingreso FAILED de hoy no impide cerrar una jornada abierta', () async {
      await env.seedOperation(
        id: 'hoy',
        type: ClockInHandler.type,
        dedupeKey: 'CLOCK_IN:m1:2026-10-24',
        status: 'FAILED',
      );
      await saveAttendance();
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T14:00:00Z'));

      expect(await env.repository.clockOut(), isA<Recorded>());
    });

    test('sin jornada abierta, la salida depende del ingreso FAILED de hoy', () async {
      await env.seedOperation(
        id: 'hoy',
        type: ClockInHandler.type,
        dedupeKey: 'CLOCK_IN:m1:2026-10-24',
        status: 'FAILED',
      );

      expect(await env.repository.clockOut(), isA<Queued>());

      final clockOut = (await env.pending()).firstWhere(
        (o) => o.type == ClockOutHandler.type,
      );
      expect(clockOut.dependsOn, 'hoy');
    });
  });

  group('estado de hoy', () {
    test('sin nada', () async {
      expect(await today(), isA<NotClockedIn>());
    });

    test('la jornada de ayer ya cerrada no cuenta para hoy', () async {
      await saveAttendance(
        clockIn: '2026-10-23T13:00:00Z',
        clockOut: '2026-10-23T22:00:00Z',
      );
      expect(await today(), isA<NotClockedIn>());
    });

    test('la jornada abierta que empezó ayer sigue abierta', () async {
      await saveAttendance(clockIn: '2026-10-23T22:00:00Z');
      expect(await today(), isA<ClockedIn>());
    });

    test('jornada cerrada hoy', () async {
      await saveAttendance(clockOut: '2026-10-24T14:00:00Z');
      expect(await today(), isA<Completed>());
    });

    test('la salida en cola manda sobre la jornada abierta', () async {
      await saveAttendance();
      await env.seedOperation(
        id: 'salida',
        type: ClockOutHandler.type,
        dedupeKey: 'CLOCK_OUT:m1:2026-10-24',
        createdAt: DateTime.utc(2026, 10, 24, 14).millisecondsSinceEpoch,
      );

      final state = await today() as ClockOutQueued;
      expect(state.attendance, isNotNull);
      expect(state.capturedAt, DateTime.utc(2026, 10, 24, 14));
    });

    test('al pasar de día y reemitir, la jornada de ayer deja de contar', () async {
      await saveAttendance(clockOut: '2026-10-24T22:00:00Z');
      final states = <TodayAttendance>[];
      final subscription = env.repository.watchToday().listen(states.add);
      addTearDown(subscription.cancel);
      await _eventually(() => states.isNotEmpty);
      expect(states.last, isA<Completed>());

      env.clock = DateTime.utc(2026, 10, 25, 14);
      env.db.notifyExternalChanges(); // Lo que hace volver a primer plano.

      await _eventually(() => states.last is NotClockedIn);
    });

    test('cambia sola al cerrar sesión', () async {
      await saveAttendance();
      final states = <TodayAttendance>[];
      final subscription = env.repository.watchToday().listen(states.add);
      addTearDown(subscription.cancel);
      await _eventually(() => states.isNotEmpty && states.last is ClockedIn);

      await env.session.clear();

      await _eventually(() => states.last is NotClockedIn);
    });
  });

  group('refresh', () {
    Map<String, Object?> branchJson() => {
      'id': 'b1',
      'name': 'Sede Lima',
      'latitude': -12,
      'longitude': -77.0428,
      'geofenceRadiusMeters': 100,
      'isActive': true,
    };

    Map<String, Object?> shiftJson() => {
      'id': 's1',
      'name': 'Mañana',
      'startTime': '08:00:00',
      'endTime': '17:00:00',
      'gracePeriodMinutes': 15,
      'isActive': true,
      'workDays': ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'],
      'restDays': ['SUNDAY'],
    };

    void respondAll() {
      env.responses['GET $_profilePath'] = (_) => json({
        'id': 'p1',
        'branchId': 'b1',
        'assignedShiftId': 's1',
      });
      env.responses['GET $_branchesPath'] = (_) => json([branchJson()]);
      env.responses['GET $_shiftPath'] = (_) => json(shiftJson());
      env.responses['GET $historyPath'] = (_) => json([
        attendanceJson(
          id: 'old',
          clockIn: '2026-10-20T13:00:00Z',
          clockOut: '2026-10-20T22:00:00Z',
          status: 'LATE',
        ),
      ]);
      // status-today sin jornada: 404 (H2), por defecto en el entorno.
    }

    test('actualiza sede y turno, sedes, turno e historial de 30 días', () async {
      await env.signIn(branchId: null, shiftId: null);
      respondAll();

      await env.repository.refresh();

      final history = env.requested('GET', historyPath).single;
      expect(history.url.queryParameters['startDate'], '2026-09-24');
      expect(history.url.queryParameters['endDate'], '2026-10-24');
      expect((await env.session.getSession())!.shiftId, 's1');

      final schedule = (await env.repository.watchSchedule().first)!;
      expect(schedule.shift.gracePeriodMinutes, 15);
      expect(schedule.branch!.name, 'Sede Lima');
      expect(schedule.branch!.latitude, -12.0);
      expect(
        schedule.days.where((d) => !d.isWorkDay).map((d) => d.day),
        [WeekDay.sunday],
      );
      expect(await env.repository.findBranch('b1'), isNotNull);

      final rows = await env.repository.watchHistory().first;
      expect(rows.single.id.value, 'old');
      expect(rows.single.status, AttendanceStatus.late);
      expect(rows.single.syncedAt, env.clock);
      expect(await today(), isA<NotClockedIn>());
    });

    test('sedes y turno valen 24 h; asistencia siempre', () async {
      respondAll();

      await env.repository.refresh();
      await env.repository.refresh();

      expect(env.requested('GET', _branchesPath), hasLength(1));
      expect(env.requested('GET', _shiftPath), hasLength(1));
      expect(env.requested('GET', historyPath), hasLength(2));

      env.clock = env.clock.add(const Duration(hours: 24));
      await env.repository.refresh();

      expect(env.requested('GET', _branchesPath), hasLength(2));
      expect(env.requested('GET', _shiftPath), hasLength(2));
    });

    test('una sede sin coordenadas no entra a la caché de geocerca', () async {
      respondAll();
      env.responses['GET $_branchesPath'] = (_) => json([
        {'id': 'b1', 'name': 'Sin mapa', 'isActive': true},
      ]);

      await env.repository.refresh();

      expect(await env.repository.findBranch('b1'), isNull);
    });

    test('H2: status-today con jornada de ayer la guarda', () async {
      respondAll();
      env.responses['GET $statusPath'] = (_) => json(
        attendanceJson(id: 'nocturna', clockIn: '2026-09-01T03:00:00Z'),
      );

      await env.repository.refresh();

      expect(await env.db.attendanceDao.findById('nocturna'), isNotNull);
    });

    for (final status in [401, 403, 500]) {
      test('H2: un $status de status-today no se toma como sin jornada', () async {
        respondAll();
        env.responses['GET $statusPath'] = (_) => apiError(status);

        await expectLater(
          env.repository.refresh(),
          throwsA(
            isA<ApiException>().having((e) => e.httpStatus, 'http', status),
          ),
        );
        expect(await env.repository.watchHistory().first, hasLength(1));
      });
    }

    test('un 404 de history sí es un error', () async {
      respondAll();
      env.responses['GET $historyPath'] = (_) => apiError(404);

      await expectLater(
        env.repository.refresh(),
        throwsA(isA<ApiException>()),
      );
    });

    test('sin red sigue la caché y no lanza', () async {
      await saveAttendance();
      for (final path in [_profilePath, _branchesPath, _shiftPath, historyPath]) {
        env.responses['GET $path'] = offline;
      }

      await env.repository.refresh();

      expect(await env.repository.watchHistory().first, hasLength(1));
      expect((await env.session.getSession())!.branchId, 'b1');
    });

    test('un error de sedes o turno no impide leer la asistencia', () async {
      respondAll();
      env.responses['GET $_branchesPath'] = (_) => apiError(500);
      env.responses['GET $_shiftPath'] = (_) => apiError(403);

      await env.repository.refresh();

      expect(await env.repository.watchHistory().first, hasLength(1));
    });

    test('sin perfil laboral borra la sede y el turno', () async {
      env.responses['GET $_profilePath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = (_) => json([]);

      await env.repository.refresh();

      final session = (await env.session.getSession())!;
      expect(session.branchId, isNull);
      expect(session.shiftId, isNull);
      expect(await env.repository.watchSchedule().first, isNull);
    });

    test('un 500 del perfil conserva lo guardado', () async {
      env.responses['GET $_profilePath'] = (_) => apiError(500);
      env.responses['GET $historyPath'] = (_) => json([]);

      await env.repository.refresh();

      expect((await env.session.getSession())!.branchId, 'b1');
    });

    test('no pide lo que la sesión no permite', () async {
      await env.signIn(permissions: const []);

      await env.repository.refresh();

      expect(env.requests, isEmpty);
    });

    test('solo con read_own no pide sedes ni turno', () async {
      await env.signIn(permissions: const [Permission.attendanceReadOwn]);
      respondAll();

      await env.repository.refresh();

      expect(env.requested('GET', _branchesPath), isEmpty);
      expect(env.requested('GET', _shiftPath), isEmpty);
      expect(env.requested('GET', historyPath), hasLength(1));
    });
  });

  group('con SyncProcessor real', () {
    late SyncProcessor processor;
    late OperationHandlerRegistry registry;

    setUp(() {
      registerFallbackValue(0);
      registry = OperationHandlerRegistry()
        ..register(
          ClockInHandler.type,
          () => ClockInHandler(
            api: env.api,
            cache: env.cache,
            session: env.session,
            now: () => env.clock,
          ),
        )
        ..register(
          ClockOutHandler.type,
          () => ClockOutHandler(
            api: env.api,
            cache: env.cache,
            session: env.session,
            now: () => env.clock,
          ),
        );
      when(
        () => env.scheduler.requestSyncAt(any(), any()),
      ).thenAnswer((_) async {});
      processor = SyncProcessor(
        dao: env.db.pendingOperationDao,
        session: env.session,
        lock: CrossIsolateLock(database: env.db),
        handlers: registry,
        scheduler: env.scheduler,
        maxAttemptsMessage: 'No se pudo sincronizar',
        ensureFreshToken: env.session.getAuthToken,
        now: () => env.clock,
      );
    });

    test('envía ingreso y salida en orden, con sus horas capturadas', () async {
      env.connectivity.online = false;
      await env.repository.clockIn('b1', 's1', _location);
      env.clock = env.clock.add(const Duration(hours: 8));
      await env.repository.clockOut();

      env.responses['POST $clockInPath'] = (_) => json(attendanceJson(), 201);
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T22:00:00Z'));
      await processor.run();

      expect(env.requests.map((r) => r.url.path), [clockInPath, clockOutPath]);
      expect(
        env.requests.first.body,
        contains('"clockInTime":"2026-10-24T14:00:00.000Z"'),
      );
      expect(
        env.requests.last.body,
        contains('"clockOutTime":"2026-10-24T22:00:00.000Z"'),
      );
      expect(await env.pending(), isEmpty);
      expect(await today(), isA<Completed>());
    });

    test('con el ingreso en backoff, la salida espera sin enviarse', () async {
      env.connectivity.online = false;
      await env.repository.clockIn('b1', 's1', _location);
      await env.repository.clockOut();

      env.responses['POST $clockInPath'] = (_) => apiError(500);
      await processor.run();

      expect(env.requested('POST', clockOutPath), isEmpty);
      final statuses = (await env.pending()).map((o) => o.status);
      expect(statuses, everyElement('PENDING'));
    });

    test('salida encolada con el ingreso ya FAILED: falla con su mensaje y Reintentar reactiva', () async {
      env.connectivity.online = false;
      await env.repository.clockIn('b1', 's1', _location);
      env.responses['POST $clockInPath'] = (_) =>
          apiError(422, 'Estás a 350 m de la sede');
      await processor.run();
      expect((await env.pending()).single.status, 'FAILED');

      await env.repository.clockOut();
      await processor.run();

      final clockOut = (await env.pending()).firstWhere(
        (o) => o.type == ClockOutHandler.type,
      );
      expect(clockOut.status, 'FAILED');
      expect(clockOut.lastErrorMessage, 'Estás a 350 m de la sede');
      expect(env.requested('POST', clockOutPath), isEmpty);

      final ids = (await env.pending()).map((o) => o.id).toList();
      await env.db.pendingOperationDao.resetFailed(
        ids,
        env.clock.millisecondsSinceEpoch,
      );
      env.responses['POST $clockInPath'] = (_) => json(attendanceJson(), 201);
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T14:00:00Z'));
      await processor.run();

      expect(await env.pending(), isEmpty);
      expect(env.requested('POST', clockOutPath), hasLength(1));
    });
  });
}

Future<void> _eventually(bool Function() condition) async {
  for (var i = 0; i < 200 && !condition(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(condition(), isTrue);
}
