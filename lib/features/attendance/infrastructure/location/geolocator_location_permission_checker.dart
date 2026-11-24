import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_permission_checker.dart';
import 'package:geolocator/geolocator.dart';

class GeolocatorLocationPermissionChecker implements LocationPermissionChecker {
  const GeolocatorLocationPermissionChecker();

  @override
  Future<bool> isGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }
}
