import 'dart:async';

import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Ubicación **fresca** de alta precisión (docs/04-mobile-integration.md §7). `isMocked` es menos
/// fiable en iOS: solo sirve de aviso.
class GeolocatorLocationProvider implements LocationProvider {
  static const _timeout = Duration(seconds: 30);

  const GeolocatorLocationProvider();

  @override
  Future<DeviceLocation> currentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailableException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException();
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: defaultTargetPlatform == TargetPlatform.android
            // Sin esto, el plugin pide aceptar "Precisión de la ubicación" de Google en cada
            // marcación y, si se rechaza, falla. La app nativa no lo pide.
            ? AndroidSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: _timeout,
                forceLocationManager: true,
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: _timeout,
              ),
      );
    } on TimeoutException {
      throw const LocationUnavailableException();
    } on LocationServiceDisabledException {
      throw const LocationUnavailableException();
    } on PermissionDeniedException {
      throw const LocationPermissionDeniedException();
    }
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      isMock: position.isMocked,
    );
  }
}
