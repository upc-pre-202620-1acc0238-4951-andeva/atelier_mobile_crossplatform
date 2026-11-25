import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_kpi_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/justification_review.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Cuántas órdenes muestra "Hoy" antes de mandar a la pestaña Órdenes.
const _ordersPreview = 6;

/// "Hoy": el parte de la sede para quien la supervisa. Una cifra a escala de señal (autos en el taller), lo que
/// espera una decisión en ámbar y las órdenes abiertas. Lo que se decide aquí se decide en hoja inferior.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late final AdminDashboardViewModel viewModel = getIt<AdminDashboardViewModel>();
  int _resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_confirmDecision);
  }

  /// La decisión se confirma en la mano además de en la fila.
  void _confirmDecision() {
    final count = viewModel.state.resolved.length;
    if (count > _resolvedCount) rememberAtelierHaptics().confirm();
    _resolvedCount = count;
  }

  @override
  void dispose() {
    viewModel.removeListener(_confirmDecision);
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  /// Cambia de pestaña si la sesión la tiene (como `navigateToTab` de Android); si no, la abre encima.
  void _openTab(AppRoute route, MainTab tab) {
    final controller = MainShellController.maybeOf(context) ?? MainShellController.current;
    if (controller == null) {
      _open(route);
    } else {
      controller.openRoute(route, tab: tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JustificationReviewHost(
      listenable: viewModel,
      reviewing: () => viewModel.state.reviewing,
      onDismiss: viewModel.onDismissJustification,
      sheetBuilder: (context, item) {
        final state = viewModel.state;
        return JustificationSheet(
          item: item,
          who: null,
          canApprove: state.canApproveJustifications,
          isOnline: state.isOnline,
          isSubmitting: state.isSubmittingReview,
          error: state.reviewError,
          onReview: viewModel.onReviewJustification,
        );
      },
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => AdminDashboardContent(
          state: viewModel.state,
          actions: DashboardActions(
            onRefresh: viewModel.refresh,
            onSelectBranch: () => _open(AppRoute.branchSelection),
            onOpenNotifications: () => _open(AppRoute.notifications),
            onOpenSyncQueue: () => _open(AppRoute.pendingOperations),
            onOpenProfile: () => _open(AppRoute.profile),
            onReceiveVehicle: () => _open(AppRoute.vehicleSearch),
            onRegisterWalkIn: () => _open(AppRoute.registerCustomer, const RegisterCustomerArgs()),
            onOpenOrder: (id) => _open(AppRoute.workOrderDetail, id),
            onOpenOrders: () => _openTab(AppRoute.workOrders, MainTab.orders),
            onOpenTeam: () => _openTab(AppRoute.adminAttendance, MainTab.team),
            onOpenObd: () => _open(AppRoute.diagnosticsHub),
            onOpenMyAttendance: () => _open(AppRoute.attendanceDetail),
            onOpenMyTasks: () => _open(AppRoute.myTasks),
            onOpenJustification: viewModel.onOpenJustification,
          ),
        ),
      ),
    );
  }
}

class DashboardActions {
  final Future<void> Function() onRefresh;
  final VoidCallback onSelectBranch;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSyncQueue;
  final VoidCallback onOpenProfile;
  final VoidCallback onReceiveVehicle;
  final VoidCallback onRegisterWalkIn;
  final ValueChanged<String> onOpenOrder;
  final VoidCallback onOpenOrders;
  final VoidCallback onOpenTeam;
  final VoidCallback onOpenObd;
  final VoidCallback onOpenMyAttendance;
  final VoidCallback onOpenMyTasks;
  final ValueChanged<TeamAttendance> onOpenJustification;

  DashboardActions({
    Future<void> Function()? onRefresh,
    VoidCallback? onSelectBranch,
    VoidCallback? onOpenNotifications,
    VoidCallback? onOpenSyncQueue,
    VoidCallback? onOpenProfile,
    VoidCallback? onReceiveVehicle,
    VoidCallback? onRegisterWalkIn,
    ValueChanged<String>? onOpenOrder,
    VoidCallback? onOpenOrders,
    VoidCallback? onOpenTeam,
    VoidCallback? onOpenObd,
    VoidCallback? onOpenMyAttendance,
    VoidCallback? onOpenMyTasks,
    ValueChanged<TeamAttendance>? onOpenJustification,
  }) : onRefresh = onRefresh ?? (() async {}),
       onSelectBranch = onSelectBranch ?? (() {}),
       onOpenNotifications = onOpenNotifications ?? (() {}),
       onOpenSyncQueue = onOpenSyncQueue ?? (() {}),
       onOpenProfile = onOpenProfile ?? (() {}),
       onReceiveVehicle = onReceiveVehicle ?? (() {}),
       onRegisterWalkIn = onRegisterWalkIn ?? (() {}),
       onOpenOrder = onOpenOrder ?? ((_) {}),
       onOpenOrders = onOpenOrders ?? (() {}),
       onOpenTeam = onOpenTeam ?? (() {}),
       onOpenObd = onOpenObd ?? (() {}),
       onOpenMyAttendance = onOpenMyAttendance ?? (() {}),
       onOpenMyTasks = onOpenMyTasks ?? (() {}),
       onOpenJustification = onOpenJustification ?? ((_) {});
}

class AdminDashboardContent extends StatelessWidget {
  final AdminDashboardUiState state;
  final DashboardActions actions;

  const AdminDashboardContent({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AtelierMainTopBar(
            title: state.tenantName.trim().isEmpty ? strings.dashboardTitle : state.tenantName,
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
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final error = state.error;
    final items = <Widget>[
      _ReportPanel(state: state, actions: actions, loading: showSkeleton),
      if (!state.isOnline)
        _padded(
          AtelierBanner(
            message: strings.todayOfflineCache,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          ),
        ),
      if (error != null && state.orders.isNotEmpty)
        _padded(AtelierBanner(message: error.asString(strings), icon: Icons.error_outline)),
      _BranchCard(state: state, onSelectBranch: actions.onSelectBranch),
      if (state.canClockPersonalAttendance || state.canWorkOwnTasks)
        _PersonalShiftCard(state: state, actions: actions),
      if (state.canCreateWorkOrder) _ReceptionCard(state: state, actions: actions),
      _KpiGrid(state: state, actions: actions, loading: showSkeleton),
      ..._decisions(strings),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: AtelierSectionHeader(
          title: strings.todayOpenOrders,
          action: state.orders.length > _ordersPreview
              ? AtelierButton(
                  text: strings.todaySeeAll,
                  onClick: actions.onOpenOrders,
                  style: AtelierButtonStyle.text,
                )
              : null,
        ),
      ),
      ..._orders(strings, showSkeleton, error),
      SizedBox(height: FloatingBarInset.of(context)),
    ];
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) => items[index],
    );
  }

  List<Widget> _orders(AppLocalizations strings, bool showSkeleton, Object? error) {
    if (!state.canReadWorkOrders) {
      return [_padded(AtelierNoPermissionState(text: strings.todayOrdersNoPermission))];
    }
    if (showSkeleton) {
      return [
        for (var i = 0; i < 3; i++)
          const AtelierListRow(title: 'Orden', subtitle: 'Cliente', plate: 'ABC123', loading: true),
      ];
    }
    if (state.showSkeleton) return const [];
    if (state.orders.isEmpty && error != null && !state.isOnline) {
      return [_padded(AtelierOfflineState(onRetry: actions.onRefresh))];
    }
    if (state.orders.isEmpty && error != null) {
      return [
        _padded(
          AtelierErrorState(
            message: state.error!.asString(strings),
            onRetry: actions.onRefresh,
          ),
        ),
      ];
    }
    if (state.orders.isEmpty) {
      return [_padded(AtelierEmptyState(text: strings.todayOrdersEmpty))];
    }
    return [
      for (final order in state.orders.take(_ordersPreview))
        _OrderRow(order: order, onClick: () => actions.onOpenOrder(order.id.value)),
    ];
  }

  /// "Esperan tu decisión": suspensiones (US29), órdenes sin iniciar y descargos por revisar. Sin nada pendiente, la sección no existe.
  List<Widget> _decisions(AppLocalizations strings) {
    final drafts = state.draftOrders;
    final suspensions = state.suspensionDecisions;
    if (drafts.isEmpty &&
        suspensions.isEmpty &&
        state.justifications.isEmpty &&
        state.failedJustificationDays == 0) {
      return const [];
    }
    const rowPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(title: strings.todayDecisions, count: state.decisionsCount),
      ),
      for (final item in suspensions)
        Padding(
          padding: rowPadding,
          child: AtelierDecisionRow(
            title: strings.todayDecisionSuspension,
            subtitle: item.order.customerName ?? orderNumberLabel(strings, item.order),
            plate: item.order.plate,
            onClick: () => actions.onOpenOrder(item.order.id.value),
          ),
        ),
      for (final order in drafts)
        Padding(
          padding: rowPadding,
          child: AtelierDecisionRow(
            title: strings.todayDecisionDraft,
            subtitle: order.customerName ?? orderNumberLabel(strings, order),
            plate: order.plate,
            amount: _positiveAmount(order),
            onClick: () => actions.onOpenOrder(order.id.value),
          ),
        ),
      for (final item in state.justifications)
        Padding(
          padding: rowPadding,
          child: AtelierDecisionRow(
            title: justificationTitle(strings, item.status),
            subtitle: whoAndWhen(strings, item),
            resolved: switch (state.resolved[item.id]) {
              true => strings.todayJustificationApproved,
              false => strings.todayJustificationRejected,
              null => null,
            },
            onClick: () => actions.onOpenJustification(item),
          ),
        ),
      if (state.failedJustificationDays > 0)
        Padding(
          padding: rowPadding,
          child: AtelierBanner(
            message: strings.todayJustificationsPartial(state.failedJustificationDays),
            icon: Icons.info_outline,
            kind: BannerKind.wait,
          ),
        ),
    ];
  }

  String? _positiveAmount(WorkOrder order) {
    final total = order.totalAmount;
    return total != null && total.amount > Decimal.zero ? total.format() : null;
  }

  Widget _padded(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

/// Resumen vivo de la sede en formato Parte Hero Navy.
class _ReportPanel extends StatelessWidget {
  final AdminDashboardUiState state;
  final DashboardActions actions;
  final bool loading;

  const _ReportPanel({required this.state, required this.actions, required this.loading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dateText = state.today.isEmpty ? '' : formatLimaDayShortOfDate(state.today);
    final branch = state.branchName;
    final contextText = [
      if (branch != null && branch.trim().isNotEmpty) branch,
      if (dateText.isNotEmpty) dateText,
    ].join(' · ');
    final legend = !state.canReadWorkOrders
        ? '–'
        : (!state.showSkeleton && state.carsInWorkshop == 0)
        ? strings.todayCarsEmpty
        : strings.todayCars(state.carsInWorkshop);
    final caption = state.canReadWorkOrders
        ? strings.todayCaption
        : state.branchName ?? strings.dashboardTitle;
    return AtelierReportPanel(
      context: contextText.isEmpty ? strings.dashboardTitle : contextText,
      legend: legend,
      caption: caption,
      loading: loading,
      figures: [
        if (state.canReadWorkOrders)
          PanelFigure(
            value: state.readyOrdersCount.toString(),
            label: strings.todayFigureReadyShort,
            onClick: actions.onOpenOrders,
          ),
        if (state.canAuditAttendance)
          PanelFigure(
            value: state.onShiftCount.toString(),
            label: strings.todayFigureOnShift,
            onClick: actions.onOpenTeam,
          ),
      ],
    );
  }
}

/// Sede activa de la jornada; con más de una sede, toca para cambiarla.
class _BranchCard extends StatelessWidget {
  final AdminDashboardUiState state;
  final VoidCallback onSelectBranch;

  const _BranchCard({required this.state, required this.onSelectBranch});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        onClick: state.canChangeBranch ? onSelectBranch : null,
        contentPadding: const EdgeInsets.all(16),
        child: Row(
          spacing: 14,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: colors.surfaceRecessed, shape: BoxShape.circle),
              child: Icon(Icons.storefront_outlined, size: 20, color: colors.primaryText),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    state.branchName ?? strings.dashboardSelectBranchPrompt,
                    style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    strings.dashboardBranchLabel,
                    style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (state.canChangeBranch)
              Icon(Icons.keyboard_arrow_right_outlined, color: colors.inkSecondary),
          ],
        ),
      ),
    );
  }
}

/// Accesos personales en "Hoy" para roles operativos que también marcan turno o ejecutan tareas (Jefe / Asesor).
class _PersonalShiftCard extends StatelessWidget {
  final AdminDashboardUiState state;
  final DashboardActions actions;

  const _PersonalShiftCard({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final (subtitle, badge) = switch (state.personalTodayAttendance) {
      ClockedIn() => (strings.dashboardMyShiftClockedIn, strings.floorHubShiftActive),
      ClockInQueued() || ClockOutQueued() => (
        strings.dashboardMyShiftQueued,
        strings.floorHubShiftPending,
      ),
      Completed() => (strings.dashboardMyShiftCompleted, strings.floorHubShiftClosed),
      NotClockedIn() => (strings.dashboardMyShiftNotClockedIn, strings.floorHubShiftIdle),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierGroupedCard(
        children: [
          if (state.canClockPersonalAttendance)
            AtelierGroupedRow(
              title: strings.dashboardMyShiftTitle,
              subtitle: subtitle,
              icon: Icons.schedule_outlined,
              trailingBadgeText: badge,
              showDivider: state.canWorkOwnTasks,
              onClick: actions.onOpenMyAttendance,
            ),
          if (state.canWorkOwnTasks)
            AtelierGroupedRow(
              title: strings.dashboardMyTasksTitle,
              subtitle: strings.dashboardMyTasksSub(state.activePersonalTasksCount),
              icon: Icons.assignment_turned_in_outlined,
              trailingBadgeText: state.activePersonalTasksCount > 0
                  ? state.activePersonalTasksCount.toString()
                  : null,
              onClick: actions.onOpenMyTasks,
            ),
        ],
      ),
    );
  }
}

class _ReceptionCard extends StatelessWidget {
  final AdminDashboardUiState state;
  final DashboardActions actions;

  const _ReceptionCard({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colors.infoContainer, shape: BoxShape.circle),
                  child: Icon(Icons.directions_car_outlined, size: 20, color: colors.primaryText),
                ),
                Expanded(
                  child: Text(
                    strings.dashboardReceptionCtaTitle,
                    style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                  ),
                ),
              ],
            ),
            Text(
              strings.dashboardReceptionCtaBody,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                AtelierButton(
                  text: strings.dashboardSearchPlateBtn,
                  onClick: actions.onReceiveVehicle,
                  icon: Icons.directions_car_outlined,
                ),
                if (state.canRegisterCustomers)
                  AtelierButton(
                    text: strings.dashboardWalkInBtn,
                    onClick: actions.onRegisterWalkIn,
                    style: AtelierButtonStyle.tonal,
                    icon: Icons.person_add_alt_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuatro indicadores de la sede, dos por fila. Cada uno aparece solo con el permiso de su fuente.
class _KpiGrid extends StatelessWidget {
  final AdminDashboardUiState state;
  final DashboardActions actions;
  final bool loading;

  const _KpiGrid({required this.state, required this.actions, required this.loading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cards = <Widget>[
      if (state.canReadWorkOrders)
        AtelierKpiCard(
          title: strings.dashboardKpiOrders,
          value: state.orders.length.toString(),
          subtitle: strings.dashboardKpiOrdersSub(state.draftOrdersCount, state.inProgressCount),
          loading: loading,
          chip: state.draftOrdersCount > 0
              ? AtelierChip(
                  text: strings.dashboardKpiDraftsChip(state.draftOrdersCount),
                  kind: ChipKind.warn,
                )
              : null,
          onClick: actions.onOpenOrders,
        ),
      if (state.canReadCustomers)
        AtelierKpiCard(
          title: strings.dashboardKpiCrm,
          value: '${state.customersCount} · ${state.vehiclesCount}',
          subtitle: strings.dashboardKpiCrmSub(state.appointments.length),
          loading: loading,
          onClick: actions.onReceiveVehicle,
        ),
      if (state.canAuditAttendance)
        AtelierKpiCard(
          title: strings.dashboardKpiAttendance,
          value: state.branchAttendances.length.toString(),
          subtitle: strings.dashboardKpiAttendanceSub(state.pendingJustificationsCount),
          loading: loading,
          onClick: actions.onOpenTeam,
        ),
      if (state.canReadObd)
        AtelierKpiCard(
          title: strings.dashboardKpiObd,
          value: '${state.activeObdCount}/${state.obdDevices.length}',
          subtitle: strings.dashboardKpiObdSub,
          loading: loading,
          onClick: actions.onOpenObd,
        ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 8,
        children: [
          for (var i = 0; i < cards.length; i += 2)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Expanded(child: cards[i]),
                  if (i + 1 < cards.length) Expanded(child: cards[i + 1]) else const Spacer(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onClick;

  const _OrderRow({required this.order, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final number = orderNumberLabel(strings, order);
    final customer = order.customerName;
    final subtitle = [if (customer != null) number, ?order.bayName].join(' · ');
    return AtelierListRow(
      title: customer ?? number,
      subtitle: subtitle.isEmpty ? null : subtitle,
      plate: order.plate,
      onClick: onClick,
      trailing: AtelierChip(
        text: workOrderStatusLabel(strings, order.status),
        kind: workOrderStatusChipKind(order.status),
      ),
    );
  }
}
