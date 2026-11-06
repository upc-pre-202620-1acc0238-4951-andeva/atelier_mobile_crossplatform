class Branch {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double geofenceRadiusMeters;
  final bool isActive;

  const Branch({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.geofenceRadiusMeters,
    required this.isActive,
  });
}
