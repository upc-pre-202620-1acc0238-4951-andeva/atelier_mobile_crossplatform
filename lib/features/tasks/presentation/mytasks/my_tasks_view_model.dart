import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_ui_state.dart';
import 'package:flutter/foundation.dart';

/// US26: Mis tareas. Observa la caché Drift (en curso → en pausa → asignadas) y la recarga con `GET /tasks/my`
/// al abrir y al deslizar. Si la recarga falla se sigue con la caché.
class MyTasksViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveMyTasksUseCase observeMyTasks;
  final RefreshMyTasksUseCase refreshMyTasks;
  final ConnectivityObserver connectivity;
  final ObservePendingOperationCountUseCase? observePendingCount;
  final ObservePushHistoryUseCase? observePushHistory;

  MyTasksViewModel({
    required this.observeSession,
    required this.observeMyTasks,
    required this.refreshMyTasks,
    required this.connectivity,
    this.observePendingCount,
    this.observePushHistory,
  }) {
    _state = MyTasksUiState(isOnline: connectivity.isOnline);
    _subscriptions.add(
      observeSession.execute().listen((session) {
        final isWorkshopSupervision =
            session != null &&
            !session.has(Permission.tasksTrackTime) &&
            (session.has(Permission.workOrdersUpdate) ||
                session.has(Permission.tasksHoldValidate) ||
                session.has(Permission.baysReassign));
        _update(
          _state.copyWith(
            canRead: session?.has(Permission.tasksRead) == true,
            isWorkshopScope: isWorkshopSupervision,
            tenantName: session?.tenantName ?? '',
          ),
        );
      }),
    );
    _subscriptions.add(
      observeMyTasks.execute().listen((tasks) => _update(_state.copyWith(tasks: tasks, isLoaded: true))),
    );
    final pending = observePendingCount;
    if (pending != null) {
      _subscriptions.add(
        pending.execute().listen((count) => _update(_state.copyWith(pendingSyncCount: count))),
      );
    }
    final push = observePushHistory;
    if (push != null) {
      _subscriptions.add(
        push.execute().listen(
          (records) => _update(
            _state.copyWith(unreadNotificationsCount: records.where((r) => !r.read).length),
          ),
        ),
      );
    }
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  late MyTasksUiState _state;
  MyTasksUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  /// Si la recarga falló sin red, al volver la conexión se actualiza sola y el aviso se quita.
  void _onConnectivity() {
    final online = connectivity.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (online && _state.showingCache) refresh();
  }

  void onFilterChange(TaskFilter filter) => _update(_state.copyWith(selectedFilter: filter));

  /// Al abrir, al deslizar y cuando llega el push `TASK_ASSIGNED`.
  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    try {
      await refreshMyTasks.execute();
      _update(_state.copyWith(isRefreshing: false, showingCache: false));
    } on Object catch (e) {
      _update(_state.copyWith(isRefreshing: false, showingCache: true, error: toUiText(e)));
    }
  }

  void _update(MyTasksUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
