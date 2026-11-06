import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';

/// Ubicación para la geocerca (docs/04-mobile-integration.md §7), nunca la última conocida. Pide el
/// permiso si aún no se decidió. Lanza `LocationPermissionDeniedException` o
/// `LocationUnavailableException`.
abstract class LocationProvider {
  Future<DeviceLocation> currentLocation();
}
