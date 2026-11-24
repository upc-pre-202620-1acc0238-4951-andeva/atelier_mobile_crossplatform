import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/date_format.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Textos y marcas compartidos por "Hoy" y "Equipo" (en Android viven duplicados en cada pantalla).

/// Título del descargo según el estado de la jornada.
String justificationTitle(AppLocalizations strings, AttendanceStatus? status) {
  return switch (status) {
    AttendanceStatus.late => strings.todayDecisionJustificationLate,
    AttendanceStatus.absent => strings.todayDecisionJustificationAbsent,
    _ => strings.todayDecisionJustification,
  };
}

/// El backend no envía el nombre del colaborador (H36): se identifica por [label] o por su cargo, y la
/// fecha de la jornada.
String whoAndWhen(AppLocalizations strings, TeamAttendance item, [String? label]) {
  final who = label ?? item.jobTitle ?? strings.todayCollaboratorFallback;
  final clockIn = item.clockIn;
  return [who, ?clockIn?.formatLimaDate()].join(' · ');
}

/// Nombre con el que se lista a un colaborador: el de la sesión si es el propio, su cargo si el
/// backend lo dio, o el final de su `membershipId`.
String collaboratorLabel(
  AppLocalizations strings,
  TeamAttendance attendance,
  Session? session,
) {
  final membershipId = attendance.membershipId;
  if (session != null && membershipId == session.membershipId) {
    return session.fullName;
  }
  final jobTitle = attendance.jobTitle;
  if (jobTitle != null && jobTitle.trim().isNotEmpty) return jobTitle;
  if (membershipId.trim().isEmpty) return strings.todayCollaboratorFallback;
  final tail = membershipId.length > 4
      ? membershipId.substring(membershipId.length - 4)
      : membershipId;
  return strings.teamCollaboratorWithId(tail);
}

extension TeamAttendanceStatus on TeamAttendance {
  /// Sigue abierta: ingresó y no marcó salida.
  bool get isOpen => clockOut == null;
}

String attendanceStatusLabel(AppLocalizations strings, AttendanceStatus status) {
  return switch (status) {
    AttendanceStatus.onTime => strings.teamStatusOnTime,
    AttendanceStatus.late => strings.teamStatusLate,
    AttendanceStatus.absent => strings.teamStatusAbsent,
    AttendanceStatus.excused => strings.teamStatusExcused,
  };
}

ChipKind attendanceStatusChipKind(AttendanceStatus status) {
  return switch (status) {
    AttendanceStatus.onTime || AttendanceStatus.excused => ChipKind.ok,
    AttendanceStatus.late => ChipKind.warn,
    AttendanceStatus.absent => ChipKind.bad,
  };
}

String orderNumberLabel(AppLocalizations strings, WorkOrder order) {
  final number = order.internalNumber;
  return number == null
      ? strings.todayOrderNoNumber
      : strings.todayOrderNumber(number);
}

String workOrderStatusLabel(AppLocalizations strings, WorkOrderStatus? status) {
  return switch (status) {
    WorkOrderStatus.draft => strings.orderStatusDraft,
    WorkOrderStatus.inProgress => strings.orderStatusInProgress,
    WorkOrderStatus.completed => strings.orderStatusCompleted,
    WorkOrderStatus.paid => strings.orderStatusPaid,
    WorkOrderStatus.canceled => strings.orderStatusCanceled,
    null => strings.orderStatusUnknown,
  };
}

ChipKind workOrderStatusChipKind(WorkOrderStatus? status) {
  return switch (status) {
    WorkOrderStatus.inProgress => ChipKind.info,
    WorkOrderStatus.completed || WorkOrderStatus.paid => ChipKind.ok,
    WorkOrderStatus.canceled => ChipKind.bad,
    WorkOrderStatus.draft || null => ChipKind.idle,
  };
}
