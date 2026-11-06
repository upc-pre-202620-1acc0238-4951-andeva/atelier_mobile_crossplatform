import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';

/// Horas hombre para precargar al cerrar (US30 E1): desde `startedAt` menos lo pausado.
class SuggestLaborHoursUseCase {
  final DateTime Function() now;

  const SuggestLaborHoursUseCase({this.now = DateTime.now});

  double? execute(Task task) {
    final startedAt = task.startedAt;
    if (startedAt == null) return null;
    return LaborTime.suggestedHours(startedAt, task.totalPausedSeconds, now());
  }
}
