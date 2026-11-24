/// Sin permiso de ubicación: la UI explica y lleva a los ajustes.
class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

/// Ubicación apagada o sin fix: pedir activarla.
class LocationUnavailableException implements Exception {
  const LocationUnavailableException();
}

/// Precisión peor que 50 m: pedir salir a cielo abierto.
class LocationTooInaccurateException implements Exception {
  final double accuracyMeters;

  const LocationTooInaccurateException(this.accuracyMeters);
}

/// La sesión no tiene sede, turno o `membershipId`.
class MissingAssignmentException implements Exception {
  const MissingAssignmentException();
}

/// Motivo vacío o de más de 500 caracteres.
class InvalidJustificationException implements Exception {
  const InvalidJustificationException();
}

/// Ubicación simulada: no se marca ni se encola una ubicación no verificable.
class MockLocationException implements Exception {
  const MockLocationException();
}

/// La sede asignada no está en caché: sin su geocerca no se puede validar la ubicación.
class BranchGeofenceUnavailableException implements Exception {
  const BranchGeofenceUnavailableException();
}

/// Fuera de la geocerca: el bloqueo se aplica también sin conexión; el backend repite la validación.
class LocationOutsideGeofenceException implements Exception {
  final double distanceMeters;
  final double radiusMeters;

  const LocationOutsideGeofenceException(this.distanceMeters, this.radiusMeters);
}
