import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';

abstract class PausedElapsedStore {
  Future<int?> get(TaskId id);
  Future<void> save(TaskId id, int seconds);
  Future<void> clear(TaskId id);
}
