import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';

class Session {
  final String userId;
  final String email;
  final String fullName;
  final String tenantId;
  final String tenantName;
  final String? membershipId;
  final Set<String> permissions;

  /// `null`: sin plan conocido. No se oculta nada y decide el backend.
  final Plan? plan;

  /// La asignada por el backend o, si no hay, la elegida a mano (H33).
  final String? branchId;
  final String? shiftId;

  /// Sin perfil laboral y aún sin elegir sede (pantalla A5b).
  final bool needsBranchChoice;

  const Session({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.tenantId,
    required this.tenantName,
    required this.membershipId,
    required this.permissions,
    required this.plan,
    this.branchId,
    this.shiftId,
    this.needsBranchChoice = false,
  });

  bool has(Permission permission) => permissions.contains(permission.value);

  bool canUseTelemetry() =>
      has(Permission.telemetryIngest) && (plan?.iotTelemetryEnabled ?? true);

  /// Lectura de telemetría remota o fallas OBD-II: permiso de lectura y módulo en el plan.
  bool canReadTelemetry() =>
      (has(Permission.telemetryRead) || has(Permission.faultsRead)) &&
      (plan?.iotTelemetryEnabled ?? true);

  bool canUseAiDiagnostics() =>
      has(Permission.healthReportsGenerate) &&
      (plan?.aiDiagnosticsEnabled ?? true);

  bool canReadAiReports() =>
      has(Permission.healthReportsRead) && (plan?.aiDiagnosticsEnabled ?? true);

  /// `false` solo si el plan dice que la suscripción no está vigente.
  bool hasSubscriptionAccess() => plan?.accessGranted != false;

  /// `iam:branches:read` lo tienen todos los roles para ver geocerca y nombre de su sede. Cambiar
  /// de sede activa solo corresponde a quien administra sedes (`iam:branches:manage`) o a una
  /// cuenta sin perfil laboral fijo en una sede (`shiftId == null` y sin marcación propia, H33).
  bool canSwitchBranch() =>
      has(Permission.branchesRead) &&
      (has(Permission.branchesManage) ||
          (shiftId == null && !has(Permission.attendanceClockIn)));
}
