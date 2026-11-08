import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../support/step9_test_env.dart';

const _daily = 'GET /api/v1/hr/attendances/branch/b1/daily';
const _audit = [Permission.attendanceAuditAll];

void main() {
  late Step9TestEnv env;

  setUp(() async => env = await Step9TestEnv.create());
  tearDown(() => env.close());

  test('sin audit_all, diario y bandeja vacíos sin llamar', () async {
    await env.signIn(permissions: const [Permission.justificationsApprove]);
    expect(await env.team.getBranchDaily('2026-11-06'), isEmpty);
    final pending = await env.team.getPendingJustifications(7);
    expect(pending.items, isEmpty);
    expect(env.requests, isEmpty);
  });

  test('days < 1 es un error de quien llama', () async {
    await env.signIn(permissions: _audit);
    expect(() => env.team.getPendingJustifications(0), throwsArgumentError);
  });

  test('sin sede falla sin llamar', () async {
    await env.signIn(permissions: _audit, branchId: null);
    await expectLater(
      env.team.getBranchDaily('2026-11-06'),
      throwsA(isA<MissingBranchException>()),
    );
    expect(env.requests, isEmpty);
  });

  test(
    'diario de la sede: día ausente sin ingreso; puesto solo con members:read',
    () async {
      await env.signIn(
        permissions: const [
          Permission.attendanceAuditAll,
          Permission.membersRead,
        ],
      );
      env.responses[_daily] = (request) {
        expect(request.url.queryParameters['date'], '2026-11-06');
        return json([
          attendanceJson(
            id: 'a0',
            membershipId: 'm2',
            clockIn: null,
            status: 'ABSENT',
            justificationStatus: null,
          ),
          attendanceJson(),
        ]);
      };
      env.responses['GET /api/v1/hr/employees/branch/b1'] = (_) => json([
        {
          'id': 'e1',
          'branchId': 'b1',
          'membershipId': 'm1',
          'jobTitle': 'Mecánico',
        },
      ]);
      final rows = await env.team.getBranchDaily('2026-11-06');
      expect(rows.map((r) => r.id), ['a1', 'a0']);
      expect(rows.first.jobTitle, 'Mecánico');
      expect(rows.last.status, AttendanceStatus.absent);
      expect(rows.last.jobTitle, isNull);
    },
  );

  test('una fila mal formada hace fallar la lectura', () async {
    await env.signIn(permissions: _audit);
    env.responses[_daily] = (_) => json([attendanceJson(clockIn: 'ayer')]);
    await expectLater(
      env.team.getBranchDaily('2026-11-06'),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'bandeja: 7 días de Lima, solo PENDING, días fallidos en failedDates',
    () async {
      await env.signIn(permissions: _audit);
      env.responses[_daily] = (request) =>
          switch (request.url.queryParameters['date']) {
            '2026-11-06' => json([
              attendanceJson(id: 'early', clockIn: '2026-11-06T13:00:00Z'),
              attendanceJson(id: 'late', clockIn: '2026-11-06T14:00:00Z'),
              attendanceJson(id: 'ok', justificationStatus: 'APPROVED'),
            ]),
            '2026-11-04' => apiError(500),
            '2026-11-03' => http.Response('<html>', 200),
            '2026-11-01' => json([
              attendanceJson(id: 'old', clockIn: '2026-11-01T13:00:00Z'),
            ]),
            _ => json([]),
          };
      final pending = await env.team.getPendingJustifications(7);
      expect(
        env.requested('GET', '/api/v1/hr/attendances/branch/b1/daily'),
        hasLength(7),
      );
      expect(pending.items.map((i) => i.id), ['late', 'early', 'old']);
      expect(pending.failedDates, ['2026-11-04', '2026-11-03']);
    },
  );

  test('si fallan todos los días, el error del primero', () async {
    await env.signIn(permissions: _audit);
    env.responses[_daily] = (_) => apiError(503, 'Mantenimiento');
    await expectLater(
      env.team.getPendingJustifications(3),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'm', 'Mantenimiento'),
      ),
    );
  });

  test('el día de Lima no cambia hasta las 05:00 UTC', () async {
    await env.signIn(permissions: _audit);
    env.clock = DateTime.utc(2026, 11, 7, 3);
    env.responses[_daily] = (_) => json([]);
    await env.team.getPendingJustifications(1);
    expect(env.requests.single.url.queryParameters['date'], '2026-11-06');
  });

  test(
    'asistencia del colaborador: busca en 30 días; null si no está',
    () async {
      await env.signIn(permissions: _audit);
      env.responses['GET /api/v1/hr/attendances/employee/m1/history'] =
          (request) {
            expect(request.url.queryParameters, {
              'startDate': '2026-10-08',
              'endDate': '2026-11-06',
            });
            return json([attendanceJson()]);
          };
      expect((await env.team.getCollaboratorAttendance('m1', 'a1'))?.id, 'a1');
      expect(await env.team.getCollaboratorAttendance('m1', 'zz'), isNull);
    },
  );

  test(
    'aprobar devuelve la asistencia; un descargo ya revisado da su message',
    () async {
      await env.signIn(permissions: const [Permission.justificationsApprove]);
      env.responses['POST /api/v1/hr/attendances/a1/justification/approve'] =
          (_) => json(
            attendanceJson(status: 'EXCUSED', justificationStatus: 'APPROVED'),
          );
      env.responses['POST /api/v1/hr/attendances/a2/justification/reject'] = (
        _,
      ) => apiError(409, 'Ya revisado');
      final approved = await env.team.approveJustification('a1');
      expect(approved.status, AttendanceStatus.excused);
      expect(approved.awaitsReview, isFalse);
      await expectLater(
        env.team.rejectJustification('a2'),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'm', 'Ya revisado'),
        ),
      );
    },
  );
}
