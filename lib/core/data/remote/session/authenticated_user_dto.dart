/// `AuthenticatedUserResource` de docs/api/iam.md.
class AuthenticatedUserDto {
  final String userId;
  final String email;
  final String? fullName;
  final String token;
  final TenantSummaryDto? activeTenant;
  final List<String>? permissions;
  final String refreshToken;
  final String? membershipId;
  final SessionPlanDto? plan;

  const AuthenticatedUserDto({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.token,
    required this.activeTenant,
    required this.permissions,
    required this.refreshToken,
    required this.membershipId,
    required this.plan,
  });

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    final tenant = json['activeTenant'] as Map<String, dynamic>?;
    final plan = json['plan'] as Map<String, dynamic>?;
    return AuthenticatedUserDto(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      token: json['token'] as String,
      activeTenant: tenant == null ? null : TenantSummaryDto.fromJson(tenant),
      permissions: (json['permissions'] as List?)?.cast<String>(),
      refreshToken: json['refreshToken'] as String,
      membershipId: json['membershipId'] as String?,
      plan: plan == null ? null : SessionPlanDto.fromJson(plan),
    );
  }
}

class TenantSummaryDto {
  final String id;
  final String? name;

  const TenantSummaryDto({required this.id, required this.name});

  factory TenantSummaryDto.fromJson(Map<String, dynamic> json) {
    return TenantSummaryDto(
      id: json['id'] as String,
      name: json['name'] as String?,
    );
  }
}

class SessionPlanDto {
  final String? tier;
  final String? status;
  final bool accessGranted;
  final bool iotTelemetryEnabled;
  final bool aiDiagnosticsEnabled;

  const SessionPlanDto({
    required this.tier,
    required this.status,
    required this.accessGranted,
    required this.iotTelemetryEnabled,
    required this.aiDiagnosticsEnabled,
  });

  factory SessionPlanDto.fromJson(Map<String, dynamic> json) {
    return SessionPlanDto(
      tier: json['tier'] as String?,
      status: json['status'] as String?,
      accessGranted: json['accessGranted'] as bool,
      iotTelemetryEnabled: json['iotTelemetryEnabled'] as bool,
      aiDiagnosticsEnabled: json['aiDiagnosticsEnabled'] as bool,
    );
  }
}
