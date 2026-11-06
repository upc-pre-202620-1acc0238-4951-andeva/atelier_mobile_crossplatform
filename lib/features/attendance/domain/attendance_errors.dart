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
