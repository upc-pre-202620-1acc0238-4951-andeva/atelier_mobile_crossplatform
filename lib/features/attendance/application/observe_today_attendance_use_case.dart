import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';

/// Mi jornada de hoy, incluida una marcación que espera señal (US06, US08).
class ObserveTodayAttendanceUseCase {
  final AttendanceRepository repository;

  const ObserveTodayAttendanceUseCase({required this.repository});

  Stream<TodayAttendance> execute() => repository.watchToday();
}
