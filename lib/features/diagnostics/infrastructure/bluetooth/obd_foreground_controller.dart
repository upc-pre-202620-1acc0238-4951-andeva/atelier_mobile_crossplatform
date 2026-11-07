/// Mantiene el proceso en primer plano mientras dura el muestreo (04 §4). Nunca lanza: sin él la sesión
/// sigue igual, solo pierde la protección en segundo plano.
abstract class ObdForegroundController {
  Future<void> start();

  Future<void> stop();
}
