import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';

/// Marcar salida (US08). El backend calcula los minutos y pausa las tareas en curso. Sin red se encola.
class ClockOutUseCase {
  final AttendanceRepository repository;

  const ClockOutUseCase({required this.repository});

  Future<SubmitOutcome> execute() => repository.clockOut();
}
