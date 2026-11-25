import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_pending_suspensions_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:flutter/foundation.dart';

/// Lista de órdenes de la sede (`operations:work_orders:read`). Observa la caché Drift y la recarga al abrir;
/// el estado y la placa se filtran en el dispositivo. Recibir un vehículo (`work_orders:create`) es del flujo
/// de recepción: aquí solo se avisa a la navegación.
class WorkOrdersViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveBranchWorkOrdersUseCase observeOrders;
  final RefreshBranchWorkOrdersUseCase refreshOrders;
  final ConnectivityObserver connectivity;
  final EnrichReceptionReferencesUseCase? enrichReferences;
  final ObservePendingOperationCountUseCase? observePendingSyncCount;
  final ObservePushHistoryUseCase? observePushHistory;
  final FindPendingSuspensionsUseCase? findPendingSuspensions;
  final DateTime Function() now;

  WorkOrdersViewModel({
    this.findPendingSuspensions,
    required this.observeSession,
    required this.observeOrders,
    required this.refreshOrders,
    required this.connectivity,
    this.enrichReferences,
    this.observePendingSyncCount,
    this.observePushHistory,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now {
    _state = WorkOrdersUiState(isOnline: connectivity.isOnline);
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(observeOrders.execute().listen(_onOrders));
    final pending = observePendingSyncCount;
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

  late WorkOrdersUiState _state;
  WorkOrdersUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  String? _lastBranchId;
  bool _hasSession = false;
  final Set<String> _enrichedIds = {};
  bool _disposed = false;

  void _onSession(Session? session) {
    final branchChanged = _hasSession && session?.branchId != _lastBranchId;
    _hasSession = true;
    _lastBranchId = session?.branchId;
    _canValidateSuspension = session?.has(Permission.tasksHoldValidate) == true;
    _update(
      _state.copyWith(
        canRead: session?.has(Permission.workOrdersRead) == true,
        canCreate: session?.has(Permission.workOrdersCreate) == true,
      ),
    );
    if (branchChanged) refresh();
  }

  void _onOrders(List<WorkOrder> orders) {
    _update(_state.copyWith(orders: orders, isLoaded: true));
    final missingVehicles = {
      for (final order in orders)
        if (order.plate == null && !_enrichedIds.contains(order.vehicleId)) order.vehicleId,
    };
    final missingCustomers = {
      for (final order in orders)
        if (order.customerName == null && !_enrichedIds.contains(order.customerId)) order.customerId,
    };
    if (missingVehicles.isNotEmpty || missingCustomers.isNotEmpty) {
      _enrichedIds
        ..addAll(missingVehicles)
        ..addAll(missingCustomers);
      final enrich = enrichReferences;
      if (enrich != null) {
        unawaited(() async {
          try {
            await enrich.execute(missingVehicles, missingCustomers);
          } on Object {
            // Sin red o sin permiso se sigue con la caché.
          }
        }());
      }
    }
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (online && _state.showingCache) refresh();
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    try {
      await refreshOrders.execute();
      _update(
        _state.copyWith(isRefreshing: false, showingCache: false, lastRefreshedAt: now()),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(isRefreshing: false, showingCache: true, error: toWorkOrderUiText(error)),
      );
      return;
    }
    await _loadPendingSuspensions();
  }

  bool _canValidateSuspension = false;

  /// US29 (H5): marca las órdenes con una suspensión por revisar. Solo para quien puede validarla.
  Future<void> _loadPendingSuspensions() async {
    final find = findPendingSuspensions;
    if (find == null || !_canValidateSuspension || _disposed) return;
    try {
      final pending = await find.execute(await observeOrders.execute().first);
      _update(
        _state.copyWith(pendingSuspensionOrderIds: {for (final item in pending) item.order.id.value}),
      );
    } on Object {
      // Se conservan las marcas que ya había.
    }
  }

  void onStatusFilterChange(WorkOrderStatus? status) {
    _update(_state.copyWith(statusFilter: status, clearStatusFilter: status == null));
  }

  void onQueryChange(String value) => _update(_state.copyWith(query: value));

  void _update(WorkOrdersUiState state) {
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
