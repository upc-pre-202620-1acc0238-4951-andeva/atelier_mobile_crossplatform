import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_in_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_out_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/justification_handler.dart';
import 'package:flutter_test/flutter_test.dart' hide Retry;

import '../support/attendance_test_env.dart';

PendingOperationEntity _operation(String type, String payload) {
  return PendingOperationEntity(
    id: 'op1',
    type: type,
    payload: payload,
    dedupeKey: 'key',
    userId: 'u1',
    tenantId: 't1',
    status: 'SYNCING',
    attempts: 0,
    nextAttemptAt: 0,
    createdAt: 0,
  );
}

const _clockInPayload =
    '{"branchId":"b1","shiftId":"s1","latitude":-12.0,"longitude":-77.0,'
    '"clockInTime":"2026-10-24T14:00:00.000Z"}';

/// Salida capturada a las 07:00 de Lima del 24.
String _clockOutPayload({String? attendanceId}) {
  final id = attendanceId == null ? '' : '"attendanceId":"$attendanceId",';
  return '{$id"clockOutTime":"2026-10-24T12:00:00.000Z"}';
}

void main() {
  late AttendanceTestEnv env;

  setUp(() async {
    env = AttendanceTestEnv.create();
    await env.signIn();
  });
  tearDown(() => env.close());

  group('CLOCK_IN', () {
    ClockInHandler handler() => ClockInHandler(
      api: env.api,
      cache: env.cache,
      session: env.session,
      now: () => env.clock,
    );

    Future<OperationResult> send() {
      return handler().send(_operation('CLOCK_IN', _clockInPayload));
    }

    test('2xx guarda la jornada y envía la hora capturada', () async {
      env.responses['POST $clockInPath'] = (_) => json(attendanceJson(), 201);

      expect(await send(), isA<Applied>());

      expect(
        env.requested('POST', clockInPath).single.body,
        contains('"clockInTime":"2026-10-24T14:00:00.000Z"'),
      );
      expect(await env.db.attendanceDao.findById('a1'), isNotNull);
    });

    test('409 ya está aplicada y recarga el día capturado', () async {
      env.responses['POST $clockInPath'] = (_) => apiError(409);
      env.responses['GET $historyPath'] = (_) => json([attendanceJson()]);

      expect(await send(), isA<Applied>());

      final history = env.requested('GET', historyPath).single;
      expect(history.url.queryParameters['startDate'], '2026-10-24');
      expect(await env.db.attendanceDao.findById('a1'), isNotNull);
    });

    test('un fallo de caché tras aplicar no la vuelve a enviar', () async {
      env.responses['POST $clockInPath'] = (_) => apiError(409);
      env.responses['GET $historyPath'] = offline;

      expect(await send(), isA<Applied>());
    });

    test('422 fuera de geocerca queda Failed con el message', () async {
      env.responses['POST $clockInPath'] = (_) =>
          apiError(422, 'Estás a 350 m de la sede');

      final result = await send();

      expect(result, isA<Failed>());
      expect((result as Failed).message, 'Estás a 350 m de la sede');
    });

    test('sin red o 5xx se reintenta', () async {
      env.responses['POST $clockInPath'] = offline;
      expect(await send(), isA<Retry>());

      env.responses['POST $clockInPath'] = (_) => apiError(500);
      expect(await send(), isA<Retry>());
    });
  });

  group('CLOCK_OUT', () {
    ClockOutHandler handler() => ClockOutHandler(
      api: env.api,
      cache: env.cache,
      session: env.session,
      now: () => env.clock,
    );

    Future<OperationResult> send({String? attendanceId}) {
      return handler().send(
        _operation('CLOCK_OUT', _clockOutPayload(attendanceId: attendanceId)),
      );
    }

    test('2xx guarda la salida', () async {
      env.responses['POST $clockOutPath'] = (_) =>
          json(attendanceJson(clockOut: '2026-10-24T12:00:00Z'));

      expect(await send(attendanceId: 'a1'), isA<Applied>());

      final row = await env.db.attendanceDao.findById('a1');
      expect(row!.clockOut, isNotNull);
    });

    for (final status in [400, 404]) {
      test('$status con la salida ya registrada queda aplicada', () async {
        env.responses['POST $clockOutPath'] = (_) => apiError(status);
        env.responses['GET $historyPath'] = (_) =>
            json([attendanceJson(clockOut: '2026-10-24T12:00:00Z')]);

        expect(await send(attendanceId: 'a1'), isA<Applied>());
      });

      test('$status sin salida registrada queda Failed con su message', () async {
        env.responses['POST $clockOutPath'] = (_) =>
            apiError(status, 'Sin jornada abierta');
        env.responses['GET $historyPath'] = (_) => json([attendanceJson()]);

        final result = await send(attendanceId: 'a1');

        expect(result, isA<Failed>());
        expect((result as Failed).message, 'Sin jornada abierta');
      });
    }

    test('otra jornada cerrada no cuenta si el id no coincide', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = (_) => json([
        attendanceJson(id: 'otra', clockOut: '2026-10-24T12:00:00Z'),
      ]);

      expect(await send(attendanceId: 'a1'), isA<Failed>());
    });

    test('verifica también el día anterior: jornada nocturna con id', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(400);
      env.responses['GET $historyPath'] = (request) {
        // Como `history` filtra por ingreso, la jornada de anoche solo sale si se pide ayer.
        return request.url.queryParameters['startDate'] == '2026-10-23'
            ? json([
                attendanceJson(
                  clockIn: '2026-10-24T03:00:00Z',
                  clockOut: '2026-10-24T12:00:00Z',
                ),
              ])
            : json([]);
      };

      expect(await send(attendanceId: 'a1'), isA<Applied>());
    });

    test('sin id: la jornada nocturna ya aplicada se reconoce por su salida', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(400);
      env.responses['GET $historyPath'] = (_) => json([
        attendanceJson(
          clockIn: '2026-10-24T03:00:00Z',
          clockOut: '2026-10-24T12:00:00Z',
        ),
      ]);

      expect(await send(), isA<Applied>());
    });

    test('sin id: la jornada cerrada de ayer no se confunde con esta salida', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = (_) => json([
        attendanceJson(
          clockIn: '2026-10-23T13:00:00Z',
          clockOut: '2026-10-23T22:00:00Z',
        ),
      ]);

      expect(await send(), isA<Failed>(), reason: 'perdería la marcación');
    });

    test('sin red para verificar se reintenta', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = offline;

      expect(await send(attendanceId: 'a1'), isA<Retry>());
    });

    test('500 al verificar se reintenta', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = (_) => apiError(500);

      expect(await send(attendanceId: 'a1'), isA<Retry>());
    });

    test('401 al verificar detiene la vuelta', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(404);
      env.responses['GET $historyPath'] = (_) => apiError(401);

      expect(await send(attendanceId: 'a1'), isA<Unauthorized>());
    });

    test('403 al verificar deja el error original', () async {
      env.responses['POST $clockOutPath'] = (_) =>
          apiError(404, 'Sin jornada abierta');
      env.responses['GET $historyPath'] = (_) => apiError(403);

      final result = await send(attendanceId: 'a1');

      expect((result as Failed).message, 'Sin jornada abierta');
    });

    test('un 422 no es ambiguo: no consulta el historial', () async {
      env.responses['POST $clockOutPath'] = (_) => apiError(422);

      expect(await send(attendanceId: 'a1'), isA<Failed>());
      expect(env.requested('GET', historyPath), isEmpty);
    });
  });

  group('SUBMIT_JUSTIFICATION', () {
    const path = '/api/v1/hr/attendances/a1/justification';

    JustificationHandler handler() => JustificationHandler(
      api: env.api,
      cache: env.cache,
      dao: env.db.attendanceDao,
      session: env.session,
    );

    Future<OperationResult> send() {
      return handler().send(
        _operation(
          'SUBMIT_JUSTIFICATION',
          '{"attendanceId":"a1","reason":"Tráfico"}',
        ),
      );
    }

    test('envía solo el motivo: el id va en la ruta', () async {
      env.responses['POST $path'] = (_) =>
          json(attendanceJson(status: 'LATE', justificationStatus: 'PENDING'));

      expect(await send(), isA<Applied>());

      expect(env.requested('POST', path).single.body, '{"reason":"Tráfico"}');
      final row = await env.db.attendanceDao.findById('a1');
      expect(row!.justificationStatus, 'PENDING');
    });

    test('422 ya está justificada y recarga el día de esa jornada', () async {
      await env.cache.save(
        AttendanceDto.fromJson(attendanceJson(status: 'LATE')),
        'm1',
      );
      env.responses['POST $path'] = (_) => apiError(422);
      env.responses['GET $historyPath'] = (_) =>
          json([attendanceJson(status: 'EXCUSED')]);

      expect(await send(), isA<Applied>());

      final history = env.requested('GET', historyPath).single;
      expect(history.url.queryParameters['startDate'], '2026-10-24');
      final row = await env.db.attendanceDao.findById('a1');
      expect(row!.status, 'EXCUSED');
    });
  });
}
