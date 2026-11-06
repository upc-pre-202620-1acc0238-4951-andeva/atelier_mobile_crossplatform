/// Ubicación fresca del teléfono. [isMock]: ubicación simulada (el backend no lo verifica).
class DeviceLocation {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool isMock;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isMock,
  });
}
