import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';

/// Órdenes no cerradas de la sede, desde Drift (se ven sin red). Punto de entrada del supervisor a las tareas
/// (US33). Sin el chip "Suspensión por revisar" de la lista: es la historia US29.
class WorkOrdersUiState {
  final List<WorkOrder> orders;
  final bool isLoaded;
  final bool isRefreshing;
  final bool isOnline;

  /// La última recarga falló (sin red): se sigue con la caché.
  final bool showingCache;
  final DateTime? lastRefreshedAt;
  final UiText? error;
  final bool canRead;
  final bool canCreate;

  /// Filtro por estado; `null` muestra todas.
  final WorkOrderStatus? statusFilter;

  /// Texto de la búsqueda por placa.
  final String query;
  final int pendingSyncCount;
  final int unreadNotificationsCount;

  const WorkOrdersUiState({
    this.orders = const [],
    this.isLoaded = false,
    this.isRefreshing = false,
    this.isOnline = true,
    this.showingCache = false,
    this.lastRefreshedAt,
    this.error,
    this.canRead = true,
    this.canCreate = false,
    this.statusFilter,
    this.query = '',
    this.pendingSyncCount = 0,
    this.unreadNotificationsCount = 0,
  });

  /// Las órdenes que pasan el filtro de estado y la búsqueda por placa (sin guion ni mayúsculas).
  List<WorkOrder> get visibleOrders {
    final needle = _normalize(query);
    return [
      for (final order in orders)
        if ((statusFilter == null || order.status == statusFilter) &&
            (needle.isEmpty || _normalize(order.plate ?? '').contains(needle)))
          order,
    ];
  }

  /// Sin caché que pintar: se muestra el esqueleto.
  bool get showSkeleton =>
      !isLoaded || (orders.isEmpty && isRefreshing && lastRefreshedAt == null && error == null);

  static String _normalize(String value) =>
      value.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '').toUpperCase();

  WorkOrdersUiState copyWith({
    List<WorkOrder>? orders,
    bool? isLoaded,
    bool? isRefreshing,
    bool? isOnline,
    bool? showingCache,
    DateTime? lastRefreshedAt,
    UiText? error,
    bool clearError = false,
    bool? canRead,
    bool? canCreate,
    WorkOrderStatus? statusFilter,
    bool clearStatusFilter = false,
    String? query,
    int? pendingSyncCount,
    int? unreadNotificationsCount,
  }) {
    return WorkOrdersUiState(
      orders: orders ?? this.orders,
      isLoaded: isLoaded ?? this.isLoaded,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOnline: isOnline ?? this.isOnline,
      showingCache: showingCache ?? this.showingCache,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
      canCreate: canCreate ?? this.canCreate,
      statusFilter: clearStatusFilter ? null : statusFilter ?? this.statusFilter,
      query: query ?? this.query,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
    );
  }
}
