import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';

/// Resultado de una acción que funciona sin red (marcar ingreso o salida, enviar descargo).
sealed class SubmitOutcome {
  const SubmitOutcome();
}

/// Con red: el backend ya la registró.
final class Recorded extends SubmitOutcome {
  final Attendance attendance;

  const Recorded(this.attendance);
}

/// Sin red: quedó en la cola y se envía al recuperar señal.
final class Queued extends SubmitOutcome {
  const Queued();
}

/// El mismo hecho ya estaba en la cola (pendiente o fallido: ver "Pendientes de sincronizar").
final class AlreadyQueued extends SubmitOutcome {
  const AlreadyQueued();
}

/// Marcación de ingreso con sus avisos: nada de esto la impide, decide el backend (04 §7).
class ClockInResult {
  final SubmitOutcome outcome;

  /// `null` si la sede no está en caché.
  final GeofenceCheck? geofence;
  final bool isMockLocation;

  const ClockInResult({
    required this.outcome,
    required this.geofence,
    required this.isMockLocation,
  });
}
