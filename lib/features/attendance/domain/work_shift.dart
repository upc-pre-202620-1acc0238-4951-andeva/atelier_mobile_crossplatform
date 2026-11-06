import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';

/// Turno (`WorkShiftResource` de docs/api/hr.md). Las horas son de Lima, `HH:mm:ss`.
class WorkShift {
  final String id;
  final String name;
  final String startTime;
  final String endTime;
  final int gracePeriodMinutes;
  final Set<WeekDay> workDays;
  final Set<WeekDay> restDays;
  final bool isActive;

  const WorkShift({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMinutes,
    required this.workDays,
    required this.restDays,
    required this.isActive,
  });
}
