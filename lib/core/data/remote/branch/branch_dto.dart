/// `BranchResource` de docs/api/iam.md; solo lo que usan la elección de sede y la geocerca.
class BranchDto {
  final String id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final int? geofenceRadiusMeters;
  final bool? isActive;

  const BranchDto({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    required this.geofenceRadiusMeters,
    required this.isActive,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    return BranchDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      geofenceRadiusMeters: json['geofenceRadiusMeters'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}
