/// Cuenta de la sesión. La app no conoce el nombre del rol (solo sus permisos), así que no se muestra ninguno.
/// [planTier] es el nivel tal como lo envía el backend; vacío si la sesión no trae plan.
class ProfileUiState {
  final String fullName;
  final String email;
  final String tenantName;
  final String? branchId;
  final String? branchName;
  final bool canChangeBranch;
  final String planTier;
  final bool iotTelemetryEnabled;
  final bool aiDiagnosticsEnabled;
  final int pendingCount;
  final int unreadNotificationsCount;

  /// Versión de la app (`pubspec.yaml`); vacía hasta leerla.
  final String version;

  /// Hoja de confirmación de "Cerrar sesión" abierta (US04).
  final bool confirmingSignOut;

  /// Cerrando sesión: evita un segundo cierre mientras se revocan los tokens.
  final bool signingOut;

  const ProfileUiState({
    this.fullName = '',
    this.email = '',
    this.tenantName = '',
    this.branchId,
    this.branchName,
    this.canChangeBranch = false,
    this.planTier = '',
    this.iotTelemetryEnabled = false,
    this.aiDiagnosticsEnabled = false,
    this.pendingCount = 0,
    this.unreadNotificationsCount = 0,
    this.version = '',
    this.confirmingSignOut = false,
    this.signingOut = false,
  });

  bool get hasPlan => planTier.isNotEmpty && planTier.toLowerCase() != 'none';

  ProfileUiState copyWith({
    String? fullName,
    String? email,
    String? tenantName,
    String? branchId,
    String? branchName,
    bool? canChangeBranch,
    String? planTier,
    bool? iotTelemetryEnabled,
    bool? aiDiagnosticsEnabled,
    int? pendingCount,
    int? unreadNotificationsCount,
    String? version,
    bool? confirmingSignOut,
    bool? signingOut,
  }) {
    return ProfileUiState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      tenantName: tenantName ?? this.tenantName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      canChangeBranch: canChangeBranch ?? this.canChangeBranch,
      planTier: planTier ?? this.planTier,
      iotTelemetryEnabled: iotTelemetryEnabled ?? this.iotTelemetryEnabled,
      aiDiagnosticsEnabled: aiDiagnosticsEnabled ?? this.aiDiagnosticsEnabled,
      pendingCount: pendingCount ?? this.pendingCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      version: version ?? this.version,
      confirmingSignOut: confirmingSignOut ?? this.confirmingSignOut,
      signingOut: signingOut ?? this.signingOut,
    );
  }
}
