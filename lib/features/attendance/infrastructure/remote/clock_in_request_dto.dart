/// `ClockInRequest` de docs/api/hr.md. [clockInTime] solo va cuando se envía desde la cola.
class ClockInRequestDto {
  final String branchId;
  final String shiftId;
  final double latitude;
  final double longitude;
  final String? clockInTime;

  const ClockInRequestDto({
    required this.branchId,
    required this.shiftId,
    required this.latitude,
    required this.longitude,
    this.clockInTime,
  });

  factory ClockInRequestDto.fromJson(Map<String, dynamic> json) {
    return ClockInRequestDto(
      branchId: json['branchId'] as String,
      shiftId: json['shiftId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      clockInTime: json['clockInTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'shiftId': shiftId,
      'latitude': latitude,
      'longitude': longitude,
      if (clockInTime != null) 'clockInTime': clockInTime,
    };
  }
}
