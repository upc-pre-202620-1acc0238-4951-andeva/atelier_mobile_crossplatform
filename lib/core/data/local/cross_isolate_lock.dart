import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Exclusión entre motores de Flutter (docs/06-offline-sync.md §3). Tiene vencimiento porque
/// iOS puede matar al worker sin que libere el bloqueo.
class CrossIsolateLock {
  static const tokenRefresh = 'token_refresh';
  static const sync = 'sync';

  final AppDatabase database;
  final String owner;

  CrossIsolateLock({required this.database}) : owner = const Uuid().v4();

  /// Una sola sentencia atómica: dos conexiones no pueden ganar a la vez. Volver a llamarla
  /// con el mismo dueño renueva el vencimiento, así que no excluye dentro de un mismo motor.
  Future<bool> tryAcquire(String name, Duration lease) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.customStatement(
      'INSERT INTO app_locks (name, owner, expires_at) VALUES (?, ?, ?) '
      'ON CONFLICT (name) DO UPDATE SET owner = excluded.owner, '
      'expires_at = excluded.expires_at '
      'WHERE app_locks.expires_at < ? OR app_locks.owner = excluded.owner',
      [name, owner, now + lease.inMilliseconds, now],
    );
    // Sin fila: el otro motor lo liberó entre las dos sentencias; este intento no ganó.
    final row = await (database.select(
      database.appLocks,
    )..where((t) => t.name.equals(name))).getSingleOrNull();
    return row?.owner == owner;
  }

  Future<void> release(String name) async {
    await (database.delete(
      database.appLocks,
    )..where((t) => t.name.equals(name) & t.owner.equals(owner))).go();
  }
}
