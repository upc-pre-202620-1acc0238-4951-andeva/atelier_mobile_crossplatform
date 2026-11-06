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
  final String? branchId;
  final String? shiftId;

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
  });

  bool has(Permission permission) => permissions.contains(permission.value);

  bool canUseTelemetry() =>
      has(Permission.telemetryIngest) && (plan?.iotTelemetryEnabled ?? true);

  bool canUseAiDiagnostics() =>
      has(Permission.healthReportsGenerate) &&
      (plan?.aiDiagnosticsEnabled ?? true);

  bool canReadAiReports() =>
      has(Permission.healthReportsRead) && (plan?.aiDiagnosticsEnabled ?? true);

  /// `false` solo si el plan dice que la suscripción no está vigente.
  bool hasSubscriptionAccess() => plan?.accessGranted != false;
}
