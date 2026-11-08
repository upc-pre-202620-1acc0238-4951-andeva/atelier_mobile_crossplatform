import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';

/// US10: descargos `PENDING` de los últimos [days] días de Lima, del más reciente al más viejo
/// (H32). Sin `hr:attendance:audit_all`, vacía sin llamar.
class GetPendingJustificationsUseCase {
  final TeamRepository repository;

  const GetPendingJustificationsUseCase({required this.repository});

  Future<PendingJustifications> execute({int days = 7}) {
    return repository.getPendingJustifications(days);
  }
}
