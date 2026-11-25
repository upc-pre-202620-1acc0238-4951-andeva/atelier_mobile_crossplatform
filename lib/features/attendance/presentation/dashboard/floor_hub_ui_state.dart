import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';

/// Estado único del Hub de Piso y Mostrador (`FloorHubScreen`). Compone únicamente las secciones que los
/// permisos atómicos de la sesión habilitan (Técnico, Recepcionista, Almacén, Cajero o híbridos). Sin alertas de
/// stock ni bahías (US34, US40).
class FloorHubUiState {
  /// Día de Lima `yyyy-MM-dd`.
  final String todayDate;
  final Session? session;
  final WeeklySchedule? schedule;
  final TodayAttendance todayAttendance;
  final List<Task> assignedTasks;
  final List<Appointment> appointments;
  final List<WorkOrder> branchOrders;
  final List<PurchaseOrder> issuedPurchaseOrders;
  final int catalogSize;
  final DailyCashSummary? dailyCash;
  final int activeObdCount;
  final int pendingSyncCount;
  final int unreadNotificationsCount;
  final bool isOnline;
  final bool isRefreshing;
  final bool hasLoaded;
  final bool isSubmittingAttendance;
  final UiText? error;
  final UiText? notice;

  const FloorHubUiState({
    this.todayDate = '',
    this.session,
    this.schedule,
    this.todayAttendance = const NotClockedIn(),
    this.assignedTasks = const [],
    this.appointments = const [],
    this.branchOrders = const [],
    this.issuedPurchaseOrders = const [],
    this.catalogSize = 0,
    this.dailyCash,
    this.activeObdCount = 0,
    this.pendingSyncCount = 0,
    this.unreadNotificationsCount = 0,
    this.isOnline = true,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.isSubmittingAttendance = false,
    this.error,
    this.notice,
  });

  String get fullName => session?.fullName ?? '';
  String get tenantName => session?.tenantName ?? '';
  String? get branchName => schedule?.branch?.name;

  bool _has(Permission permission) => session?.has(permission) ?? false;

  bool get canClockInPerm => _has(Permission.attendanceClockIn);
  bool get canClockOutPerm => _has(Permission.attendanceClockOut);
  bool get canTrackTasks => _has(Permission.tasksTrackTime) && _has(Permission.tasksRead);
  bool get canUseCounter => _has(Permission.appointmentsRead) || _has(Permission.customersCreate);
  bool get canManageStock =>
      _has(Permission.partsManage) ||
      _has(Permission.purchaseOrdersCreate) ||
      _has(Permission.batchesReceive);
  bool get canOperateCash => _has(Permission.invoicesIssueSunat) || _has(Permission.paymentsCreate);

  bool get canReportFinding => _has(Permission.proposalsCreate);
  bool get canUseObd =>
      (session?.canUseTelemetry() ?? false) ||
      (session?.canReadTelemetry() ?? false) ||
      _has(Permission.devicesRead);
  bool get canReadParts => _has(Permission.partsRead);
  bool get canReadBays => _has(Permission.baysRead);

  Task? get activeTask {
    for (final task in assignedTasks) {
      if (task.status == TaskStatus.inProgress) return task;
    }
    for (final task in assignedTasks) {
      if (task.status == TaskStatus.onHold) return task;
    }
    return null;
  }

  int get pendingTasksCount => assignedTasks.where((t) => t.status != TaskStatus.completed).length;
  int get completedTasksCount => assignedTasks.where((t) => t.status == TaskStatus.completed).length;
  int get inProgressTasksCount =>
      assignedTasks.where((t) => t.status == TaskStatus.inProgress).length;

  List<WorkOrder> get readyToBillOrders =>
      branchOrders.where((o) => o.status == WorkOrderStatus.completed).toList();

  bool get canClockInNow =>
      canClockInPerm &&
      !isSubmittingAttendance &&
      session?.branchId != null &&
      session?.shiftId != null &&
      todayAttendance is NotClockedIn;

  bool get canClockOutNow =>
      canClockOutPerm &&
      !isSubmittingAttendance &&
      (todayAttendance is ClockedIn || todayAttendance is ClockInQueued);

  bool get showSkeleton =>
      !hasLoaded &&
      assignedTasks.isEmpty &&
      appointments.isEmpty &&
      branchOrders.isEmpty &&
      issuedPurchaseOrders.isEmpty;

  FloorHubUiState copyWith({
    String? todayDate,
    Session? session,
    WeeklySchedule? schedule,
    bool clearSchedule = false,
    TodayAttendance? todayAttendance,
    List<Task>? assignedTasks,
    List<Appointment>? appointments,
    List<WorkOrder>? branchOrders,
    List<PurchaseOrder>? issuedPurchaseOrders,
    int? catalogSize,
    DailyCashSummary? dailyCash,
    int? activeObdCount,
    int? pendingSyncCount,
    int? unreadNotificationsCount,
    bool? isOnline,
    bool? isRefreshing,
    bool? hasLoaded,
    bool? isSubmittingAttendance,
    UiText? error,
    bool clearError = false,
    UiText? notice,
    bool clearNotice = false,
  }) {
    return FloorHubUiState(
      todayDate: todayDate ?? this.todayDate,
      session: session ?? this.session,
      schedule: clearSchedule ? null : schedule ?? this.schedule,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      assignedTasks: assignedTasks ?? this.assignedTasks,
      appointments: appointments ?? this.appointments,
      branchOrders: branchOrders ?? this.branchOrders,
      issuedPurchaseOrders: issuedPurchaseOrders ?? this.issuedPurchaseOrders,
      catalogSize: catalogSize ?? this.catalogSize,
      dailyCash: dailyCash ?? this.dailyCash,
      activeObdCount: activeObdCount ?? this.activeObdCount,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      isOnline: isOnline ?? this.isOnline,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isSubmittingAttendance: isSubmittingAttendance ?? this.isSubmittingAttendance,
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
    );
  }
}
