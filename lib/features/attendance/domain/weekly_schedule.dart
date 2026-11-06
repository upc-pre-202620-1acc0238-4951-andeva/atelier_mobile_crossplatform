import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/work_shift.dart';

class ScheduleDay {
  final WeekDay day;
  final bool isWorkDay;

  const ScheduleDay({required this.day, required this.isWorkDay});
}

/// Mi turno de lunes a domingo (US09 E1). [branchId] y [shiftId] son los de la sesión, que la UI
/// pasa a `ClockInUseCase`; [branch] es `null` si la sede aún no está en caché.
class WeeklySchedule {
  final String? branchId;
  final String shiftId;
  final WorkShift shift;
  final Branch? branch;

  const WeeklySchedule({
    required this.branchId,
    required this.shiftId,
    required this.shift,
    required this.branch,
  });

  /// Un día es de descanso si está en `restDays`; sin `workDays` publicados, el resto se trabaja.
  List<ScheduleDay> get days {
    return [
      for (final day in WeekDay.values)
        ScheduleDay(
          day: day,
          isWorkDay:
              !shift.restDays.contains(day) &&
              (shift.workDays.isEmpty || shift.workDays.contains(day)),
        ),
    ];
  }
}
