import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_pid_tile.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US18: lectura en vivo de los parámetros del motor con avisos y muestra congelada.
class LiveTelemetryScreen extends StatefulWidget {
  final VehicleArgs args;

  const LiveTelemetryScreen({super.key, required this.args});

  @override
  State<LiveTelemetryScreen> createState() => _LiveTelemetryScreenState();
}

class _LiveTelemetryScreenState extends State<LiveTelemetryScreen> {
  late final LiveTelemetryViewModel viewModel = getIt<LiveTelemetryViewModel>(param1: widget.args);

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  /// Salir con el muestreo activo pide confirmación y lo detiene.
  Future<void> _confirmExit() async {
    final strings = AppLocalizations.of(context);
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.diagLiveExitTitle),
        content: Text(strings.diagLiveExitBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(strings.proposalsCancel)),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(strings.diagLiveExitConfirm)),
        ],
      ),
    );
    if (leave != true || !mounted) return;
    await viewModel.stopStreaming();
    if (mounted && !viewModel.state.isStreamingHere) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => PopScope(
        canPop: !viewModel.state.isStreamingHere,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmExit();
        },
        child: LiveTelemetryContent(
          state: viewModel.state,
          onBack: () => Navigator.of(context).maybePop(),
          onStart: viewModel.startStreaming,
          onStop: viewModel.stopStreaming,
          onFreeze: viewModel.freezeSample,
          onClearFrozen: viewModel.clearFrozenSnapshot,
          onRefreshRemote: viewModel.refreshRemote,
          onReconnect: () => AppNavigator.push(
            context,
            AppRoute.diagnosticsHub,
            DiagnosticsHubArgs(initialVehicleId: viewModel.state.vehicleId),
          ),
        ),
      ),
    );
  }
}

class LiveTelemetryContent extends StatelessWidget {
  final LiveTelemetryUiState state;
  final VoidCallback onBack;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onFreeze;
  final VoidCallback onClearFrozen;
  final VoidCallback onRefreshRemote;
  final VoidCallback onReconnect;

  const LiveTelemetryContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onStart,
    required this.onStop,
    required this.onFreeze,
    required this.onClearFrozen,
    required this.onRefreshRemote,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(title: strings.diagLiveTitle, onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                for (final item in _items(context, strings))
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _items(BuildContext context, AppLocalizations strings) {
    if (!state.hasAnyPermission) return [AtelierNoPermissionState(text: strings.diagLiveNoPermission)];
    final secondary = context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary);
    final plate = state.plate;
    final sample = state.displayedSample;
    final error = state.error;
    final sync = state.sync;
    final linkState = state.live.state;
    final frozen = state.frozen;
    return [
      Row(
        spacing: 12,
        children: [
          if (plate != null) AtelierPlate(plate: plate),
          const Spacer(),
          if (state.isStreamingHere) AtelierLiveBeacon(color: context.atelier.info),
          if (state.showRemote)
            AtelierChip(text: strings.diagBtStatusRemote, kind: ChipKind.idle)
          else
            AtelierChip(text: obdLinkStateLabel(strings, linkState), kind: obdLinkStateChipKind(linkState)),
        ],
      ),
      if (state.isOtherVehicle)
        AtelierBanner(
          message: strings.diagLiveOtherVehicleWarning,
          icon: Icons.info_outline,
          kind: BannerKind.wait,
        ),
      if (linkState == ObdLinkState.reconnecting && !state.isOtherVehicle)
        AtelierBanner(message: strings.diagBtStatusReconnecting, icon: Icons.sync_outlined, kind: BannerKind.wait),
      if (linkState == ObdLinkState.lost && !state.isOtherVehicle)
        AtelierBanner(message: strings.diagErrConnectionLost, icon: Icons.bluetooth_disabled_outlined),
      if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      if (state.showRemote) ...[
        AtelierBanner(message: strings.diagLiveRemoteBanner, icon: Icons.cloud_outlined, kind: BannerKind.info),
        if (!state.isOnline) const AtelierRequiresConnection(),
        if (state.remoteLoaded && sample == null) Text(strings.diagLiveRemoteEmpty, style: secondary),
      ],
      if (state.isStreamingHere && sample == null) Text(strings.diagLiveWaitingSample, style: secondary),
      // H23: sin temperatura la lectura no se guarda ni se envía.
      if (!state.showRemote && sample != null && !sample.canBeSent)
        AtelierBanner(message: strings.diagLiveMissingPid0105, icon: Icons.warning_amber_outlined, kind: BannerKind.wait),
      if (sample != null) ...[
        Text(strings.diagLiveLastSample(formatLimaDateTime(sample.timestamp)), style: secondary),
        TelemetryGrid(sample: sample, warnings: state.displayedWarnings, showIntake: !state.showRemote),
      ],
      if (state.needsConnection)
        AtelierButton(
          text: strings.diagLiveReconnect,
          onClick: onReconnect,
          style: AtelierButtonStyle.outlined,
          minHeight: 56,
          icon: Icons.bluetooth_outlined,
        ),
      if (state.canIngest && state.isStreamingHere)
        AtelierButton(
          text: strings.diagLiveStop,
          onClick: onStop,
          style: AtelierButtonStyle.tonal,
          minHeight: 56,
          enabled: !state.isBusy,
          loading: state.isBusy,
          icon: Icons.stop_outlined,
        )
      else if (state.canIngest && !state.needsConnection)
        AtelierButton(
          text: strings.diagLiveStart,
          onClick: onStart,
          minHeight: 56,
          enabled: state.canStart,
          loading: state.isBusy,
          icon: Icons.play_arrow_outlined,
        ),
      if (state.canIngest)
        AtelierButton(
          text: strings.diagLiveFreeze,
          onClick: onFreeze,
          style: AtelierButtonStyle.outlined,
          minHeight: 56,
          enabled: state.canFreeze,
          icon: Icons.ac_unit_outlined,
        ),
      if (state.showRemote)
        AtelierButton(
          text: strings.diagLiveRefresh,
          onClick: onRefreshRemote,
          style: AtelierButtonStyle.text,
          enabled: state.isOnline && !state.isLoadingRemote,
          loading: state.isLoadingRemote,
          icon: Icons.refresh_outlined,
        ),
      if (frozen != null) _FrozenCard(snapshot: frozen, onClose: onClearFrozen),
      if (state.canIngest && sync != null)
        Text(
          sync.pendingReadings == 0 ? strings.diagLiveSyncOk : strings.diagLiveSyncPending(sync.pendingReadings),
          style: secondary,
        ),
    ];
  }
}

/// Fichas de los parámetros; las que rebasan un umbral se marcan (US18 E1).
class TelemetryGrid extends StatelessWidget {
  final TelemetrySample sample;
  final Set<TelemetryWarning> warnings;

  /// La presión de admisión solo existe en vivo: ni el lote ni la lectura remota la traen.
  final bool showIntake;

  const TelemetryGrid({super.key, required this.sample, required this.warnings, required this.showIntake});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    String text(num? value, {int decimals = 0}) => value == null ? '--' : value.toStringAsFixed(decimals);
    AtelierPidTile tile(String label, String value, String unit, {bool alert = false}) => AtelierPidTile(
      label: label,
      value: value,
      unit: unit,
      severity: alert ? PidSeverity.warning : PidSeverity.normal,
      statusText: alert ? strings.diagLiveOutOfRange : null,
    );
    final rpm = sample.engineRpm;
    final coolant = sample.engineTempCelsius;
    final volts = sample.batteryVoltage;
    final tiles = [
      tile(
        strings.diagLivePidRpm,
        text(rpm),
        'rpm',
        alert: warnings.contains(TelemetryWarning.highRpm),
      ),
      tile(
        strings.diagLivePidCoolant,
        text(coolant),
        '°C',
        alert: warnings.contains(TelemetryWarning.coolantOverheat),
      ),
      if (showIntake) tile(strings.diagLivePidIntake, text(sample.intakePressureKpa), 'kPa'),
      tile(
        strings.diagLivePidVoltage,
        text(volts, decimals: 1),
        'V',
        alert:
            warnings.contains(TelemetryWarning.lowVoltage) || warnings.contains(TelemetryWarning.highVoltage),
      ),
      if (sample.speedKmh != null) tile(strings.diagLivePidSpeed, text(sample.speedKmh), 'km/h'),
      if (sample.fuelPercentage != null) tile(strings.diagLivePidFuel, text(sample.fuelPercentage), '%'),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [for (final item in tiles) SizedBox(width: width, child: item)],
        );
      },
    );
  }
}

class _FrozenCard extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  final VoidCallback onClose;

  const _FrozenCard({required this.snapshot, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final secondary = context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary);
    final sample = snapshot.sample;
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(strings.diagLiveFrozenTitle, style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface)),
          Text(formatLimaDateTime(sample.timestamp), style: secondary),
          TelemetryGrid(sample: sample, warnings: snapshot.warnings, showIntake: true),
          Text(sample.canBeSent ? strings.diagLiveFrozenSaved : strings.diagLiveMissingPid0105, style: secondary),
          AtelierButton(text: strings.diagLiveFrozenClose, onClick: onClose, style: AtelierButtonStyle.text),
        ],
      ),
    );
  }
}
