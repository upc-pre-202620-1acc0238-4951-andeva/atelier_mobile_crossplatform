import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';

/// Filtros de la bandeja del mecánico en bahía.
enum TaskFilter { all, inProgress, paused, assigned, suspended }

/// US26: bandeja del mecánico. Las tareas salen de Drift, así que se ven sin red.
class MyTasksUiState {
  final List<Task> tasks;
  final TaskFilter selectedFilter;

  /// Sin lectura todavía de la caché: evita mostrar "no tienes tareas" un instante al abrir.
  final bool isLoaded;
  final bool isRefreshing;

  /// La última recarga falló (sin red): se sigue con la caché.
  final bool showingCache;
  final bool isOnline;
  final UiText? error;
  final bool canRead;
  final bool isWorkshopScope;
  final String tenantName;
  final int pendingSyncCount;
  final int unreadNotificationsCount;

  const MyTasksUiState({
    this.tasks = const [],
    this.selectedFilter = TaskFilter.all,
    this.isLoaded = false,
    this.isRefreshing = false,
    this.showingCache = false,
    this.isOnline = true,
    this.error,
    this.canRead = true,
    this.isWorkshopScope = false,
    this.tenantName = '',
    this.pendingSyncCount = 0,
    this.unreadNotificationsCount = 0,
  });

  bool get showSkeleton => canRead && (!isLoaded || (isRefreshing && tasks.isEmpty && error == null));

  int get pendingCount =>
      tasks.where((t) => t.status == TaskStatus.assigned || t.status == TaskStatus.pending).length;

  int get inProgressCount => tasks.where((t) => t.status == TaskStatus.inProgress).length;

  int get pausedCount => tasks.where((t) => t.status == TaskStatus.onHold).length;

  int get mechanicPausedCount => tasks.where((t) => t.isPausedByMechanic).length;

  int get suspendedCount => tasks.where((t) => t.isSuspended || t.hasPendingSuspension).length;

  List<Task> get visibleTasks => switch (selectedFilter) {
    TaskFilter.all => tasks,
    TaskFilter.inProgress => tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
    TaskFilter.paused => tasks.where((t) => t.isPausedByMechanic).toList(),
    TaskFilter.assigned =>
      tasks.where((t) => t.status == TaskStatus.assigned || t.status == TaskStatus.pending).toList(),
    TaskFilter.suspended => tasks.where((t) => t.isSuspended || t.hasPendingSuspension).toList(),
  };

  MyTasksUiState copyWith({
    List<Task>? tasks,
    TaskFilter? selectedFilter,
    bool? isLoaded,
    bool? isRefreshing,
    bool? showingCache,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canRead,
    bool? isWorkshopScope,
    String? tenantName,
    int? pendingSyncCount,
    int? unreadNotificationsCount,
  }) {
    return MyTasksUiState(
      tasks: tasks ?? this.tasks,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoaded: isLoaded ?? this.isLoaded,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      showingCache: showingCache ?? this.showingCache,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
      isWorkshopScope: isWorkshopScope ?? this.isWorkshopScope,
      tenantName: tenantName ?? this.tenantName,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
    );
  }
}
