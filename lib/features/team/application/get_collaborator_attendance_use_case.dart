import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';

/// Destino del push `OVERTIME_RECORDED`. `null` si no está en los últimos 30 días.
class GetCollaboratorAttendanceUseCase {
  final TeamRepository repository;

  const GetCollaboratorAttendanceUseCase({required this.repository});

  Future<TeamAttendance?> execute(String membershipId, String attendanceId) {
    return repository.getCollaboratorAttendance(membershipId, attendanceId);
  }
}
