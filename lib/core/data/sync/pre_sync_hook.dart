import 'dart:developer';

/// Trabajo de una feature que debe quedar en la cola antes de enviarla (US19): p. ej. empaquetar lecturas
/// de telemetría que quedaron sin lote tras una muerte del proceso en la fosa. El núcleo no conoce a las
/// features: cada una registra el suyo en [PreSyncHookRegistry].
abstract interface class PreSyncHook {
  /// [userId] es el dueño de la cola que se va a enviar. Con [forceFlushAll] (al cerrar sesión) se empaqueta
  /// todo lo del usuario, sin esperar ventanas de inactividad.
  Future<void> beforeSync(String userId, {bool forceFlushAll = false});
}

/// Explícito, como [OperationHandlerRegistry]: `setupDependencies()` corre también en el worker y solo se
/// construye el gancho cuando se usa.
class PreSyncHookRegistry {
  final _factories = <PreSyncHook Function()>[];

  void register(PreSyncHook Function() factory) => _factories.add(factory);

  /// Un gancho que falla no detiene a los demás ni al envío.
  Future<void> runAll(String userId, {bool forceFlushAll = false}) async {
    for (final factory in _factories) {
      try {
        await factory().beforeSync(userId, forceFlushAll: forceFlushAll);
      } on Object catch (e) {
        // El envío sigue: lo que no se empaquetó se intenta en la siguiente vuelta.
        log('PreSyncHook falló: $e', name: 'PreSyncHookRegistry');
      }
    }
  }
}
