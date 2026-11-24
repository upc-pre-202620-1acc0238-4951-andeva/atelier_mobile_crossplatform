/// Si ya hay permiso de ubicación, sin pedirlo: la pantalla de asistencia solo muestra la vista previa de la
/// geocerca cuando ya se concedió (pedirlo es de `LocationProvider`, al marcar).
abstract class LocationPermissionChecker {
  Future<bool> isGranted();
}
