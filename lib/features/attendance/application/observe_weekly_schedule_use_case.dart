import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';

/// Mi turno de lunes a domingo, con sede, tolerancia y descansos (US09 E1). `null` sin turno.
class ObserveWeeklyScheduleUseCase {
  final AttendanceRepository repository;

  const ObserveWeeklyScheduleUseCase({required this.repository});

  Stream<WeeklySchedule?> execute() => repository.watchSchedule();
}
