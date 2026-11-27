import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/is_notification_permission_granted_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/mark_all_push_notifications_read_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/open_push_notification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:flutter/foundation.dart';

class NotificationsViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObservePushHistoryUseCase observePushHistory;
  final OpenPushNotificationUseCase openPushNotification;
  final MarkAllPushNotificationsReadUseCase markAllPushNotificationsRead;
  final GetBranchDailyAttendanceUseCase getBranchDailyAttendance;
  final GetStockAlertsUseCase getStockAlerts;
  final ObserveBranchWorkOrdersUseCase observeOrders;
  final ObservePendingOperationCountUseCase observePendingSyncCount;
  final IsNotificationPermissionGrantedUseCase isNotificationPermissionGranted;
  final RequestNotificationPermissionUseCase requestNotificationPermission;
  final BusinessTime time;

  NotificationsViewModel({
    required this.observeSession,
    required this.observePushHistory,
    required this.openPushNotification,
    required this.markAllPushNotificationsRead,
    required this.getBranchDailyAttendance,
    required this.getStockAlerts,
    required this.observeOrders,
    required this.observePendingSyncCount,
    required this.isNotificationPermissionGranted,
    required this.requestNotificationPermission,
    this.time = const BusinessTime(),
  }) {
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(
      observePushHistory.execute().listen(
        (items) => _update(_state.copyWith(pushHistory: items)),
      ),
    );
    _subscriptions.add(
      observeOrders.execute().listen(
        (orders) => _update(
          _state.copyWith(
            draftOrdersWaitingApproval: [
              for (final order in orders)
                if (order.status == WorkOrderStatus.draft) order,
            ],
          ),
        ),
      ),
    );
    _subscriptions.add(
      observePendingSyncCount.execute().listen(
        (count) => _update(_state.copyWith(pendingSyncCount: count)),
      ),
    );
    refreshNotificationsEnabled();
    refresh();
  }

  NotificationsUiState _state = const NotificationsUiState();
  NotificationsUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  Session? _session;
  bool _disposed = false;

  void _onSession(Session? session) {
    _session = session;
    _update(_state.copyWith(session: session));
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    final session = _session ?? await observeSession.execute().first;
    var stockAlerts = const <StockAlert>[];
    if ((session?.has(Permission.inventoryAlertsRead) ?? false) || (session?.has(Permission.partsRead) ?? false)) {
      try {
        stockAlerts = await getStockAlerts.execute();
      } on Object {
        // La bandeja sigue sin esa sección.
      }
    }
    var justifications = const <TeamAttendance>[];
    if (session?.has(Permission.attendanceAuditAll) ?? false) {
      try {
        final records = await getBranchDailyAttendance.execute(time.today());
        justifications = [for (final record in records) if (record.awaitsReview) record];
      } on Object {
        // La bandeja sigue sin esa sección.
      }
    }
    _update(_state.copyWith(isLoading: false, stockAlerts: stockAlerts, pendingJustifications: justifications));
  }

  /// Vuelve a leer el permiso del sistema (al abrir y al volver de los ajustes).
  Future<void> refreshNotificationsEnabled() async {
    try {
      final granted = await isNotificationPermissionGranted.execute();
      _update(_state.copyWith(notificationsEnabled: granted));
    } on Object {
      // Sin lectura se deja el aviso como estaba.
    }
  }

  Future<void> enableNotifications() async {
    try {
      final granted = await requestNotificationPermission.execute();
      _update(_state.copyWith(notificationsEnabled: granted));
    } on Object {
      // El aviso sigue visible.
    }
    await refreshNotificationsEnabled();
  }

  /// Lo marca leído y reabre su destino por la misma vía que un push tocado.
  void onOpenPushRecord(NotificationRecord record) => openPushNotification.execute(record.id);

  void onMarkAllRead() => markAllPushNotificationsRead.execute();

  void _update(NotificationsUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
