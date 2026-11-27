import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_weekly_schedule_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:flutter/foundation.dart';

class FloorHubViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveTodayAttendanceUseCase observeToday;
  final ObserveWeeklyScheduleUseCase observeSchedule;
  final RefreshAttendanceUseCase refreshAttendance;
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;
  final ObserveMyTasksUseCase observeMyTasks;
  final RefreshMyTasksUseCase refreshMyTasks;
  final ObserveAppointmentsUseCase observeAppointments;
  final RefreshAppointmentsUseCase refreshAppointments;
  final ObserveBranchWorkOrdersUseCase observeBranchOrders;
  final RefreshBranchWorkOrdersUseCase refreshBranchOrders;
  final ObservePartsCatalogUseCase observePartsCatalog;
  final RefreshPartsCatalogUseCase refreshPartsCatalog;
  final ObserveStockAlertsUseCase observeStockAlerts;
  final GetStockAlertsUseCase getStockAlerts;
  final GetPurchaseOrdersUseCase getPurchaseOrders;
  final GetDailyCashSummaryUseCase getDailyCashSummary;
  final GetObdDevicesUseCase getObdDevices;
  final ObservePendingOperationCountUseCase observePendingCount;
  final ObservePushHistoryUseCase observePushHistory;
  final ConnectivityObserver connectivity;
  final BusinessTime time;

  FloorHubViewModel({
    required this.observeSession,
    required this.observeToday,
    required this.observeSchedule,
    required this.refreshAttendance,
    required this.clockInUseCase,
    required this.clockOutUseCase,
    required this.observeMyTasks,
    required this.refreshMyTasks,
    required this.observeAppointments,
    required this.refreshAppointments,
    required this.observeBranchOrders,
    required this.refreshBranchOrders,
    required this.observePartsCatalog,
    required this.refreshPartsCatalog,
    required this.observeStockAlerts,
    required this.getStockAlerts,
    required this.getPurchaseOrders,
    required this.getDailyCashSummary,
    required this.getObdDevices,
    required this.observePendingCount,
    required this.observePushHistory,
    required this.connectivity,
    this.time = const BusinessTime(),
  }) {
    _today = time.today();
    _state = FloorHubUiState(todayDate: _today, isOnline: connectivity.isOnline);
    _subscriptions.add(
      observeSession.execute().listen((session) {
        _session = session;
        _update(_state.copyWith(session: session));
      }),
    );
    _subscriptions.add(
      observeToday.execute().listen((today) => _update(_state.copyWith(todayAttendance: today))),
    );
    _subscriptions.add(
      observeSchedule.execute().listen(
        (schedule) => _update(_state.copyWith(schedule: schedule, clearSchedule: schedule == null)),
      ),
    );
    _subscriptions.add(
      observeMyTasks.execute().listen((tasks) => _update(_state.copyWith(assignedTasks: tasks))),
    );
    _subscriptions.add(
      observeAppointments.execute(_today).listen(
        (list) => _update(_state.copyWith(appointments: list)),
      ),
    );
    _subscriptions.add(
      observeBranchOrders.execute().listen((orders) => _update(_state.copyWith(branchOrders: orders))),
    );
    _subscriptions.add(
      observePartsCatalog.execute().listen((parts) => _update(_state.copyWith(catalogSize: parts.length))),
    );
    // La caché pinta de entrada; la consulta en línea manda una vez que llega.
    _subscriptions.add(
      observeStockAlerts.execute().listen((cached) {
        if (_state.stockAlerts.isEmpty) _update(_state.copyWith(stockAlerts: cached));
      }),
    );
    _subscriptions.add(
      observePendingCount.execute().listen((count) => _update(_state.copyWith(pendingSyncCount: count))),
    );
    _subscriptions.add(
      observePushHistory.execute().listen(
        (records) => _update(
          _state.copyWith(unreadNotificationsCount: records.where((r) => !r.read).length),
        ),
      ),
    );
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  late final String _today;
  late FloorHubUiState _state;
  FloorHubUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Session? _session;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true, clearNotice: true));
    final session = _session ?? await observeSession.execute().first;
    bool has(Permission permission) => session?.has(permission) ?? false;
    await Future.wait([
      if (has(Permission.attendanceReadOwn)) _ignoring(refreshAttendance.execute),
      if (has(Permission.tasksRead)) _ignoring(refreshMyTasks.execute),
      if (has(Permission.appointmentsRead)) _ignoring(() => refreshAppointments.execute(_today)),
      if (has(Permission.workOrdersRead)) _ignoring(refreshBranchOrders.execute),
      if (has(Permission.partsRead)) _ignoring(() => refreshPartsCatalog.execute()),
      if (has(Permission.alertsRead))
        _ignoring(() async => _update(_state.copyWith(stockAlerts: await getStockAlerts.execute()))),
      if (has(Permission.purchaseOrdersRead))
        _ignoring(() async {
          final orders = await getPurchaseOrders.execute(status: PurchaseOrderStatus.issued);
          _update(_state.copyWith(issuedPurchaseOrders: orders));
        }),
      if (has(Permission.invoicesRead))
        _ignoring(() async {
          final summary = await getDailyCashSummary.execute(_today);
          _update(_state.copyWith(dailyCash: summary));
        }),
      if (has(Permission.devicesRead) && session?.plan?.iotTelemetryEnabled != false)
        _ignoring(() async {
          final devices = await getObdDevices.execute();
          _update(_state.copyWith(activeObdCount: devices.length));
        }),
    ]);
    _update(_state.copyWith(isRefreshing: false, hasLoaded: true));
  }

  Future<void> _ignoring(Future<void> Function() run) async {
    try {
      await run();
    } on Object {
      // Cada bloque se queda con su caché si falla.
    }
  }

  Future<void> clockIn() async {
    final session = _state.session;
    if (session == null) return;
    if (!session.has(Permission.attendanceClockIn)) {
      _update(_state.copyWith(error: UiText.resource((s) => s.attendancePermissionClockIn)));
      return;
    }
    final branchId = session.branchId;
    final shiftId = session.shiftId;
    if (branchId == null || branchId.trim().isEmpty || shiftId == null || shiftId.trim().isEmpty) {
      _update(_state.copyWith(error: UiText.resource((s) => s.attendanceMissingAssignment)));
      return;
    }
    _update(_state.copyWith(isSubmittingAttendance: true, clearError: true, clearNotice: true));
    try {
      final result = await clockInUseCase.execute(branchId, shiftId);
      final notice = switch (result.outcome) {
        Recorded() => UiText.resource((s) => s.attendanceClockInRecorded),
        Queued() || AlreadyQueued() => UiText.resource((s) => s.attendanceClockInQueued),
      };
      _update(_state.copyWith(isSubmittingAttendance: false, notice: notice));
    } on Object catch (e) {
      _update(_state.copyWith(isSubmittingAttendance: false, error: toAttendanceUiText(e)));
    }
  }

  Future<void> clockOut() async {
    final session = _state.session;
    if (session == null) return;
    if (!session.has(Permission.attendanceClockOut)) {
      _update(_state.copyWith(error: UiText.resource((s) => s.attendancePermissionClockOut)));
      return;
    }
    _update(_state.copyWith(isSubmittingAttendance: true, clearError: true, clearNotice: true));
    try {
      final outcome = await clockOutUseCase.execute();
      final notice = switch (outcome) {
        Recorded() => UiText.resource((s) => s.attendanceClockOutRecorded),
        Queued() || AlreadyQueued() => UiText.resource((s) => s.attendanceClockOutQueued),
      };
      _update(_state.copyWith(isSubmittingAttendance: false, notice: notice));
    } on Object catch (e) {
      _update(_state.copyWith(isSubmittingAttendance: false, error: toAttendanceUiText(e)));
    }
  }

  void _update(FloorHubUiState state) {
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
