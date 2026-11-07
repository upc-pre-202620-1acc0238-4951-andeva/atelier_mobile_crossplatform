enum DeviceStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  lost('LOST'),
  broken('BROKEN');

  final String value;

  const DeviceStatus(this.value);

  static DeviceStatus? fromString(String? value) {
    for (final status in values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// Escáner OBD-II registrado en el taller (`Obd2DeviceResponse`).
class ObdDevice {
  final String id;
  final String deviceIdentifier;
  final String? connectionType;
  final DeviceStatus? status;
  final String? hardwareModel;
  final String? firmwareVersion;

  const ObdDevice({
    required this.id,
    required this.deviceIdentifier,
    this.connectionType,
    this.status,
    this.hardwareModel,
    this.firmwareVersion,
  });

  /// Solo sugiere el escáner del adaptador: no hay regla que diga que `deviceIdentifier` sea la MAC
  /// (H17), así que la UI deja elegir. En iOS nunca coincide (H41).
  bool matches(String address) => _normalize(deviceIdentifier) == _normalize(address);

  static String _normalize(String value) {
    return value.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  }
}

/// Instalación del escáner en un vehículo (`DeviceInstallationResponse`). El lote de telemetría la exige
/// activa (H16).
class DeviceInstallation {
  final String id;
  final String deviceId;
  final String vehicleId;
  final DateTime? installedAt;
  final DateTime? uninstalledAt;
  final int? initialOdometerKm;
  final int? finalOdometerKm;
  final bool isActive;

  const DeviceInstallation({
    required this.id,
    required this.deviceId,
    required this.vehicleId,
    this.installedAt,
    this.uninstalledAt,
    this.initialOdometerKm,
    this.finalOdometerKm,
    required this.isActive,
  });
}
