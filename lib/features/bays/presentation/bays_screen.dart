import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
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
      onMaintenanceClick: vm.onMaintenanceClick,
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
          ),
        ),
      ),
    );
  }
}

class BaysContent extends StatelessWidget {
  final BaysUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<BayFilter> onFilterChange;
  final ValueChanged<WorkBay> onBayClick;
  final VoidCallback onCreateClick;

  const BaysContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onFilterChange,
    required this.onBayClick,
    required this.onCreateClick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(
            title: strings.baysTitle,
            onBack: onBack,
            actions: [
              IconButton(
                onPressed: () => onRefresh(),
                tooltip: strings.baysRefresh,
                icon: const Icon(Icons.refresh_outlined),
              ),
              if (state.canManage)
                IconButton(
                  onPressed: state.isBusy ? null : onCreateClick,
                  tooltip: strings.baysNewBtn,
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: _items(context, strings),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _items(BuildContext context, AppLocalizations strings) {
    if (!state.canRead) return [AtelierNoPermissionState(text: strings.baysNoPermission)];
    final notice = state.notice;
    final error = state.error;
    final visible = state.visibleItems;
    return [
      if (!state.isOnline)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AtelierBanner(message: strings.baysOffline, icon: Icons.cloud_off_outlined, kind: BannerKind.wait),
        ),
      if (notice != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AtelierBanner(message: notice.asString(strings), icon: Icons.check_circle_outline, kind: BannerKind.ok),
        ),
      if (error != null && !state.hasOpenSheet && state.isOnline)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
        ),
      AtelierSegmentedControl<BayFilter>(
        options: BayFilter.values,
        selected: state.filter,
        onSelect: onFilterChange,
        label: (filter) => switch (filter) {
          BayFilter.all => strings.baysFilterAllShort,
          BayFilter.available => strings.baysFilterAvailableShort,
          BayFilter.occupied => strings.baysFilterOccupiedShort,
          BayFilter.maintenance => strings.baysFilterMaintenanceShort,
        },
        badge: state.countFor,
      ),
      const SizedBox(height: 12),
      if (state.isLoading && state.items.isEmpty)
        for (var i = 0; i < 3; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Bone(loading: true, child: SizedBox(height: 72, width: double.infinity)),
          )
      else if (visible.isEmpty)
        AtelierEmptyState(text: strings.baysEmpty, actionLabel: strings.baysRefresh, onAction: () => onRefresh())
      else
        for (final item in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _BayCard(
              item: item,
              mechanicNames: state.mechanicNamesById,
              onClick: () => onBayClick(item.bay),
            ),
          ),
      if (state.canManage)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AtelierButton(
            text: strings.baysNewBtn,
            onClick: onCreateClick,
            style: AtelierButtonStyle.outlined,
            icon: Icons.add,
            enabled: !state.isBusy,
          ),
        ),
    ];
  }
}

class _BayCard extends StatelessWidget {
  final BayBoardItem item;
  final Map<String, String> mechanicNames;
  final VoidCallback onClick;

  const _BayCard({required this.item, required this.mechanicNames, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final bay = item.bay;
    final occupant = item.occupant;
    final type = bayTypeLabel(strings, bay.type);
    final status = bayStatusLabel(strings, bay.status);
    final plate = occupant?.plate;
    final number = occupant?.internalNumber;
    final elapsed = occupant?.laborElapsed;
    final names = [for (final id in occupant?.mechanicIds ?? const <String>[]) ?mechanicNames[id]];
    final secondary = context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary);
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      onClick: onClick,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bay.name, style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface)),
                    if (type != null) Text(type, style: secondary),
                  ],
                ),
              ),
              if (status != null) AtelierChip(text: status, kind: bayStatusChipKind(bay.status)),
            ],
          ),
          if (occupant != null)
            Row(
              spacing: 12,
              children: [
                if (plate != null) AtelierPlate(plate: plate),
                if (number != null) Text(strings.ordersOrderNumber(number), style: secondary),
              ],
            ),
          if (names.isNotEmpty) Text(names.join(', '), style: secondary),
          if (elapsed != null) Text(strings.baysLabor(formatLaborElapsed(elapsed)), style: secondary),
          if (bay.canReceive) Text(strings.baysTapToAssign, style: secondary),
        ],
      ),
    );
  }
}
