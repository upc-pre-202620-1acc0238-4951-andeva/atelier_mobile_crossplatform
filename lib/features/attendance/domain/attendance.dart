import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';

/// Una jornada (`AttendanceResource` de docs/api/hr.md). Los minutos los calcula el backend al
/// marcar la salida.
class Attendance {
  final AttendanceId id;
  final String branchId;
  final String shiftId;
  final DateTime clockIn;
  final DateTime? clockOut;

  /// `null` si el backend envía un estado nuevo.
  final AttendanceStatus? status;
  final double distanceToBranchMeters;
  final int? workedMinutes;
  final int? regularMinutes;
  final int? overtimeMinutes;
  final String? justificationReason;
  final JustificationStatus? justificationStatus;

  /// Última lectura del backend, para "Actualizado hace N min" (06 §4).
  final DateTime syncedAt;

  const Attendance({
    required this.id,
    required this.branchId,
    required this.shiftId,
    required this.clockIn,
    required this.clockOut,
    required this.status,
    required this.distanceToBranchMeters,
    required this.workedMinutes,
    required this.regularMinutes,
    required this.overtimeMinutes,
    required this.justificationReason,
    required this.justificationStatus,
    required this.syncedAt,
  });

  bool get isOpen => clockOut == null;
}
