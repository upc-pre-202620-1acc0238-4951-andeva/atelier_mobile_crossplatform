/// `WorkShiftResource` de docs/api/hr.md.
class WorkShiftDto {
  final String id;
  final String? name;
  final String startTime;
  final String endTime;
  final int? gracePeriodMinutes;
  final bool? isActive;
  final List<String> workDays;
  final List<String> restDays;

  const WorkShiftDto({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriodMinutes,
    required this.isActive,
    required this.workDays,
    required this.restDays,
  });

  factory WorkShiftDto.fromJson(Map<String, dynamic> json) {
    return WorkShiftDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      gracePeriodMinutes: (json['gracePeriodMinutes'] as num?)?.toInt(),
      isActive: json['isActive'] as bool?,
      workDays: (json['workDays'] as List?)?.cast<String>() ?? const [],
      restDays: (json['restDays'] as List?)?.cast<String>() ?? const [],
    );
  }
}
