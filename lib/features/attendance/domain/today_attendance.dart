import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';

/// Mi jornada de hoy: combina la caché con la cola, así la UI no deja marcar dos veces mientras una
/// marcación espera señal.
sealed class TodayAttendance {
  const TodayAttendance();
}

final class NotClockedIn extends TodayAttendance {
  const NotClockedIn();
}

/// Ingreso guardado sin red: se enviará al recuperar señal.
final class ClockInQueued extends TodayAttendance {
  final DateTime capturedAt;

  const ClockInQueued(this.capturedAt);
}

final class ClockedIn extends TodayAttendance {
  final Attendance attendance;

  const ClockedIn(this.attendance);
}

/// Salida guardada sin red. [attendance] es `null` si el ingreso también sigue en cola.
final class ClockOutQueued extends TodayAttendance {
  final Attendance? attendance;
  final DateTime capturedAt;

  const ClockOutQueued(this.attendance, this.capturedAt);
}

final class Completed extends TodayAttendance {
  final Attendance attendance;

  const Completed(this.attendance);
}
