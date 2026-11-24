import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/get_current_location_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/is_location_permission_granted_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_attendance_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_weekly_schedule_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/submit_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/navigation/attendance_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';

/// Pantallas de `attendance`: el hub "Turno" (raíz de la pestaña) y "Mi asistencia".
void setupAttendancePresentation() {
  registerAttendanceRoutes();

  getIt.registerFactory<AttendanceViewModel>(
    () => AttendanceViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeToday: getIt<ObserveTodayAttendanceUseCase>(),
      observeHistory: getIt<ObserveAttendanceHistoryUseCase>(),
      observeSchedule: getIt<ObserveWeeklyScheduleUseCase>(),
      refreshAttendance: getIt<RefreshAttendanceUseCase>(),
      clockInUseCase: getIt<ClockInUseCase>(),
      clockOutUseCase: getIt<ClockOutUseCase>(),
      submitJustificationUseCase: getIt<SubmitJustificationUseCase>(),
      getCurrentLocation: getIt<GetCurrentLocationUseCase>(),
      isLocationPermissionGranted: getIt<IsLocationPermissionGrantedUseCase>(),
    ),
  );
  getIt.registerFactory<FloorHubViewModel>(
    () => FloorHubViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeToday: getIt<ObserveTodayAttendanceUseCase>(),
      observeSchedule: getIt<ObserveWeeklyScheduleUseCase>(),
      refreshAttendance: getIt<RefreshAttendanceUseCase>(),
      clockInUseCase: getIt<ClockInUseCase>(),
      clockOutUseCase: getIt<ClockOutUseCase>(),
      observeMyTasks: getIt<ObserveMyTasksUseCase>(),
      refreshMyTasks: getIt<RefreshMyTasksUseCase>(),
      observeAppointments: getIt<ObserveAppointmentsUseCase>(),
      refreshAppointments: getIt<RefreshAppointmentsUseCase>(),
      observeBranchOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      refreshBranchOrders: getIt<RefreshBranchWorkOrdersUseCase>(),
      observePartsCatalog: getIt<ObservePartsCatalogUseCase>(),
      refreshPartsCatalog: getIt<RefreshPartsCatalogUseCase>(),
      getPurchaseOrders: getIt<GetPurchaseOrdersUseCase>(),
      getDailyCashSummary: getIt<GetDailyCashSummaryUseCase>(),
      getObdDevices: getIt<GetObdDevicesUseCase>(),
      observePendingCount: getIt<ObservePendingOperationCountUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
