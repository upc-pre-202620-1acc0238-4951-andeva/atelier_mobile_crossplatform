import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';

/// Quien también marca su propia asistencia ve dos pestañas; quien solo supervisa, una lista.
enum TeamTab { team, mine }

/// "Equipo": asistencia de la sede hoy y descargos por revisar de los últimos 7 días. Ambas salen de
/// endpoints en línea (sin caché en Drift), así que el esqueleto se muestra hasta la primera respuesta.
class AdminAttendanceUiState {
  /// Día de Lima `yyyy-MM-dd`.
  final String today;
  final TeamTab tab;
  final String? branchName;
  final Session? session;
  final List<TeamAttendance> records;
  final List<TeamAttendance> justifications;

  /// Descargos ya resueltos (id → aprobado) que aún muestran su resultado antes de retirarse de la lista.
  final Map<String, bool> resolved;

  /// Días de descargos cuya consulta falló (H32): el resultado es parcial y se avisa.
  final int failedJustificationDays;
  final TeamAttendance? reviewing;
  final bool isSubmittingReview;
  final UiText? reviewError;
  final bool isRefreshing;
  final bool hasLoaded;
  final bool isOnline;
  final UiText? error;
  final bool canAuditAll;
  final bool canApproveJustifications;
  final bool canClockIn;

  const AdminAttendanceUiState({
    this.today = '',
    this.tab = TeamTab.team,
    this.branchName,
    this.session,
    this.records = const [],
    this.justifications = const [],
    this.resolved = const {},
    this.failedJustificationDays = 0,
    this.reviewing,
    this.isSubmittingReview = false,
    this.reviewError,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.isOnline = true,
    this.error,
    this.canAuditAll = false,
    this.canApproveJustifications = false,
    this.canClockIn = false,
  });

  int get onShiftCount =>
      records.where((r) => r.clockOut == null && r.status != AttendanceStatus.absent).length;
  int get onTimeCount => records.where((r) => r.status == AttendanceStatus.onTime).length;
  int get lateCount => records.where((r) => r.status == AttendanceStatus.late).length;
  int get absentCount => records.where((r) => r.status == AttendanceStatus.absent).length;
  bool get showSkeleton => !hasLoaded && records.isEmpty;

  /// Hay pestañas solo cuando la misma cuenta supervisa y marca.
  bool get hasTabs => canAuditAll && canClockIn;

  /// La asistencia del día del colaborador de un descargo, si la trae (H36): de ahí sale su nombre; si
  /// no, se usa su cargo.
  TeamAttendance? recordFor(TeamAttendance item) {
    for (final record in records) {
      if (record.membershipId == item.membershipId) return record;
    }
    return null;
  }

  AdminAttendanceUiState copyWith({
    String? today,
    TeamTab? tab,
    String? branchName,
    Session? session,
    List<TeamAttendance>? records,
    List<TeamAttendance>? justifications,
    Map<String, bool>? resolved,
    int? failedJustificationDays,
    TeamAttendance? reviewing,
    bool clearReviewing = false,
    bool? isSubmittingReview,
    UiText? reviewError,
    bool clearReviewError = false,
    bool? isRefreshing,
    bool? hasLoaded,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canAuditAll,
    bool? canApproveJustifications,
    bool? canClockIn,
  }) {
    return AdminAttendanceUiState(
      today: today ?? this.today,
      tab: tab ?? this.tab,
      branchName: branchName ?? this.branchName,
      session: session ?? this.session,
      records: records ?? this.records,
      justifications: justifications ?? this.justifications,
      resolved: resolved ?? this.resolved,
      failedJustificationDays: failedJustificationDays ?? this.failedJustificationDays,
      reviewing: clearReviewing ? null : reviewing ?? this.reviewing,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      reviewError: clearReviewError ? null : reviewError ?? this.reviewError,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canAuditAll: canAuditAll ?? this.canAuditAll,
      canApproveJustifications: canApproveJustifications ?? this.canApproveJustifications,
      canClockIn: canClockIn ?? this.canClockIn,
    );
  }
}
