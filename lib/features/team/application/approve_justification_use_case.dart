import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';

/// US10 E2 (`hr:justifications:approve`): sin filtro aquí; la UI oculta el botón y el backend
/// responde 403.
class ApproveJustificationUseCase {
  final TeamRepository repository;

  const ApproveJustificationUseCase({required this.repository});

  Future<TeamAttendance> execute(String attendanceId) {
    return repository.approveJustification(attendanceId);
  }
}
