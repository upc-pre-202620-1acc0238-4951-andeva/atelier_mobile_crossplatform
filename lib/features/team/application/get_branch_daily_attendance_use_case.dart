import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';

/// US10: asistencia de la sede en un día de Lima. Sin `hr:attendance:audit_all`, lista vacía sin
/// llamar.
class GetBranchDailyAttendanceUseCase {
  final TeamRepository repository;

  const GetBranchDailyAttendanceUseCase({required this.repository});

  Future<List<TeamAttendance>> execute(String date) {
    return repository.getBranchDaily(date);
  }
}
