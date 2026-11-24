import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';

/// "Hoy": el panel de la sede. Todo sale de listas (órdenes abiertas, citas, clientes, asistencia del día,
/// escáneres OBD y descargos por revisar). Sin tablero de bahías, alertas de stock ni suspensiones: son
/// historias fuera de esta versión (US34, US40, US29).
class AdminDashboardUiState {
  /// Día de Lima `yyyy-MM-dd`; vacío mientras no se conoce.
  final String today;
  final String fullName;
  final String tenantName;
  final String? branchId;
  final String? branchName;
  final bool canChangeBranch;
  final List<WorkOrder> orders;
  final List<Appointment> appointments;
  final List<ObdDevice> obdDevices;
  final int customersCount;
  final int vehiclesCount;
  final List<TeamAttendance> branchAttendances;
  final List<TeamAttendance> justifications;

  /// Descargos ya resueltos (id → aprobado) que aún muestran su resultado antes de retirarse de la lista.
  final Map<String, bool> resolved;

  /// Días de descargos cuya consulta falló (H32): el resultado es parcial y se avisa.
  final int failedJustificationDays;
  final TeamAttendance? reviewing;
  final bool isSubmittingReview;
  final UiText? reviewError;
  final int pendingSyncCount;
  final int unreadNotificationsCount;
  final bool isRefreshing;
  final bool hasLoaded;
  final bool isOnline;
  final UiText? error;
  final bool canCreateWorkOrder;
  final bool canReadWorkOrders;
  final bool canStartWorkOrders;
  final bool canReadAppointments;
  final bool canReadCustomers;
  final bool canRegisterCustomers;
  final bool canReadObd;
  final bool canAuditAttendance;
  final bool canApproveJustifications;
  final bool canClockPersonalAttendance;
  final TodayAttendance personalTodayAttendance;
  final bool canWorkOwnTasks;
  final int activePersonalTasksCount;

  const AdminDashboardUiState({
    this.today = '',
    this.fullName = '',
    this.tenantName = '',
    this.branchId,
    this.branchName,
    this.canChangeBranch = false,
    this.orders = const [],
    this.appointments = const [],
    this.obdDevices = const [],
    this.customersCount = 0,
    this.vehiclesCount = 0,
    this.branchAttendances = const [],
    this.justifications = const [],
    this.resolved = const {},
    this.failedJustificationDays = 0,
    this.reviewing,
    this.isSubmittingReview = false,
    this.reviewError,
    this.pendingSyncCount = 0,
    this.unreadNotificationsCount = 0,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.isOnline = true,
    this.error,
    this.canCreateWorkOrder = false,
    this.canReadWorkOrders = false,
    this.canStartWorkOrders = false,
    this.canReadAppointments = false,
    this.canReadCustomers = false,
    this.canRegisterCustomers = false,
    this.canReadObd = false,
    this.canAuditAttendance = false,
    this.canApproveJustifications = false,
    this.canClockPersonalAttendance = false,
    this.personalTodayAttendance = const NotClockedIn(),
    this.canWorkOwnTasks = false,
    this.activePersonalTasksCount = 0,
  });

  /// La caché de la sede no guarda órdenes cerradas: toda orden aquí es un auto en el taller.
  int get carsInWorkshop => orders.length;
  int get readyOrdersCount =>
      orders.where((o) => o.status == WorkOrderStatus.completed).length;
  int get onShiftCount => branchAttendances.where((a) => a.clockOut == null).length;
  int get inProgressCount =>
      orders.where((o) => o.status == WorkOrderStatus.inProgress).length;
  int get draftOrdersCount =>
      orders.where((o) => o.status == WorkOrderStatus.draft).length;
  int get pendingJustificationsCount => justifications.length;
  int get activeObdCount =>
      obdDevices.where((d) => d.status == DeviceStatus.active).length;

  /// Órdenes abiertas sin iniciar: alguien con `work_orders:update` debe revisar la proforma y darles inicio.
  List<WorkOrder> get draftOrders => canStartWorkOrders
      ? orders.where((o) => o.status == WorkOrderStatus.draft).toList()
      : const [];

  int get decisionsCount =>
      draftOrders.length + justifications.where((j) => !resolved.containsKey(j.id)).length;

  /// Esqueleto solo sin caché: primera carga y nada que pintar todavía.
  bool get showSkeleton => !hasLoaded && orders.isEmpty;

  AdminDashboardUiState copyWith({
    String? today,
    String? fullName,
    String? tenantName,
    String? branchId,
    String? branchName,
    bool? canChangeBranch,
    List<WorkOrder>? orders,
    List<Appointment>? appointments,
    List<ObdDevice>? obdDevices,
    int? customersCount,
    int? vehiclesCount,
    List<TeamAttendance>? branchAttendances,
    List<TeamAttendance>? justifications,
    Map<String, bool>? resolved,
    int? failedJustificationDays,
    TeamAttendance? reviewing,
    bool clearReviewing = false,
    bool? isSubmittingReview,
    UiText? reviewError,
    bool clearReviewError = false,
    int? pendingSyncCount,
    int? unreadNotificationsCount,
    bool? isRefreshing,
    bool? hasLoaded,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canCreateWorkOrder,
    bool? canReadWorkOrders,
    bool? canStartWorkOrders,
    bool? canReadAppointments,
    bool? canReadCustomers,
    bool? canRegisterCustomers,
    bool? canReadObd,
    bool? canAuditAttendance,
    bool? canApproveJustifications,
    bool? canClockPersonalAttendance,
    TodayAttendance? personalTodayAttendance,
    bool? canWorkOwnTasks,
    int? activePersonalTasksCount,
  }) {
    return AdminDashboardUiState(
      today: today ?? this.today,
      fullName: fullName ?? this.fullName,
      tenantName: tenantName ?? this.tenantName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      canChangeBranch: canChangeBranch ?? this.canChangeBranch,
      orders: orders ?? this.orders,
      appointments: appointments ?? this.appointments,
      obdDevices: obdDevices ?? this.obdDevices,
      customersCount: customersCount ?? this.customersCount,
      vehiclesCount: vehiclesCount ?? this.vehiclesCount,
      branchAttendances: branchAttendances ?? this.branchAttendances,
      justifications: justifications ?? this.justifications,
      resolved: resolved ?? this.resolved,
      failedJustificationDays: failedJustificationDays ?? this.failedJustificationDays,
      reviewing: clearReviewing ? null : reviewing ?? this.reviewing,
      isSubmittingReview: isSubmittingReview ?? this.isSubmittingReview,
      reviewError: clearReviewError ? null : reviewError ?? this.reviewError,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canCreateWorkOrder: canCreateWorkOrder ?? this.canCreateWorkOrder,
      canReadWorkOrders: canReadWorkOrders ?? this.canReadWorkOrders,
      canStartWorkOrders: canStartWorkOrders ?? this.canStartWorkOrders,
      canReadAppointments: canReadAppointments ?? this.canReadAppointments,
      canReadCustomers: canReadCustomers ?? this.canReadCustomers,
      canRegisterCustomers: canRegisterCustomers ?? this.canRegisterCustomers,
      canReadObd: canReadObd ?? this.canReadObd,
      canAuditAttendance: canAuditAttendance ?? this.canAuditAttendance,
      canApproveJustifications: canApproveJustifications ?? this.canApproveJustifications,
      canClockPersonalAttendance:
          canClockPersonalAttendance ?? this.canClockPersonalAttendance,
      personalTodayAttendance: personalTodayAttendance ?? this.personalTodayAttendance,
      canWorkOwnTasks: canWorkOwnTasks ?? this.canWorkOwnTasks,
      activePersonalTasksCount: activePersonalTasksCount ?? this.activePersonalTasksCount,
    );
  }
}
