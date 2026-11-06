/// `JustifyAttendanceRequest` de docs/api/hr.md.
class JustifyAttendanceRequestDto {
  final String reason;

  const JustifyAttendanceRequestDto({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}
