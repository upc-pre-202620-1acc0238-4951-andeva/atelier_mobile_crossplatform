/// `AttendanceResource` de docs/api/hr.md.
class AttendanceDto {
  final String id;
  final String? branchId;
  final String? membershipId;
  final String? shiftId;
  final String? clockIn;
  final String? clockOut;
  final String? status;
  final double? latitude;
  final double? longitude;
  final double? distanceToBranchMeters;
  final String? justificationReason;
  final String? justificationStatus;
  final int? workedMinutes;
  final int? regularMinutes;
  final int? overtimeMinutes;

  /// Solo los lee `team` (quién revisó el descargo y cuándo).
  final String? justificationReviewedBy;
  final String? justificationReviewedAt;

  const AttendanceDto({
    required this.id,
    required this.branchId,
    required this.membershipId,
    required this.shiftId,
    required this.clockIn,
    required this.clockOut,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.distanceToBranchMeters,
    required this.justificationReason,
    required this.justificationStatus,
    required this.workedMinutes,
    required this.regularMinutes,
    required this.overtimeMinutes,
    this.justificationReviewedBy,
    this.justificationReviewedAt,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDto(
      id: json['id'] as String,
      branchId: json['branchId'] as String?,
      membershipId: json['membershipId'] as String?,
      shiftId: json['shiftId'] as String?,
      clockIn: json['clockIn'] as String?,
      clockOut: json['clockOut'] as String?,
      status: json['status'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceToBranchMeters: (json['distanceToBranchMeters'] as num?)
          ?.toDouble(),
      justificationReason: json['justificationReason'] as String?,
      justificationStatus: json['justificationStatus'] as String?,
      workedMinutes: (json['workedMinutes'] as num?)?.toInt(),
      regularMinutes: (json['regularMinutes'] as num?)?.toInt(),
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt(),
      justificationReviewedBy: json['justificationReviewedBy'] as String?,
      justificationReviewedAt: json['justificationReviewedAt'] as String?,
    );
  }
}
