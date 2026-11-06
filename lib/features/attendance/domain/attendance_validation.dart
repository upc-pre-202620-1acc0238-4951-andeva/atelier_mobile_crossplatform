import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';

/// Restricciones de docs/api/hr.md y docs/04-mobile-integration.md §7. Solo evitan una llamada
/// inútil; el backend vuelve a validar todo.
class AttendanceValidation {
  static const justificationMax = 500;

  /// Peor que esto, pedir salir a cielo abierto antes de marcar.
  static const maxAccuracyMeters = 50.0;

  static bool isJustification(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.length <= justificationMax;
  }

  static bool isAccurate(DeviceLocation location) {
    return location.accuracyMeters <= maxAccuracyMeters;
  }
}
