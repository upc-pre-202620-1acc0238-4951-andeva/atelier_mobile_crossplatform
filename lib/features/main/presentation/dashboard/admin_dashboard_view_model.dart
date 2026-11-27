import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/refresh_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_pending_suspensions_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:flutter/foundation.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  /// Cuánto se queda a la vista el resultado de una decisión antes de retirarse de la lista.
  static const resolvedLinger = Duration(milliseconds: 1600);

  final ObserveSessionUseCase observeSession;
  final GetSelectableBranchesUseCase getBranches;
  final ObserveBranchWorkOrdersUseCase observeOrders;
  final RefreshBranchWorkOrdersUseCase refreshOrders;
  final ObserveBayBoardUseCase observeBayBoard;
  final RefreshBayBoardUseCase refreshBayBoard;
  final GetStockAlertsUseCase getStockAlerts;
  final EnrichReceptionReferencesUseCase enrichReferences;
  final ObserveAppointmentsUseCase observeAppointments;
  final RefreshAppointmentsUseCase refreshAppointments;
  final ObserveCustomersUseCase observeCustomers;
  final ObserveWorkshopVehiclesUseCase observeVehicles;
  final RefreshCustomersUseCase refreshCustomers;
  final GetObdDevicesUseCase getObdDevices;
  final GetBranchDailyAttendanceUseCase getBranchDailyAttendance;
  final GetPendingJustificationsUseCase getPendingJustifications;
  final ApproveJustificationUseCase approveJustification;
  final RejectJustificationUseCase rejectJustification;
  final ObserveTodayAttendanceUseCase observePersonalToday;
  final ObserveMyTasksUseCase observeMyTasks;
  final ObservePendingOperationCountUseCase observePendingSyncCount;
  final ObservePushHistoryUseCase observePushHistory;
  final ConnectivityObserver connectivity;
  final BusinessTime time;
  final Duration linger;
  final FindPendingSuspensionsUseCase? findPendingSuspensions;

  AdminDashboardViewModel({
    this.findPendingSuspensions,
    required this.observeSession,
    required this.getBranches,
    required this.observeOrders,
    required this.refreshOrders,
    required this.observeBayBoard,
    required this.refreshBayBoard,
    required this.getStockAlerts,
    required this.enrichReferences,
    required this.observeAppointments,
    required this.refreshAppointments,
    required this.observeCustomers,
    required this.observeVehicles,
    required this.refreshCustomers,
    required this.getObdDevices,
    required this.getBranchDailyAttendance,
    required this.getPendingJustifications,
    required this.approveJustification,
    required this.rejectJustification,
    required this.observePersonalToday,
    required this.observeMyTasks,
    required this.observePendingSyncCount,
    required this.observePushHistory,
    required this.connectivity,
    this.time = const BusinessTime(),
    this.linger = resolvedLinger,
  }) {
    _today = time.today();
    _state = AdminDashboardUiState(today: _today, isOnline: connectivity.isOnline);
    _listen();
    refresh();
  }

  late final String _today;
  late AdminDashboardUiState _state;
  AdminDashboardUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Session? _session;
  String? _lastBranchId;
  final Set<String> _enrichedIds = {};
  bool _disposed = false;

  void _listen() {
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(
      observePersonalToday.execute().listen(
        (personal) => _update(_state.copyWith(personalTodayAttendance: personal)),
      ),
    );
    _subscriptions.add(
      observeMyTasks.execute().listen((tasks) {
        final active = tasks.where((t) => t.status != TaskStatus.completed).length;
        _update(_state.copyWith(activePersonalTasksCount: active));
      }),
    );
    _subscriptions.add(observeOrders.execute().listen(_onOrders));
    _subscriptions.add(observeBayBoard.execute().listen((bays) => _update(_state.copyWith(bays: bays)), onError: (Object _) {}));
    _subscriptions.add(
      observeAppointments.execute(_today).listen(
        (list) => _update(_state.copyWith(appointments: list)),
      ),
    );
    _subscriptions.add(
      observeCustomers.execute().listen(
        (list) => _update(_state.copyWith(customersCount: list.length)),
      ),
    );
    _subscriptions.add(
      observeVehicles.execute().listen(
        (list) => _update(_state.copyWith(vehiclesCount: list.length)),
      ),
    );
    _subscriptions.add(
      observePendingSyncCount.execute().listen(
        (count) => _update(_state.copyWith(pendingSyncCount: count)),
      ),
    );
    _subscriptions.add(
      observePushHistory.execute().listen(
        (records) => _update(
          _state.copyWith(unreadNotificationsCount: records.where((r) => !r.read).length),
        ),
      ),
    );
    connectivity.addListener(_onConnectivity);
  }

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  void _onSession(Session? session) {
    final branchChanged = _lastBranchId != null && session?.branchId != _lastBranchId;
    _lastBranchId = session?.branchId;
    _session = session;
    bool has(Permission permission) => session?.has(permission) ?? false;
    _update(
      _state.copyWith(
        fullName: session?.fullName ?? '',
        tenantName: session?.tenantName ?? '',
        branchId: session?.branchId,
        canCreateWorkOrder: has(Permission.workOrdersCreate),
        canReadWorkOrders: has(Permission.workOrdersRead),
        canStartWorkOrders: has(Permission.workOrdersUpdate),
        canValidateSuspension: has(Permission.tasksHoldValidate),
        canReadBays: has(Permission.baysRead),
        canReadAppointments: has(Permission.appointmentsRead),
        canReadCustomers: has(Permission.customersRead),
        canRegisterCustomers: has(Permission.customersCreate),
        canReadInventory: has(Permission.inventoryAlertsRead),
        canReadObd: has(Permission.obdDevicesRead) && session?.plan?.iotTelemetryEnabled != false,
        canAuditAttendance: has(Permission.attendanceAuditAll),
        canApproveJustifications: has(Permission.justificationsApprove),
        canClockPersonalAttendance:
            has(Permission.attendanceClockIn) || has(Permission.attendanceClockOut),
        canWorkOwnTasks: has(Permission.tasksTrackTime) && has(Permission.tasksRead),
      ),
    );
    if (branchChanged) refresh();
  }

  void _onOrders(List<WorkOrder> orders) {
    _update(_state.copyWith(orders: orders));
    final missingVehicles = {
      for (final order in orders)
        if (order.plate == null && !_enrichedIds.contains(order.vehicleId)) order.vehicleId,
    };
    final missingCustomers = {
      for (final order in orders)
        if (order.customerName == null && !_enrichedIds.contains(order.customerId))
          order.customerId,
    };
    if (missingVehicles.isNotEmpty || missingCustomers.isNotEmpty) {
      _enrichedIds
        ..addAll(missingVehicles)
        ..addAll(missingCustomers);
      unawaited(_enrich(missingVehicles, missingCustomers));
    }
  }

  Future<void> _enrich(Set<String> vehicles, Set<String> customers) async {
    try {
      await enrichReferences.execute(vehicles, customers);
    } on Object {
      // Nunca falla la pantalla: sin red o sin permiso se sigue con la caché.
    }
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    final session = _session ?? await observeSession.execute().first;
    bool has(Permission permission) => session?.has(permission) ?? false;
    Object? failure;

    if (has(Permission.branchesRead)) {
      try {
        final branches = await getBranches.execute();
        final name = branches.where((b) => b.id == session!.branchId).firstOrNull?.name;
        _update(
          _state.copyWith(
            branchName: name,
            canChangeBranch: session!.canSwitchBranch() && branches.length > 1,
          ),
        );
      } on Object {
        // Sin red se conserva el nombre previo.
      }
    }
    if (has(Permission.workOrdersRead)) {
      try {
        await refreshOrders.execute();
      } on Object catch (e) {
        failure = e;
      }
      if (failure == null && has(Permission.tasksHoldValidate)) await _loadPendingSuspensions();
    }
    if (has(Permission.baysRead)) {
      await _ignoring(() => refreshBayBoard.execute());
    }
    if (has(Permission.appointmentsRead)) {
      await _ignoring(() => refreshAppointments.execute(_today));
    }
    if (has(Permission.customersRead)) {
      await _ignoring(() => refreshCustomers.execute());
    }
    if (has(Permission.inventoryAlertsRead)) {
      try {
        _update(_state.copyWith(stockAlerts: await getStockAlerts.execute()));
      } on Object {
        // El indicador conserva el último valor.
      }
    }
    if (has(Permission.obdDevicesRead) && session?.plan?.iotTelemetryEnabled != false) {
      try {
        final devices = await getObdDevices.execute(status: null);
        _update(_state.copyWith(obdDevices: devices));
      } on Object {
        // El indicador conserva el último valor.
      }
    }
    if (has(Permission.attendanceAuditAll)) {
      try {
        final records = await getBranchDailyAttendance.execute(_today);
        _update(_state.copyWith(branchAttendances: records));
      } on Object {
        // El indicador conserva el último valor.
      }
      try {
        final pending = await getPendingJustifications.execute();
        _update(
          _state.copyWith(
            justifications: pending.items,
            failedJustificationDays: pending.failedDates.length,
            resolved: const {},
          ),
        );
      } on Object {
        // Sin consulta no hay decisiones nuevas.
      }
    }
    _update(
      _state.copyWith(
        isRefreshing: false,
        hasLoaded: true,
        error: failure == null ? null : toUiText(failure),
      ),
    );
  }

  /// US29 (H5): solicitudes de suspensión que esperan al supervisor en las órdenes activas.
  Future<void> _loadPendingSuspensions() async {
    final find = findPendingSuspensions;
    if (find == null) return;
    await _ignoring(() async {
      final pending = await find.execute(await observeOrders.execute().first);
      _update(_state.copyWith(pendingSuspensions: pending));
    });
  }

  Future<void> _ignoring(Future<void> Function() run) async {
    try {
      await run();
    } on Object {
      // Se sigue con la caché.
    }
  }

  void onOpenJustification(TeamAttendance item) {
    if (_state.resolved.containsKey(item.id)) return;
    _update(_state.copyWith(reviewing: item, clearReviewError: true));
  }

  void onDismissJustification() {
    if (_state.isSubmittingReview) return;
    _update(_state.copyWith(clearReviewing: true, clearReviewError: true));
  }

  Future<void> onReviewJustification(bool approve) async {
    final item = _state.reviewing;
    if (item == null || !_state.canApproveJustifications || _state.isSubmittingReview) return;
    _update(_state.copyWith(isSubmittingReview: true, clearReviewError: true));
    try {
      if (approve) {
        await approveJustification.execute(item.id);
      } else {
        await rejectJustification.execute(item.id);
      }
    } on Object catch (e) {
      _update(_state.copyWith(isSubmittingReview: false, reviewError: toUiText(e)));
      return;
    }
    _update(
      _state.copyWith(
        isSubmittingReview: false,
        clearReviewing: true,
        resolved: {..._state.resolved, item.id: approve},
      ),
    );
    await Future<void>.delayed(linger);
    final remaining = {..._state.resolved}..remove(item.id);
    _update(
      _state.copyWith(
        justifications: _state.justifications.where((j) => j.id != item.id).toList(),
        resolved: remaining,
      ),
    );
  }

  void _update(AdminDashboardUiState state) {
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
