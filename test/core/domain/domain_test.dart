import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session(Set<String> permissions, Plan? plan) => Session(
  userId: 'u1',
  email: 'm@taller.pe',
  fullName: 'Mecánico',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: permissions,
  plan: plan,
);

Plan _plan({required bool iot, required bool ai, bool access = true}) => Plan(
  tier: 'PRO',
  status: 'ACTIVE',
  accessGranted: access,
  iotTelemetryEnabled: iot,
  aiDiagnosticsEnabled: ai,
);

void main() {
  group('Session', () {
    test('decide por permiso y no por nombre de rol', () {
      expect(
        _session({'ROLE_MECHANIC'}, null).has(Permission.tasksTrackTime),
        isFalse,
      );
      expect(
        _session({
          'operations:tasks:track_time',
        }, null).has(Permission.tasksTrackTime),
        isTrue,
      );
    });

    test('telemetría requiere permiso y plan con IoT', () {
      final permissions = {Permission.telemetryIngest.value};
      expect(
        _session(permissions, _plan(iot: true, ai: false)).canUseTelemetry(),
        isTrue,
      );
      expect(
        _session(permissions, _plan(iot: false, ai: true)).canUseTelemetry(),
        isFalse,
      );
      expect(
        _session({}, _plan(iot: true, ai: true)).canUseTelemetry(),
        isFalse,
      );
    });

    test('sin plan conocido no se oculta el módulo', () {
      expect(
        _session({Permission.telemetryIngest.value}, null).canUseTelemetry(),
        isTrue,
      );
      expect(
        _session({
          Permission.healthReportsGenerate.value,
        }, null).canUseAiDiagnostics(),
        isTrue,
      );
    });

    test('aviso de suscripción solo con accessGranted false', () {
      expect(
        _session(
          {},
          _plan(iot: true, ai: true, access: false),
        ).hasSubscriptionAccess(),
        isFalse,
      );
      expect(
        _session({}, _plan(iot: true, ai: true)).hasSubscriptionAccess(),
        isTrue,
      );
      expect(_session({}, null).hasSubscriptionAccess(), isTrue);
    });

    test('informe IA requiere plan con IA', () {
      final permissions = {Permission.healthReportsGenerate.value};
      expect(
        _session(
          permissions,
          _plan(iot: true, ai: false),
        ).canUseAiDiagnostics(),
        isFalse,
      );
      expect(
        _session(
          permissions,
          _plan(iot: false, ai: true),
        ).canUseAiDiagnostics(),
        isTrue,
      );
    });

    test('canReadAiReports exige permiso y plan con IA', () {
      final permissions = {Permission.healthReportsRead.value};
      expect(
        _session(permissions, _plan(iot: false, ai: true)).canReadAiReports(),
        isTrue,
      );
      expect(
        _session(permissions, _plan(iot: true, ai: false)).canReadAiReports(),
        isFalse,
      );
      expect(
        _session({
          Permission.healthReportsGenerate.value,
        }, _plan(iot: true, ai: true)).canReadAiReports(),
        isFalse,
      );
      expect(_session(permissions, null).canReadAiReports(), isTrue);
    });
  });

  group('BusinessTime', () {
    test('a las 23:30 en Lima sigue siendo el mismo día aunque en UTC no', () {
      final clock = BusinessTime(now: () => DateTime.utc(2026, 10, 21, 4, 30));
      expect(clock.today(), '2026-10-20');
    });

    test('el inicio del día de Lima son las 05:00 UTC', () {
      expect(
        BusinessTime.startOfDay('2026-10-20'),
        DateTime.utc(2026, 10, 20, 5),
      );
    });
  });

  group('Money', () {
    test('conserva los céntimos', () {
      expect(Money.of('118.10', Money.pen).amount.toString(), '118.1');
    });

    test('rechaza monto negativo y moneda desconocida', () {
      expect(() => Money.of('-1', Money.pen), throwsArgumentError);
      expect(() => Money.of('1', 'EUR'), throwsArgumentError);
    });
  });
}
