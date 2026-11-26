import 'package:atelier_mobile_crossplatform/core/data/sync/pre_sync_hook.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';

/// Empaqueta las lecturas de `telemetry_readings` que quedaron sin lote (menos de 200) tras una muerte del
/// proceso en la fosa o al cerrar sesión (US19 E2). Lo corre el `SyncProcessor` dentro del bloqueo `sync`,
/// en la UI o en el worker, antes de leer la cola: así el envío en bloque al recuperar la red las incluye.
///
/// A diferencia de Android, no consulta la sesión Bluetooth en vivo: el worker es otro motor y no la ve. La
/// ventana de inactividad cumple ese papel: un vehículo que sigue transmitiendo tiene muestras de hace 2 s y
/// sus remanentes esperan. Con `forceFlushAll` (cierre de sesión) se empaqueta todo lo del usuario saliente.
class DiagnosticsPreSyncHook implements PreSyncHook {
  static const idleWindow = Duration(seconds: 60);

  final DiagnosticsRepository repository;

  const DiagnosticsPreSyncHook({required this.repository});

  @override
  Future<void> beforeSync(String userId, {bool forceFlushAll = false}) async {
    await repository.enqueueUnbatchedReadings(
      onlyFull: false,
      userId: userId,
      minIdle: forceFlushAll ? Duration.zero : idleWindow,
    );
  }
}
