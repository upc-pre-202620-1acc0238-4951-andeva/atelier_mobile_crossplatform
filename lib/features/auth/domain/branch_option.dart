/// Sede que una cuenta sin perfil laboral puede elegir (`BranchResource` de docs/api/iam.md).
class BranchOption {
  final String id;
  final String name;

  /// Radio de la geocerca de marcación; `null` si el backend no lo informa.
  final int? geofenceRadiusMeters;

  const BranchOption({
    required this.id,
    required this.name,
    required this.geofenceRadiusMeters,
  });
}
