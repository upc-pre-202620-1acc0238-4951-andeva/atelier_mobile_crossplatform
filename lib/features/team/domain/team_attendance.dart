import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';

/// Asistencia de un colaborador vista por la jefatura (US10). [clockIn] falta en un día `ABSENT`
/// (H44). [jobTitle] es el único nombre disponible y solo llega con `iam:members:read` (H32).
class TeamAttendance {
  final String id;
  final String membershipId;
  final String branchId;
  final String? shiftId;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus? status;
  final double? distanceToBranchMeters;
  final int? workedMinutes;
  final int? overtimeMinutes;
  final String? justificationReason;
  final JustificationStatus? justificationStatus;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? jobTitle;

  const TeamAttendance({
    required this.id,
    required this.membershipId,
    required this.branchId,
    this.shiftId,
    this.clockIn,
    this.clockOut,
    this.status,
    this.distanceToBranchMeters,
    this.workedMinutes,
    this.overtimeMinutes,
    this.justificationReason,
    this.justificationStatus,
    this.reviewedBy,
    this.reviewedAt,
    this.jobTitle,
  });

  bool get awaitsReview => justificationStatus == JustificationStatus.pending;

  TeamAttendance withJobTitle(String? title) {
    return TeamAttendance(
      id: id,
      membershipId: membershipId,
      branchId: branchId,
      shiftId: shiftId,
      clockIn: clockIn,
      clockOut: clockOut,
      status: status,
      distanceToBranchMeters: distanceToBranchMeters,
      workedMinutes: workedMinutes,
      overtimeMinutes: overtimeMinutes,
      justificationReason: justificationReason,
      justificationStatus: justificationStatus,
      reviewedBy: reviewedBy,
      reviewedAt: reviewedAt,
      jobTitle: title,
    );
  }
}

/// Bandeja de descargos (H32). [failedDates] no vacío significa "faltan días": avisar y ofrecer
/// reintentar.
class PendingJustifications {
  final List<TeamAttendance> items;
  final List<String> failedDates;

  const PendingJustifications({required this.items, required this.failedDates});
}
