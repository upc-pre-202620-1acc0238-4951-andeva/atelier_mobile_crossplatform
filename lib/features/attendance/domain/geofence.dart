import 'dart:math';

import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';

/// Resultado local de Haversine. El backend repite la validación como autoridad final (422).
class GeofenceCheck {
  final double distanceMeters;
  final bool isInside;
  final bool isMock;

  const GeofenceCheck({
    required this.distanceMeters,
    required this.isInside,
    required this.isMock,
  });
}

class Geofence {
  static const _earthRadiusMeters = 6371008.8;

  /// Distancia de Haversine en metros.
  static double distanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a =
        pow(sin(dLat / 2), 2) +
        cos(_radians(lat1)) * cos(_radians(lat2)) * pow(sin(dLon / 2), 2);
    return 2 * _earthRadiusMeters * asin(sqrt(a));
  }

  static GeofenceCheck check(Branch branch, DeviceLocation location) {
    final distance = distanceMeters(
      branch.latitude,
      branch.longitude,
      location.latitude,
      location.longitude,
    );
    return GeofenceCheck(
      distanceMeters: distance,
      isInside: distance <= branch.geofenceRadiusMeters,
      isMock: location.isMock,
    );
  }

  static double _radians(double degrees) => degrees * pi / 180;
}
