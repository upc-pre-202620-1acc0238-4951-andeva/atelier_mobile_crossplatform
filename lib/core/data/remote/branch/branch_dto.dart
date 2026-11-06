/// `BranchResource` de docs/api/iam.md; por ahora solo lo que usa la elección de sede.
class BranchDto {
  final String id;
  final String? name;
  final int? geofenceRadiusMeters;
  final bool? isActive;

  const BranchDto({
    required this.id,
    required this.name,
    required this.geofenceRadiusMeters,
    required this.isActive,
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    return BranchDto(
      id: json['id'] as String,
      name: json['name'] as String?,
      geofenceRadiusMeters: json['geofenceRadiusMeters'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}
