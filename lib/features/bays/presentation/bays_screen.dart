import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bay_action_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bay_labels.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US40: tablero de ocupación de bahías de la sede.
class BaysScreen extends StatefulWidget {
  const BaysScreen({super.key});

  @override
  State<BaysScreen> createState() => _BaysScreenState();
}

class _BaysScreenState extends State<BaysScreen> with WidgetsBindingObserver {
  late final BaysViewModel viewModel = getIt<BaysViewModel>();
  bool _onScreen = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// `TickerMode` se apaga cuando otra pantalla tapa a esta; una hoja encima no la apaga.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onScreen = TickerMode.valuesOf(context).enabled;
    _updateVisibility();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed || state == AppLifecycleState.inactive;
    _updateVisibility();
  }

  /// Fuera del cuadro actual: puede llegar durante la construcción y el ViewModel notifica.
  void _updateVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) viewModel.setVisible(_onScreen && _foreground);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    viewModel.dispose();
    super.dispose();
  }

  /// Cierra la hoja y después abre la orden, para no apilar la pantalla sobre la hoja.
  void _openOrder(String workOrderId) {
    viewModel.onDismissSheet();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppNavigator.push(context, AppRoute.workOrderDetail, workOrderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final sheetActions = BaySheetActions(
      onOpenOrder: _openOrder,
      onMoveOrder: vm.onMoveOrder,
      onAssignOrder: vm.onAssignOrder,
      onRelease: vm.onRelease,
      onOpenReassignTaskMechanic: vm.onOpenReassignTaskMechanic,
      onConfirmReassignTaskMechanic: vm.onConfirmReassignTaskMechanic,
      onMaintenanceClick: vm.onMaintenanceClick,
      onMaintenanceBack: vm.onMaintenanceBack,
      onMaintenanceReasonChange: vm.onMaintenanceReasonChange,
      onConfirmMaintenance: vm.onConfirmMaintenance,
      onRestore: vm.onRestore,
      onDismiss: vm.onDismissSheet,
    );
    return StateSheetHost<BaySheet>(
      listenable: vm,
      value: () => vm.state.sheet,
      onDismiss: vm.onDismissSheet,
      sheetBuilder: (context, _) {
        final item = vm.state.selectedItem;
        return item == null
            ? const SizedBox.shrink()
            : BayDetailSheet(state: vm.state, item: item, actions: sheetActions);
      },
      child: StateSheetHost<CreateBayForm>(
        listenable: vm,
        value: () => vm.state.createForm,
        onDismiss: vm.onDismissCreate,
        sheetBuilder: (context, form) => CreateBaySheet(
          state: vm.state,
          form: form,
          onNameChange: vm.onCreateNameChange,
          onTypeChange: vm.onCreateTypeChange,
          onConfirm: vm.onConfirmCreate,
          onDismiss: vm.onDismissCreate,
        ),
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => BaysContent(
            state: vm.state,
            onBack: () => Navigator.of(context).maybePop(),
            onRefresh: vm.refresh,
            onFilterChange: vm.onFilterChange,
            onBayClick: vm.onBayClick,
            onCreateClick: vm.onCreateClick,
            onOpenOrder: _openOrder,
          ),
        ),
      ),
    );
  }
}

class BaysContent extends StatefulWidget {
  final BaysUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<BayFilter> onFilterChange;
  final ValueChanged<WorkBay> onBayClick;
  final VoidCallback onCreateClick;
  final ValueChanged<String>? onOpenOrder;

  const BaysContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onFilterChange,
    required this.onBayClick,
    required this.onCreateClick,
    this.onOpenOrder,
  });

  @override
  State<BaysContent> createState() => _BaysContentState();
}

class _BaysContentState extends State<BaysContent> {
  DateTime _now = DateTime.now();
  Timer? _ticker;

  BaysUiState get state => widget.state;

  /// El tiempo de mano de obra avanza cada 30 s mientras haya bahías ocupadas.
  void _syncTicker() {
    if (state.occupiedCount > 0) {
      _ticker ??= Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(BaysContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canManage && state.isOnline
          ? AtelierFab(text: strings.baysNewBtn, icon: Icons.add, onClick: widget.onCreateClick).floatingBarPadding()
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(title: strings.baysTitle, onBack: widget.onBack),
          if (!state.canRead)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.baysNoPermission),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AtelierSegmentedControl<BayFilter>(
                options: BayFilter.values,
                selected: state.filter,
                onSelect: widget.onFilterChange,
                label: (filter) => switch (filter) {
                  BayFilter.all => strings.baysFilterAllShort,
                  BayFilter.available => strings.baysFilterAvailableShort,
                  BayFilter.occupied => strings.baysFilterOccupiedShort,
                  BayFilter.maintenance => strings.baysFilterMaintenanceShort,
                },
                badge: state.countFor,
              ),
            ),
            AtelierRefreshBar(visible: state.isRefreshing && state.items.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: DelayedLoading(
                  loading: state.isLoading && state.items.isEmpty,
                  builder: (context, showSkeleton) => _list(context, strings, showSkeleton),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    const side = EdgeInsets.symmetric(horizontal: 16);
    final notice = state.notice;
    final error = state.error;
    final visible = state.visibleItems;
    final loading = state.isLoading && state.items.isEmpty;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (!state.isOnline)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AtelierBanner(message: strings.baysOffline, icon: Icons.info_outline, kind: BannerKind.info),
          ),
        if (notice != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AtelierBanner(
              message: notice.asString(strings),
              icon: Icons.check_circle_outline,
              kind: BannerKind.ok,
            ),
          ),
        if (error != null && state.items.isNotEmpty && !state.hasOpenSheet)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
          ),
        if (!showSkeleton && !loading && state.items.isNotEmpty) _OccupancySummary(state: state),
        if (showSkeleton)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(title: 'Bahía', subtitle: 'Elevador', plate: 'ABC123', loading: true)
        else if (loading)
          const SizedBox.shrink()
        else if (state.items.isEmpty && error != null && !state.isOnline)
          Padding(
            padding: side,
            child: AtelierOfflineState(onRetry: () => widget.onRefresh()),
          )
        else if (state.items.isEmpty && error != null)
          Padding(
            padding: side,
            child: AtelierErrorState(message: error.asString(strings), onRetry: () => widget.onRefresh()),
          )
        else if (visible.isEmpty)
          Padding(
            padding: side,
            child: AtelierEmptyState(text: strings.baysEmpty),
          )
        else
          for (final item in visible) _row(context, strings, item),
      ],
    );
  }

  Widget _row(BuildContext context, AppLocalizations strings, BayBoardItem item) {
    final bay = item.bay;
    final occupant = item.occupant;
    final canAssignThisBay =
        state.canAssignBay && state.isOnline && bay.canReceive && state.assignableOrders.isNotEmpty;
    final canActOnBay = switch (bay.status) {
      BayStatus.occupied => occupant != null && (state.canReadWorkOrders || state.canReleaseBay || state.canAssignBay),
      BayStatus.available => canAssignThisBay || (state.canManage && state.isOnline),
      BayStatus.maintenance => state.canManage && state.isOnline,
      null => false,
    };
    final live = occupant == null ? null : bayLiveElapsed(occupant, _now);
    final elapsed = live ?? occupant?.laborElapsed;
    final mechanics = occupant == null ? const <String>[] : state.mechanicLabelsFor(occupant);
    final type = bayTypeLabel(strings, bay.type);
    final line = occupant != null
        ? [
            ?type,
            if (occupant.internalNumber != null) strings.todayOrderNumber(occupant.internalNumber!),
            if (elapsed != null) strings.baysLabor(formatBayElapsed(elapsed)),
            if (mechanics.isNotEmpty) mechanics.join(', '),
          ].join(' · ')
        : canAssignThisBay
        ? [?type, strings.baysTapToAssign].join(' · ')
        : type ?? '';
    final status = bayStatusLabel(strings, bay.status);
    return AtelierListRow(
      key: ValueKey('bay-${bay.id}'),
      title: bay.name,
      subtitle: line.isEmpty ? null : line,
      plate: occupant?.plate,
      onClick: canActOnBay
          ? () => widget.onBayClick(bay)
          : occupant != null && state.canReadWorkOrders && widget.onOpenOrder != null
          ? () => widget.onOpenOrder!(occupant.workOrderId)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          if (bay.status == BayStatus.occupied) AtelierLiveBeacon(color: context.atelier.info, size: 8),
          if (status != null)
            AtelierChip(
              text: status,
              kind: bayStatusChipKind(bay.status),
              icon: bay.status == BayStatus.maintenance ? Icons.build_outlined : null,
            ),
        ],
      ),
    );
  }
}

/// Ocupación de la sede: fracción, barra métrica y desglose de libres y en mantenimiento.
class _OccupancySummary extends StatelessWidget {
  final BaysUiState state;

  const _OccupancySummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final total = state.items.length;
    final progress = total > 0 ? state.occupiedCount / total : 0.0;
    final barColor = progress >= 0.85
        ? colors.warnMark
        : state.occupiedCount > 0
        ? colors.info
        : colors.okMark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      if (state.occupiedCount > 0) AtelierLiveBeacon(color: colors.info, size: 8),
                      Flexible(
                        child: Text(
                          strings.baysOccupancyTitle,
                          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  strings.baysOccupancyFraction(state.occupiedCount, total),
                  style: context.text.titleLarge?.copyWith(color: context.scheme.onSurface),
                ),
              ],
            ),
            AtelierMetricBar(progress: progress, color: barColor, height: 8),
            Text(
              strings.baysOccupancyBreakdown(state.availableCount, state.maintenanceCount),
              style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
