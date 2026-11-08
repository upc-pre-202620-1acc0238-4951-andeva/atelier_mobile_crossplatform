import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';

/// US10 E2 (`hr:justifications:approve`): sin filtro aquí, como aprobar.
class RejectJustificationUseCase {
  final TeamRepository repository;

  const RejectJustificationUseCase({required this.repository});

  Future<TeamAttendance> execute(String attendanceId) {
    return repository.rejectJustification(attendanceId);
  }
}
