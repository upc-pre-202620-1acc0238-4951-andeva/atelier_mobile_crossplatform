import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';

/// Pantalla "Pendientes de sincronizar" e ícono con contador (docs/06-offline-sync.md §3).
abstract class PendingOperationRepository {
  /// Solo la cola del usuario de la sesión; vacía sin sesión.
  Stream<List<PendingOperation>> watchAll();

  Stream<int> watchCount();

  /// Vuelve a encolar una operación FAILED y su cadena. `false` si no aplicaba.
  Future<bool> retry(String id);

  /// Borra la operación con sus dependientes y, si era una foto, su subida. `false` si no aplicaba
  /// o si algo de la cadena se está enviando.
  Future<bool> discard(String id);
}
