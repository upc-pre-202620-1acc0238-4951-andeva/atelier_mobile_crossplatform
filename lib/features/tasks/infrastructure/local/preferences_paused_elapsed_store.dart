import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un valor por tarea; `SessionManager.clear` los borra al cerrar sesión.
class PreferencesPausedElapsedStore implements PausedElapsedStore {
  final SharedPreferencesAsync preferences;

  const PreferencesPausedElapsedStore({required this.preferences});

  String _key(TaskId id) => '${SessionManager.taskPausedElapsedPrefix}${id.value}';

  @override
  Future<int?> get(TaskId id) => preferences.getInt(_key(id));

  @override
  Future<void> save(TaskId id, int seconds) =>
      preferences.setInt(_key(id), seconds);

  @override
  Future<void> clear(TaskId id) => preferences.remove(_key(id));
}
