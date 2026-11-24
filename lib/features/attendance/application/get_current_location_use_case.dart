import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';

/// Ubicación fresca para la vista previa de la geocerca. Nunca autoriza la marcación: `ClockInUseCase` vuelve
/// a pedirla. Lanza `LocationPermissionDeniedException` o `LocationUnavailableException`.
class GetCurrentLocationUseCase {
  final LocationProvider locationProvider;

  const GetCurrentLocationUseCase({required this.locationProvider});

  Future<DeviceLocation> execute() => locationProvider.currentLocation();
}
