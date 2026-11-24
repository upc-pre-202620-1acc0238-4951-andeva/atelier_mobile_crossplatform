import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:flutter_test/flutter_test.dart';

Session _session(Set<Permission> permissions, {String? shiftId, Plan? plan}) {
  return Session(
    userId: 'u1',
    email: 'm@taller.pe',
    fullName: 'Nombre',
    tenantId: 't1',
    tenantName: 'Taller',
    membershipId: 'm1',
    permissions: {for (final p in permissions) p.value},
    plan: plan,
    shiftId: shiftId,
  );
}

void main() {
  group('canSwitchBranch', () {
    test('sin iam:branches:read nunca', () {
      expect(_session({Permission.branchesManage}).canSwitchBranch(), isFalse);
      expect(_session({}).canSwitchBranch(), isFalse);
    });

    test('quien administra sedes cambia aunque tenga turno', () {
      expect(
        _session({
          Permission.branchesRead,
          Permission.branchesManage,
          Permission.attendanceClockIn,
        }, shiftId: 's1').canSwitchBranch(),
        isTrue,
      );
    });

    test('una cuenta sin turno ni marcación propia cambia (H33)', () {
      expect(_session({Permission.branchesRead}).canSwitchBranch(), isTrue);
    });

    test('quien marca asistencia o tiene turno queda en su sede', () {
      expect(
        _session({
          Permission.branchesRead,
          Permission.attendanceClockIn,
        }).canSwitchBranch(),
        isFalse,
      );
      expect(
        _session({Permission.branchesRead}, shiftId: 's1').canSwitchBranch(),
        isFalse,
      );
    });
  });

  group('canReadTelemetry', () {
    const noIot = Plan(
      tier: 'BASIC',
      status: 'ACTIVE',
      accessGranted: true,
      iotTelemetryEnabled: false,
      aiDiagnosticsEnabled: false,
    );

    test('lectura de telemetría o de fallas, con el plan que lo incluye', () {
      expect(_session({Permission.telemetryRead}).canReadTelemetry(), isTrue);
      expect(_session({Permission.faultsRead}).canReadTelemetry(), isTrue);
      expect(_session({Permission.devicesRead}).canReadTelemetry(), isFalse);
    });

    test('un plan sin IoT lo oculta', () {
      expect(
        _session({Permission.telemetryRead}, plan: noIot).canReadTelemetry(),
        isFalse,
      );
    });
  });

  test('alias de permisos apuntan al mismo valor', () {
    expect(Permission.tasksSuspend, Permission.tasksHoldValidate);
    expect(Permission.baysAssign, Permission.baysReassign);
    expect(Permission.inventoryAlertsRead, Permission.alertsRead);
    expect(Permission.obdDevicesRead, Permission.devicesRead);
    expect(Permission.obdDevicesRegister, Permission.devicesRegister);
  });
}
