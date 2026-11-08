import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';

/// Jefatura (US10). Todo en línea y sin caché (06 §2). Lo que lee la sede lanza
/// `MissingBranchException` sin sede.
abstract class TeamRepository {
  /// Día de Lima [date] de la sede de la sesión. Sin sesión o sin `hr:attendance:audit_all`, vacío
  /// sin llamar. Una fila mal formada hace fallar la lectura en vez de ocultarse.
  Future<List<TeamAttendance>> getBranchDaily(String date);

  /// Descargos `PENDING` de los últimos [days] días de Lima (H32). Mismo filtro de permiso que
  /// [getBranchDaily]. Si fallan todos los días, lanza el error del primero. [days] < 1 lanza
  /// `ArgumentError`.
  Future<PendingJustifications> getPendingJustifications(int days);

  /// Destino del push `OVERTIME_RECORDED`: busca en los últimos 30 días; `null` si no está.
  Future<TeamAttendance?> getCollaboratorAttendance(
    String membershipId,
    String attendanceId,
  );

  Future<TeamAttendance> approveJustification(String attendanceId);

  Future<TeamAttendance> rejectJustification(String attendanceId);
}
