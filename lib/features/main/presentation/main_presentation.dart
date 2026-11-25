import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/is_notification_permission_granted_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/discard_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/mark_all_push_notifications_read_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operations_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/open_push_notification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/retry_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/sync_now_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_pending_suspensions_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Pantallas de `main`: "Hoy" (dashboard), "Equipo" (asistencia de sede), notificaciones, perfil y pendientes de
/// sincronizar. El shell (barra y pestañas) lo registra `setupMainShellPresentation`.
void setupMainPresentation() {
  AppNavigator.register(AppRoute.adminDashboard, (context, args) => const AdminDashboardScreen());
  AppNavigator.register(AppRoute.adminAttendance, (context, args) => const AdminAttendanceScreen());
  AppNavigator.register(AppRoute.notifications, (context, args) => const NotificationsScreen());
  AppNavigator.register(
    AppRoute.pendingOperations,
    (context, args) => const PendingOperationsScreen(),
  );
  AppNavigator.register(AppRoute.profile, (context, args) => const ProfileScreen());

  getIt.registerFactory<AdminDashboardViewModel>(
    () => AdminDashboardViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      getBranches: getIt<GetSelectableBranchesUseCase>(),
      observeOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      refreshOrders: getIt<RefreshBranchWorkOrdersUseCase>(),
      enrichReferences: getIt<EnrichReceptionReferencesUseCase>(),
      observeAppointments: getIt<ObserveAppointmentsUseCase>(),
      refreshAppointments: getIt<RefreshAppointmentsUseCase>(),
      observeCustomers: getIt<ObserveCustomersUseCase>(),
      observeVehicles: getIt<ObserveWorkshopVehiclesUseCase>(),
      refreshCustomers: getIt<RefreshCustomersUseCase>(),
      getObdDevices: getIt<GetObdDevicesUseCase>(),
      getBranchDailyAttendance: getIt<GetBranchDailyAttendanceUseCase>(),
      getPendingJustifications: getIt<GetPendingJustificationsUseCase>(),
      approveJustification: getIt<ApproveJustificationUseCase>(),
      rejectJustification: getIt<RejectJustificationUseCase>(),
      observePersonalToday: getIt<ObserveTodayAttendanceUseCase>(),
      observeMyTasks: getIt<ObserveMyTasksUseCase>(),
      observePendingSyncCount: getIt<ObservePendingOperationCountUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      findPendingSuspensions: getIt<FindPendingSuspensionsUseCase>(),
    ),
  );
  getIt.registerFactory<AdminAttendanceViewModel>(
    () => AdminAttendanceViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      getBranches: getIt<GetSelectableBranchesUseCase>(),
      getBranchDaily: getIt<GetBranchDailyAttendanceUseCase>(),
      getPendingJustifications: getIt<GetPendingJustificationsUseCase>(),
      approveJustification: getIt<ApproveJustificationUseCase>(),
      rejectJustification: getIt<RejectJustificationUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
  getIt.registerFactory<NotificationsViewModel>(
    () => NotificationsViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
      openPushNotification: getIt<OpenPushNotificationUseCase>(),
      markAllPushNotificationsRead: getIt<MarkAllPushNotificationsReadUseCase>(),
      getBranchDailyAttendance: getIt<GetBranchDailyAttendanceUseCase>(),
      observeOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      observePendingSyncCount: getIt<ObservePendingOperationCountUseCase>(),
      isNotificationPermissionGranted: getIt<IsNotificationPermissionGrantedUseCase>(),
      requestNotificationPermission: getIt<RequestNotificationPermissionUseCase>(),
    ),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observePendingCount: getIt<ObservePendingOperationCountUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
      getBranches: getIt<GetSelectableBranchesUseCase>(),
      loadVersion: () async => (await PackageInfo.fromPlatform()).version,
    ),
  );
  getIt.registerFactory<PendingOperationsViewModel>(
    () => PendingOperationsViewModel(
      observeOperations: getIt<ObservePendingOperationsUseCase>(),
      retryOperation: getIt<RetryPendingOperationUseCase>(),
      discardOperation: getIt<DiscardPendingOperationUseCase>(),
      syncNow: getIt<SyncNowUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
