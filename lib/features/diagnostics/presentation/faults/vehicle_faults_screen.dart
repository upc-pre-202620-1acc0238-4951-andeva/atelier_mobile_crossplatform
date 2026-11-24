import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc_catalog.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Códigos de falla electrónicos (DTC) activos de un vehículo: escaneo modo 03 y borrado modo 04.
class VehicleFaultsScreen extends StatefulWidget {
  final VehicleArgs args;

  const VehicleFaultsScreen({super.key, required this.args});

  @override
  State<VehicleFaultsScreen> createState() => _VehicleFaultsScreenState();
}

class _VehicleFaultsScreenState extends State<VehicleFaultsScreen> {
  late final VehicleFaultsViewModel viewModel = getIt<VehicleFaultsViewModel>(param1: widget.args);
  final AtelierHaptics _haptics = rememberAtelierHaptics();
  Object? _lastClearResult;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onState);
  }

  void _onState() {
    final result = viewModel.state.lastClearResult;
    if (result != null && !identical(result, _lastClearResult)) {
      if (result.isClean) {
        _haptics.confirm();
      } else {
        _haptics.reject();
      }
    }
    _lastClearResult = result;
  }

  @override
  void dispose() {
    viewModel.removeListener(_onState);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<bool>(
      listenable: viewModel,
      value: () => viewModel.state.confirmClearOpen ? true : null,
      onDismiss: viewModel.dismissClearConfirm,
      sheetBuilder: (context, _) => ClearFaultsSheet(
        state: viewModel.state,
        onConfirm: () {
          _haptics.confirm();
          viewModel.confirmClearDtcs();
        },
        onCancel: viewModel.dismissClearConfirm,
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => VehicleFaultsContent(
          state: viewModel.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: viewModel.refresh,
          onScanDtcs: () {
            _haptics.toggle();
            viewModel.scanDtcs();
          },
          onOpenClearConfirm: () {
            _haptics.toggle();
            viewModel.openClearConfirm();
          },
        ),
      ),
    );
  }
}

class VehicleFaultsContent extends StatelessWidget {
  final VehicleFaultsUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onScanDtcs;
  final VoidCallback onOpenClearConfirm;

  const VehicleFaultsContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onScanDtcs,
    required this.onOpenClearConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final vehicle = state.vehicle;
    final vehicleTitle = vehicle == null ? '' : '${vehicle.brand} ${vehicle.model}'.trim();
    final showBottomBar = state.planIncludesTelemetry && (state.canScanFaults || state.canResolveFaults);
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        bottomNavigationBar: showBottomBar ? _BottomBar(state: state, onScan: onScanDtcs, onClear: onOpenClearConfirm) : null,
        body: Column(
          children: [
            AtelierFichaPanel(
              onBack: onBack,
              title: vehicleTitle.isEmpty ? strings.diagFaultsTitle : vehicleTitle,
              subtitle: strings.diagFaultsCount(state.faults.length),
              identity: state.displayPlate.trim().isNotEmpty
                  ? AtelierPlate(plate: state.displayPlate, size: PlateSize.l)
                  : null,
              status: state.syncState.pendingFaults > 0
                  ? AtelierChip(
                      text: strings.diagFaultsPendingSync(state.syncState.pendingFaults),
                      kind: ChipKind.idle,
                    )
                  : null,
            ),
            Expanded(child: _body(context, strings)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations strings) {
    if (!state.planIncludesTelemetry) {
      return _padded(AtelierPlanLockedState(text: strings.diagHubPlanLocked));
    }
    if (!state.canReadFaults) {
      return _padded(AtelierNoPermissionState(text: strings.diagFaultsNoPermission));
    }
    final notice = state.notice;
    final error = state.error;
    final persistent = state.lastClearResult?.isClean == false;
    final freezeFrame = state.freezeFrame;
    return DelayedLoading(
      loading: state.isRefreshing && !state.isLoaded && state.faults.isEmpty,
      builder: (context, showSkeleton) {
        final items = <Widget>[
          if ((state.canScanFaults || state.canResolveFaults) && !state.isBluetoothConnected)
            AtelierBanner(message: strings.diagFaultsNeedBt, icon: Icons.info_outline, kind: BannerKind.info),
          if (notice != null)
            AtelierBanner(
              message: notice.asString(strings),
              icon: persistent ? Icons.warning_amber_outlined : Icons.check_circle_outline,
              kind: persistent ? BannerKind.wait : BannerKind.ok,
            ),
          if (error != null && state.faults.isNotEmpty)
            AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
          if (freezeFrame != null) _FreezeFrameCard(frame: freezeFrame),
          if (showSkeleton)
            for (var i = 0; i < 3; i++)
              const AtelierListRow(
                title: 'P0304',
                subtitle: 'Falla de encendido en el cilindro 4',
                loading: true,
              )
          else if (state.faults.isEmpty && error != null)
            AtelierErrorState(message: error.asString(strings), onRetry: onRefresh)
          else if (state.faults.isEmpty)
            AtelierEmptyState(text: strings.diagFaultsEmpty)
          else
            for (final fault in state.faults) _FaultRow(fault: fault),
        ];
        return Column(
          children: [
            AtelierRefreshBar(visible: state.isRefreshing && state.faults.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => items[index],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

class _BottomBar extends StatelessWidget {
  final VehicleFaultsUiState state;
  final VoidCallback onScan;
  final VoidCallback onClear;

  const _BottomBar({required this.state, required this.onScan, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final idle = state.isBluetoothConnected && !state.isScanning && !state.isClearing;
    return Material(
      color: context.scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(color: context.scheme.outlineVariant, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                spacing: 8,
                children: [
                  if (state.canScanFaults)
                    Expanded(
                      child: AtelierButton(
                        text: strings.diagFaultsScan,
                        onClick: onScan,
                        enabled: idle,
                        loading: state.isScanning,
                        icon: Icons.search,
                      ),
                    ),
                  if (state.canResolveFaults && state.faults.isNotEmpty)
                    Expanded(
                      child: AtelierButton(
                        text: strings.diagFaultsClear,
                        onClick: onClear,
                        style: AtelierButtonStyle.destructive,
                        enabled: idle,
                        icon: Icons.delete_outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmación del borrado de códigos (modo 04).
class ClearFaultsSheet extends StatelessWidget {
  final VehicleFaultsUiState state;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ClearFaultsSheet({super.key, required this.state, required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    return AtelierBottomSheet(
      title: strings.diagFaultsClearTitle,
      actions: [
        AtelierButton(
          text: strings.diagFaultsClearConfirm,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: !state.isClearing,
          loading: state.isClearing,
          icon: Icons.delete_outline,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onCancel,
          style: AtelierButtonStyle.text,
          enabled: !state.isClearing,
        ),
      ],
      content: [
        Text(
          strings.diagFaultsClearBody,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class _FaultRow extends StatelessWidget {
  final VehicleFault fault;

  const _FaultRow({required this.fault});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dtc = fault.dtc;
    final DtcEntry? catalogEntry = dtc == null ? null : DtcCatalog.describe(dtc);
    final severity = fault.severity ?? catalogEntry?.severity ?? FaultSeverity.medium;
    final description = fault.description.trim().isEmpty ? (catalogEntry?.description ?? '') : fault.description;
    final detectedAt = fault.detectedAt;
    final timeText = detectedAt == null ? null : formatLimaDateTime(detectedAt);
    return AtelierSurface(
      tier: severity == FaultSeverity.critical ? SurfaceTier.elevated : SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  fault.dtcCode,
                  style: context.text.titleLarge?.copyWith(color: context.scheme.onSurface),
                ),
              ),
              if (fault.isPending) AtelierChip(text: strings.diagFaultsPendingBadge, kind: ChipKind.idle),
              AtelierChip(text: faultSeverityLabel(strings, severity), kind: faultSeverityChipKind(severity)),
            ],
          ),
          if (description.trim().isNotEmpty)
            Text(description, style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface)),
          if (timeText != null && timeText.trim().isNotEmpty)
            Text(timeText, style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary)),
        ],
      ),
    );
  }
}

class _FreezeFrameCard extends StatelessWidget {
  final FreezeFrame frame;

  const _FreezeFrameCard({required this.frame});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final temp = frame.engineTempCelsius;
    final rpm = frame.engineRpm;
    final speed = frame.speedKmh;
    final parts = [
      if (frame.dtc != null) frame.dtc!.code,
      if (temp != null) '${temp.round()} °C',
      if (rpm != null) '$rpm rpm',
      if (speed != null) '$speed km/h',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        AtelierSectionHeader(title: strings.diagFaultsFreezeHeader),
        AtelierSurface(
          tier: SurfaceTier.elevated,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(16),
          child: Text(
            parts.isEmpty ? '—' : parts,
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
          ),
        ),
      ],
    );
  }
}
