import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';

/// Mis asistencias de los últimos 30 días, con minutos y estado del descargo (US06–US08, US10).
class ObserveAttendanceHistoryUseCase {
  final AttendanceRepository repository;

  const ObserveAttendanceHistoryUseCase({required this.repository});

  Stream<List<Attendance>> execute() => repository.watchHistory();
}
