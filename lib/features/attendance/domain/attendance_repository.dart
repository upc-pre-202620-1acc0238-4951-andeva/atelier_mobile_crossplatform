import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';

/// Asistencia propia (US06–US10). Offline-first: red → Drift → UI; marcaciones y descargos sin red
/// van a la cola.
abstract class AttendanceRepository {
  Stream<TodayAttendance> watchToday();

  /// Últimos 30 días, del más reciente al más antiguo.
  Stream<List<Attendance>> watchHistory();

  Stream<WeeklySchedule?> watchSchedule();

  /// Perfil laboral, sedes, turno y asistencias. Sin red sigue la caché; lanza `ApiException` solo
  /// si no se pudo leer la asistencia.
  Future<void> refresh();

  Future<Branch?> findBranch(String branchId);

  Future<SubmitOutcome> clockIn(
    String branchId,
    String shiftId,
    DeviceLocation location,
  );

  Future<SubmitOutcome> clockOut();

  Future<SubmitOutcome> submitJustification(AttendanceId id, String reason);
}
