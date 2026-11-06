/// `ClockOutRequest` de docs/api/hr.md. [clockOutTime] solo va cuando se envía desde la cola.
class ClockOutRequestDto {
  final String? attendanceId;
  final String? clockOutTime;

  const ClockOutRequestDto({this.attendanceId, this.clockOutTime});

  factory ClockOutRequestDto.fromJson(Map<String, dynamic> json) {
    return ClockOutRequestDto(
      attendanceId: json['attendanceId'] as String?,
      clockOutTime: json['clockOutTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (attendanceId != null) 'attendanceId': attendanceId,
      if (clockOutTime != null) 'clockOutTime': clockOutTime,
    };
  }
}
