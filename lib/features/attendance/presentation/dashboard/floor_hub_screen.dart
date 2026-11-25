import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_adaptive_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_screen.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Hub de Piso y Mostrador ("Turno") del Segmento 2. Compone su panel de cabecera y bloques operativos
/// exclusivamente desde los permisos de la sesión, siguiendo el sistema visual "La vía señalizada".
///
/// Sin accesos a bahías ni alertas de stock (US40, US34), a la telemetría en vivo (US18) ni al cobro de una
/// orden (US37–US39).
class FloorHubScreen extends StatefulWidget {
  const FloorHubScreen({super.key});

  @override
  State<FloorHubScreen> createState() => _FloorHubScreenState();
}

class _FloorHubScreenState extends State<FloorHubScreen> {
  late final FloorHubViewModel viewModel = getIt<FloorHubViewModel>();
  final ValueNotifier<bool> _confirmClockOut = ValueNotifier(false);
  Object? _lastNotice;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_haptics);
  }

  void _haptics() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) {
      rememberAtelierHaptics().confirm();
    }
    if (state.error != null && !identical(state.error, _lastError)) {
      rememberAtelierHaptics().reject();
    }
    _lastNotice = state.notice;
    _lastError = state.error;
  }

  @override
  void dispose() {
    viewModel.removeListener(_haptics);
    _confirmClockOut.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<bool>(
      listenable: _confirmClockOut,
      value: () => _confirmClockOut.value ? true : null,
      onDismiss: () => _confirmClockOut.value = false,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ClockOutSheet(
          isSubmitting: viewModel.state.isSubmittingAttendance,
          onConfirm: () {
            _confirmClockOut.value = false;
            viewModel.clockOut();
          },
          onCancel: () => _confirmClockOut.value = false,
        ),
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => FloorHubContent(
          state: viewModel.state,
          actions: FloorHubActions(
            onRefresh: viewModel.refresh,
            onClockIn: viewModel.clockIn,
            onRequestClockOut: () => _confirmClockOut.value = true,
            onOpenProfile: () => _open(AppRoute.profile),
            onOpenNotifications: () => _open(AppRoute.notifications),
            onOpenSyncQueue: () => _open(AppRoute.pendingOperations),
            onOpenAttendanceDetail: () => _open(AppRoute.attendanceDetail),
            onOpenTasks: () => _open(AppRoute.myTasks),
            onOpenTaskDetail: (workOrderId, taskId) => _open(
              AppRoute.taskDetail,
              TaskDetailArgs(workOrderId: workOrderId, taskId: taskId),
            ),
            onOpenObd: () => _open(AppRoute.diagnosticsHub),
            onOpenReportFinding: (workOrderId) => _open(AppRoute.reportFinding, workOrderId),
            onOpenReception: () => _open(AppRoute.vehicleSearch),
            onRegisterWalkIn: () => _open(AppRoute.registerCustomer, const RegisterCustomerArgs()),
            onOpenInventory: () => _open(AppRoute.partsCatalog),
            onOpenBays: () => _open(AppRoute.bays),
            onOpenPurchaseOrders: () => _open(AppRoute.purchaseOrders),
            onOpenPurchaseOrderDetail: (id) => _open(AppRoute.purchaseOrderDetail, id),
            onOpenWorkOrder: (id) => _open(AppRoute.workOrderDetail, id),
            onOpenDailyCash: () => _open(AppRoute.dailyCash),
          ),
        ),
      ),
    );
  }
}

class FloorHubActions {
  final Future<void> Function() onRefresh;
  final VoidCallback onClockIn;
  final VoidCallback onRequestClockOut;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSyncQueue;
  final VoidCallback onOpenAttendanceDetail;
  final VoidCallback onOpenTasks;
  final void Function(String workOrderId, String taskId) onOpenTaskDetail;
  final VoidCallback onOpenObd;
  final ValueChanged<String> onOpenReportFinding;
  final VoidCallback onOpenReception;
  final VoidCallback onRegisterWalkIn;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenBays;
  final VoidCallback onOpenPurchaseOrders;
  final ValueChanged<String> onOpenPurchaseOrderDetail;
  final ValueChanged<String> onOpenWorkOrder;
  final VoidCallback onOpenDailyCash;

  FloorHubActions({
    Future<void> Function()? onRefresh,
    VoidCallback? onClockIn,
    VoidCallback? onRequestClockOut,
    VoidCallback? onOpenProfile,
    VoidCallback? onOpenNotifications,
    VoidCallback? onOpenSyncQueue,
    VoidCallback? onOpenAttendanceDetail,
    VoidCallback? onOpenTasks,
    void Function(String, String)? onOpenTaskDetail,
    VoidCallback? onOpenObd,
    ValueChanged<String>? onOpenReportFinding,
    VoidCallback? onOpenReception,
    VoidCallback? onRegisterWalkIn,
    VoidCallback? onOpenInventory,
    VoidCallback? onOpenBays,
    VoidCallback? onOpenPurchaseOrders,
    ValueChanged<String>? onOpenPurchaseOrderDetail,
    ValueChanged<String>? onOpenWorkOrder,
    VoidCallback? onOpenDailyCash,
  }) : onRefresh = onRefresh ?? (() async {}),
       onClockIn = onClockIn ?? (() {}),
       onRequestClockOut = onRequestClockOut ?? (() {}),
       onOpenProfile = onOpenProfile ?? (() {}),
       onOpenNotifications = onOpenNotifications ?? (() {}),
       onOpenSyncQueue = onOpenSyncQueue ?? (() {}),
       onOpenAttendanceDetail = onOpenAttendanceDetail ?? (() {}),
       onOpenTasks = onOpenTasks ?? (() {}),
       onOpenTaskDetail = onOpenTaskDetail ?? ((_, _) {}),
       onOpenObd = onOpenObd ?? (() {}),
       onOpenReportFinding = onOpenReportFinding ?? ((_) {}),
       onOpenReception = onOpenReception ?? (() {}),
       onRegisterWalkIn = onRegisterWalkIn ?? (() {}),
       onOpenInventory = onOpenInventory ?? (() {}),
       onOpenBays = onOpenBays ?? (() {}),
       onOpenPurchaseOrders = onOpenPurchaseOrders ?? (() {}),
       onOpenPurchaseOrderDetail = onOpenPurchaseOrderDetail ?? ((_) {}),
       onOpenWorkOrder = onOpenWorkOrder ?? ((_) {}),
       onOpenDailyCash = onOpenDailyCash ?? (() {});
}

class FloorHubContent extends StatelessWidget {
  final FloorHubUiState state;
  final FloorHubActions actions;

  const FloorHubContent({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // Piso y fosa: objetivos táctiles de 56 dp para manos con grasa o guantes.
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        body: Column(
          children: [
            AtelierMainTopBar(
              title: state.tenantName.trim().isEmpty ? strings.appName : state.tenantName,
              subtitle: state.fullName.trim().isEmpty ? null : state.fullName,
              onOpenNotifications: actions.onOpenNotifications,
              unreadNotificationsCount: state.unreadNotificationsCount,
              onOpenSync: actions.onOpenSyncQueue,
              pendingSyncCount: state.pendingSyncCount,
              onOpenProfile: actions.onOpenProfile,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: actions.onRefresh,
                child: DelayedLoading(
                  loading: state.showSkeleton,
                  builder: (context, showSkeleton) => _list(context, strings, showSkeleton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final notice = state.notice;
    final error = state.error;
    final items = <Widget>[
      _HubReportPanel(state: state, loading: showSkeleton, actions: actions),
      if (!state.isOnline)
        _padded(
          AtelierBanner(
            message: strings.todayOfflineCache,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          ),
        ),
      if (notice != null)
        _padded(
          AtelierBanner(
            message: notice.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        ),
      if (error != null)
        _padded(
          AtelierBanner(
            message: error.asString(strings),
            icon: Icons.error_outline,
            kind: BannerKind.bad,
          ),
        ),
      // 1. Tira de marcación GPS personal (siempre visible para colaboradores con turno).
      if (state.canClockInPerm || state.canClockOutPerm || state.schedule != null)
        _ShiftExpressCard(state: state, actions: actions),
      // 2. Bloque de Fosa / Mecánico.
      if (state.canTrackTasks) ..._mechanicBlock(strings, showSkeleton),
      // 3. Bloque de Mostrador / Recepcionista.
      if (state.canUseCounter) ..._counterBlock(strings, showSkeleton),
      // 4. Bloque de Almacén / Encargado de Inventario.
      if (state.canManageStock) ..._warehouseBlock(strings, showSkeleton),
      // 5. Bloque de Caja / Cajero.
      if (state.canOperateCash) ..._cashierBlock(strings, showSkeleton),
      // 6. Accesos de piso para quien tiene herramientas adicionales.
      if (state.canTrackTasks || state.canUseObd || state.canReadBays)
        _FloorShortcutsCard(state: state, actions: actions),
      SizedBox(height: FloatingBarInset.of(context)),
    ];
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) => items[index],
    );
  }

  Widget _padded(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);

  List<Widget> _mechanicBlock(AppLocalizations strings, bool loading) {
    final active = state.activeTask;
    return [
      if (active != null) ...[
        _padded(AtelierSectionHeader(title: strings.floorHubActiveTaskSection)),
        _ActiveMechanicTaskCard(
          active: active,
          onOpenTaskDetail: () => actions.onOpenTaskDetail(active.workOrderId, active.id.value),
        ),
      ],
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: AtelierSectionHeader(
          title: strings.floorHubTasksQueueSection,
          count: state.pendingTasksCount > 0 ? state.pendingTasksCount : null,
          action: AtelierButton(
            text: strings.todaySeeAll,
            onClick: actions.onOpenTasks,
            style: AtelierButtonStyle.text,
          ),
        ),
      ),
      if (loading)
        for (var i = 0; i < 3; i++)
          const AtelierListRow(
            title: 'Cambio de pastillas',
            subtitle: 'Bahía 1',
            plate: 'BKL482',
            loading: true,
          )
      else if (state.assignedTasks.isEmpty)
        _padded(AtelierEmptyState(text: strings.floorHubTasksEmpty))
      else
        for (final task in state.assignedTasks.take(5))
          AtelierListRow(
            title: task.description,
            subtitle: _taskSubtitle(strings, task),
            plate: task.plate,
            onClick: () => actions.onOpenTaskDetail(task.workOrderId, task.id.value),
            trailing: AtelierChip(
              text: _taskStatusLabel(strings, task),
              kind: _taskStatusChipKind(task),
            ),
          ),
    ];
  }

  String? _taskSubtitle(AppLocalizations strings, Task task) {
    final hours = task.estimatedHours;
    final text = [
      ?task.bayName,
      if (hours != null) strings.floorHubTaskEstimated(hours.formatQuantity()),
    ].join(' · ');
    return text.isEmpty ? null : text;
  }

  List<Widget> _counterBlock(AppLocalizations strings, bool loading) {
    return [
      _padded(
        AtelierGroupedCard(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  AtelierButton(
                    text: strings.floorHubCounterOpenReception,
                    onClick: actions.onOpenReception,
                    icon: Icons.directions_car_outlined,
                  ),
                  AtelierButton(
                    text: strings.floorHubCounterNewCustomer,
                    onClick: actions.onRegisterWalkIn,
                    style: AtelierButtonStyle.tonal,
                    icon: Icons.person_add_alt_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _padded(
        AtelierSectionHeader(
          title: strings.floorHubCounterSection,
          count: state.appointments.isEmpty ? null : state.appointments.length,
        ),
      ),
      if (loading)
        for (var i = 0; i < 3; i++)
          const AtelierListRow(
            title: '09:30 · Cliente',
            subtitle: 'Mantenimiento',
            plate: 'F4T119',
            loading: true,
          )
      else if (state.appointments.isEmpty)
        _padded(AtelierEmptyState(text: strings.floorHubCounterEmpty))
      else
        for (final appointment in state.appointments.take(6))
          AtelierListRow(
            title: [
              formatLimaTime(appointment.scheduledAt),
              ?appointment.customerName,
            ].join(' · '),
            subtitle: appointment.reason,
            plate: appointment.plate,
            onClick: actions.onOpenReception,
            trailing: _appointmentChip(strings, appointment),
          ),
    ];
  }

  Widget _appointmentChip(AppLocalizations strings, Appointment appointment) {
    final (label, kind) = switch (appointment.status) {
      AppointmentStatus.confirmed => (strings.floorHubApptConfirmed, ChipKind.info),
      AppointmentStatus.arrived => (strings.floorHubApptArrived, ChipKind.ok),
      AppointmentStatus.canceled => (strings.floorHubApptCanceled, ChipKind.bad),
      _ => (strings.floorHubApptPending, ChipKind.warn),
    };
    return AtelierChip(text: label, kind: kind);
  }

  List<Widget> _warehouseBlock(AppLocalizations strings, bool loading) {
    final orders = state.issuedPurchaseOrders;
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: AtelierSectionHeader(
          title: strings.floorHubStockPosSection,
          count: orders.isEmpty ? null : orders.length,
          action: AtelierButton(
            text: strings.floorHubStockOpenCatalog,
            onClick: actions.onOpenInventory,
            style: AtelierButtonStyle.text,
          ),
        ),
      ),
      if (orders.isEmpty && !loading)
        _padded(AtelierEmptyState(text: strings.floorHubStockPosEmpty))
      else
        for (final po in orders.take(4))
          AtelierListRow(
            title: po.orderNumber ?? strings.floorHubPoFallback(_take(po.id, 8)),
            subtitle: strings.floorHubPoSummary(po.lines.length, po.totalCost?.format() ?? ''),
            onClick: () => actions.onOpenPurchaseOrderDetail(po.id),
            leading: AtelierChip(
              text: strings.floorHubPoIssued,
              kind: ChipKind.info,
              icon: Icons.shopping_cart_outlined,
            ),
          ),
    ];
  }

  /// Caja: solo lo que no es cobrar. Las órdenes listas abren su detalle (el cobro es US37–US39).
  List<Widget> _cashierBlock(AppLocalizations strings, bool loading) {
    final ready = state.readyToBillOrders;
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: AtelierSectionHeader(
          title: strings.floorHubCashDecisions,
          count: ready.isEmpty ? null : ready.length,
          action: AtelierButton(
            text: strings.floorHubCashOpenDaily,
            onClick: actions.onOpenDailyCash,
            style: AtelierButtonStyle.text,
          ),
        ),
      ),
      if (loading)
        for (var i = 0; i < 2; i++)
          const AtelierListRow(
            title: 'Orden #1042',
            subtitle: 'Cliente',
            plate: 'BKL482',
            loading: true,
          )
      else if (ready.isEmpty)
        _padded(AtelierEmptyState(text: strings.floorHubCashEmpty))
      else
        for (final order in ready.take(6))
          _padded(
            AtelierDecisionRow(
              title:
                  order.customerName ??
                  strings.floorHubCashOrderNumber(
                    order.internalNumber?.toString() ?? _take(order.id.value, 6),
                  ),
              subtitle: order.bayName ?? strings.floorHubCashReadySubtitle,
              plate: order.plate,
              amount: order.totalAmount?.format(),
              onClick: () => actions.onOpenWorkOrder(order.id.value),
            ),
          ),
    ];
  }

  String _take(String value, int count) => value.length <= count ? value : value.substring(0, count);
}

/// Etiqueta de estado de una tarea; suspendida (pieza defectuosa o espera) se distingue de una pausa del mecánico.
String _taskStatusLabel(AppLocalizations strings, Task task) {
  return switch (task.status) {
    TaskStatus.inProgress => strings.taskStatusInProgress,
    TaskStatus.onHold =>
      task.holdReason != null && !task.holdReason!.isMechanicPause
          ? strings.taskStatusSuspended
          : strings.taskStatusOnHold,
    TaskStatus.assigned => strings.taskStatusAssigned,
    TaskStatus.completed => strings.taskStatusCompleted,
    TaskStatus.cancelled => strings.taskStatusCancelled,
    TaskStatus.pending || null => strings.taskStatusPending,
  };
}

ChipKind _taskStatusChipKind(Task task) {
  return switch (task.status) {
    TaskStatus.inProgress => ChipKind.info,
    TaskStatus.onHold =>
      task.holdReason != null && !task.holdReason!.isMechanicPause ? ChipKind.bad : ChipKind.wait,
    TaskStatus.completed => ChipKind.ok,
    _ => ChipKind.idle,
  };
}

(String, ChipKind, IconData) _shiftBadge(AppLocalizations strings, TodayAttendance today) {
  return switch (today) {
    ClockedIn() => (strings.floorHubShiftActive, ChipKind.ok, Icons.check_circle_outline),
    ClockInQueued() || ClockOutQueued() => (
      strings.floorHubShiftPending,
      ChipKind.idle,
      Icons.sync_outlined,
    ),
    Completed() => (strings.floorHubShiftClosed, ChipKind.info, Icons.schedule_outlined),
    NotClockedIn() => (strings.floorHubShiftIdle, ChipKind.warn, Icons.schedule_outlined),
  };
}

class _HubReportPanel extends StatelessWidget {
  final FloorHubUiState state;
  final bool loading;
  final FloorHubActions actions;

  const _HubReportPanel({required this.state, required this.loading, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dateText = state.todayDate.isEmpty ? '' : formatLimaDayShortOfDate(state.todayDate);
    final branch = state.branchName;
    final contextLine = [
      if (branch != null && branch.trim().isNotEmpty) branch,
      if (dateText.isNotEmpty) dateText,
    ].join(' · ');
    final contextText = contextLine.isEmpty ? strings.mainTabShift : contextLine;

    if (state.canTrackTasks) {
      final active = state.activeTask;
      final plate = active?.plate;
      final legend = active != null
          ? (plate != null && plate.trim().isNotEmpty ? plate : strings.floorHubTasksLegendActive)
          : state.pendingTasksCount.toString();
      final caption = active != null
          ? active.description
          : strings.floorHubTasksCaptionFormat(state.pendingTasksCount, state.completedTasksCount);
      return AtelierReportPanel(
        context: contextText,
        legend: legend,
        caption: caption,
        loading: loading,
        figures: [
          PanelFigure(
            value: state.pendingTasksCount.toString(),
            label: strings.floorHubFigurePending,
            onClick: actions.onOpenTasks,
          ),
          PanelFigure(
            value: state.inProgressTasksCount.toString(),
            label: strings.floorHubFigureInProgress,
            onClick: actions.onOpenTasks,
          ),
          if (state.canUseObd)
            PanelFigure(
              value: state.activeObdCount.toString(),
              label: strings.floorHubFigureObd,
              onClick: actions.onOpenObd,
            ),
        ],
      );
    }
    if (state.canManageStock) {
      return AtelierReportPanel(
        context: contextText,
        legend: state.issuedPurchaseOrders.length.toString(),
        caption: strings.floorHubStockPosCaption,
        loading: loading,
        figures: [
          PanelFigure(
            value: state.catalogSize.toString(),
            label: strings.floorHubFigureCatalog,
            onClick: actions.onOpenInventory,
          ),
        ],
      );
    }
    if (state.canOperateCash) {
      return AtelierReportPanel(
        context: contextText,
        legend: state.readyToBillOrders.length.toString(),
        caption: strings.floorHubCashCaption,
        loading: loading,
        figures: [
          PanelFigure(
            value: state.dailyCash?.totalCollected.format() ?? 'S/ 0.00',
            label: strings.floorHubFigureCollected,
            onClick: actions.onOpenDailyCash,
          ),
          PanelFigure(
            value: (state.dailyCash?.paymentCount ?? 0).toString(),
            label: strings.floorHubFigurePayments,
            onClick: actions.onOpenDailyCash,
          ),
        ],
      );
    }
    if (state.canUseCounter) {
      final arrived = state.appointments.where((a) => a.status == AppointmentStatus.arrived).length;
      final waiting = state.appointments
          .where(
            (a) => a.status == AppointmentStatus.pending || a.status == AppointmentStatus.confirmed,
          )
          .length;
      return AtelierReportPanel(
        context: contextText,
        legend: state.appointments.length.toString(),
        caption: strings.floorHubCounterCaption,
        loading: loading,
        figures: [
          PanelFigure(
            value: waiting.toString(),
            label: strings.floorHubFigureWaiting,
            onClick: actions.onOpenReception,
          ),
          PanelFigure(
            value: arrived.toString(),
            label: strings.floorHubFigureArrived,
            onClick: actions.onOpenReception,
          ),
          PanelFigure(
            value: state.branchOrders.length.toString(),
            label: strings.floorHubFigureOrders,
          ),
        ],
      );
    }
    final (statusLabel, _, _) = _shiftBadge(strings, state.todayAttendance);
    return AtelierReportPanel(
      context: contextText,
      legend: statusLabel,
      caption: state.schedule?.shift.name ?? strings.attendanceTitle,
      loading: loading,
    );
  }
}

class _ShiftExpressCard extends StatelessWidget {
  final FloorHubUiState state;
  final FloorHubActions actions;

  const _ShiftExpressCard({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final shift = state.schedule?.shift;
    final (badge, badgeKind, badgeIcon) = _shiftBadge(strings, state.todayAttendance);
    final showMainAction = state.canClockInNow || state.canClockOutNow;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.dashboardMyShiftTitle,
                        style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                      ),
                      if (shift != null)
                        Text(
                          '${shift.name} · ${hourMinute(shift.startTime)} – ${hourMinute(shift.endTime)}',
                          style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
                        ),
                    ],
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    if (state.todayAttendance is ClockedIn) AtelierLiveBeacon(color: colors.okMark),
                    AtelierChip(text: badge, kind: badgeKind, icon: badgeIcon),
                  ],
                ),
              ],
            ),
            AtelierAdaptiveRow(
              equalWidthInRow: true,
              children: [
                if (state.canClockInNow)
                  AtelierButton(
                    text: strings.floorHubClockInCta,
                    onClick: actions.onClockIn,
                    loading: state.isSubmittingAttendance,
                    icon: Icons.login_outlined,
                    minHeight: 52,
                  )
                else if (state.canClockOutNow)
                  AtelierButton(
                    text: strings.floorHubClockOutCta,
                    onClick: actions.onRequestClockOut,
                    style: AtelierButtonStyle.outlined,
                    loading: state.isSubmittingAttendance,
                    icon: Icons.logout_outlined,
                    minHeight: 52,
                  ),
                AtelierButton(
                  text: strings.floorHubAttendanceDetail,
                  onClick: actions.onOpenAttendanceDetail,
                  style: AtelierButtonStyle.tonal,
                  minHeight: showMainAction ? 52 : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveMechanicTaskCard extends StatefulWidget {
  final Task active;
  final VoidCallback onOpenTaskDetail;

  const _ActiveMechanicTaskCard({required this.active, required this.onOpenTaskDetail});

  @override
  State<_ActiveMechanicTaskCard> createState() => _ActiveMechanicTaskCardState();
}

class _ActiveMechanicTaskCardState extends State<_ActiveMechanicTaskCard> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  bool get _isRunning => widget.active.status == TaskStatus.inProgress;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(_ActiveMechanicTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  /// El avance se recalcula cada 30 s mientras la tarea corre.
  void _syncTimer() {
    if (_isRunning && _timer == null) {
      _now = DateTime.now();
      _timer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    } else if (!_isRunning) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final active = widget.active;
    final startedAt = active.startedAt;
    final estimated = active.estimatedHours;
    final plate = active.plate;
    final bay = active.bayName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: heroShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                if (plate != null) AtelierPlate(plate: plate, size: PlateSize.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active.description,
                        style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                      ),
                      if (bay != null)
                        Text(
                          bay,
                          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                        ),
                    ],
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    if (_isRunning) AtelierLiveBeacon(color: colors.info),
                    AtelierChip(
                      text: _taskStatusLabel(strings, active),
                      kind: _taskStatusChipKind(active),
                    ),
                  ],
                ),
              ],
            ),
            if (startedAt != null && estimated != null && estimated > Decimal.zero)
              _progress(context, strings, startedAt, estimated),
            AtelierButton(
              text: strings.floorHubOpenTask,
              onClick: widget.onOpenTaskDetail,
              icon: Icons.play_arrow_outlined,
              minHeight: 52,
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress(
    BuildContext context,
    AppLocalizations strings,
    DateTime startedAt,
    Decimal estimated,
  ) {
    final colors = context.atelier;
    final elapsedSeconds = LaborTime.effectiveSeconds(
      startedAt,
      widget.active.totalPausedSeconds,
      _now,
    );
    final estimatedSeconds = (estimated.toDouble() * 3600).clamp(1.0, double.infinity);
    final rawProgress = elapsedSeconds / estimatedSeconds;
    final barColor = rawProgress >= 1
        ? colors.badMark
        : rawProgress >= 0.85
        ? colors.warnMark
        : context.scheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.pitTaskProgressLabel,
              style: context.text.labelMedium?.copyWith(color: colors.inkSecondary),
            ),
            Text(
              strings.pitTaskElapsedVsEst(
                elapsedSeconds ~/ 3600,
                (elapsedSeconds % 3600) ~/ 60,
                estimated.formatQuantity(),
              ),
              style: context.text.labelLarge?.copyWith(color: context.scheme.onSurface),
            ),
          ],
        ),
        AtelierMetricBar(progress: rawProgress.clamp(0.0, 1.0), color: barColor, markerAt: 1),
      ],
    );
  }
}

class _FloorShortcutsCard extends StatelessWidget {
  final FloorHubUiState state;
  final FloorHubActions actions;

  const _FloorShortcutsCard({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final activeWorkOrderId =
        state.activeTask?.workOrderId ??
        (state.assignedTasks.isEmpty ? null : state.assignedTasks.first.workOrderId);
    final rows = <({String title, String subtitle, IconData? icon, VoidCallback onClick})>[
      if (state.canUseObd)
        (
          title: strings.floorHubQuickObd,
          subtitle: strings.floorHubQuickObdSub,
          icon: null,
          onClick: actions.onOpenObd,
        ),
      if (state.canReportFinding && activeWorkOrderId != null)
        (
          title: strings.floorHubQuickFinding,
          subtitle: strings.floorHubQuickFindingSub,
          icon: Icons.report_problem_outlined,
          onClick: () => actions.onOpenReportFinding(activeWorkOrderId),
        ),
      if (state.canReadBays)
        (
          title: strings.floorHubQuickBays,
          subtitle: strings.moreHBaysSub,
          icon: Icons.garage_outlined,
          onClick: actions.onOpenBays,
        ),
      if (state.canReadParts)
        (
          title: strings.floorHubQuickParts,
          subtitle: strings.floorHubQuickPartsSub,
          icon: Icons.inventory_2_outlined,
          onClick: actions.onOpenInventory,
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierGroupedCard(
        title: strings.floorHubQuickSection,
        children: [
          for (var i = 0; i < rows.length; i++)
            rows[i].icon == null
                ? _ObdShortcutRow(
                    title: rows[i].title,
                    subtitle: rows[i].subtitle,
                    showDivider: i < rows.length - 1,
                    onClick: rows[i].onClick,
                  )
                : AtelierGroupedRow(
                    title: rows[i].title,
                    subtitle: rows[i].subtitle,
                    icon: rows[i].icon,
                    showDivider: i < rows.length - 1,
                    onClick: rows[i].onClick,
                  ),
        ],
      ),
    );
  }
}

/// El acceso a OBD-II lleva el ícono propio `bluetooth_searching`, que no es de Material.
class _ObdShortcutRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback onClick;

  const _ObdShortcutRow({
    required this.title,
    required this.subtitle,
    required this.showDivider,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onClick,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              spacing: 14,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: colors.surfaceRecessed,
                    shape: RoundedRectangleBorder(
                      borderRadius: controlRadius,
                      side: BorderSide(color: colors.outlineSoft.withValues(alpha: 0.65)),
                    ),
                  ),
                  child: AtelierIcon(
                    AtelierIcons.bluetoothSearching,
                    size: 20,
                    color: context.scheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: context.text.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.scheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_right_outlined, size: 20, color: colors.muted),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 16,
            color: colors.outlineSoft.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}
