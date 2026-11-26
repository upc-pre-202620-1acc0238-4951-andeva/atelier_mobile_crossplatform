import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_pid_tile.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry_thresholds.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US18: telemetría en vivo de un vehículo. Con el escáner conectado muestrea cada 2 s y avisa por umbral; sin él, quien
/// puede leer ve la última lectura del servidor y su historial por hora.
class LiveTelemetryScreen extends StatefulWidget {
  final VehicleArgs args;

  const LiveTelemetryScreen({super.key, required this.args});

  @override
  State<LiveTelemetryScreen> createState() => _LiveTelemetryScreenState();
}

class _LiveTelemetryScreenState extends State<LiveTelemetryScreen> {
  late final LiveTelemetryViewModel viewModel = getIt<LiveTelemetryViewModel>(param1: widget.args);

  @override
  void initState() {
    super.initState();
    // Remoto: la lectura y el historial se piden al abrir, como Android al conocer el permiso.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && viewModel.state.isRemoteMode && viewModel.state.remoteTelemetry == null) {
        viewModel.loadRemoteTelemetry();
      }
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<TelemetrySnapshot>(
      listenable: viewModel,
      value: () => viewModel.state.frozenSnapshot,
      onDismiss: viewModel.dismissFrozenSnapshot,
      sheetBuilder: (context, snapshot) =>
          FrozenSampleSheet(snapshot: snapshot, onDismiss: viewModel.dismissFrozenSnapshot),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final state = viewModel.state;
          return LiveTelemetryContent(
            state: state,
            onBack: () => Navigator.of(context).maybePop(),
            onStartStreaming: viewModel.startStreamingIfEligible,
            onStopStreaming: viewModel.stopStreaming,
            onFreezeSample: viewModel.freezeSample,
            onRefreshRemote: viewModel.loadRemoteTelemetry,
            onReconnect: viewModel.reconnect,
            onOpenFaults: () => AppNavigator.push(
              context,
              AppRoute.vehicleFaults,
              VehicleArgs(vehicleId: state.vehicleId, plate: state.displayPlate.isEmpty ? null : state.displayPlate),
            ),
          );
        },
      ),
    );
  }
}

/// Una ficha de la rejilla: valor, unidad, estado y barra calibrada.
class PidMetric {
  final String label;
  final String value;
  final String unit;
  final PidSeverity severity;
  final String? statusText;
  final double? progress;
  final double? markerAt;

  const PidMetric({
    required this.label,
    required this.value,
    required this.unit,
    this.severity = PidSeverity.normal,
    this.statusText,
    this.progress,
    this.markerAt,
  });
}

class LiveTelemetryContent extends StatelessWidget {
  final LiveTelemetryUiState state;
  final VoidCallback onBack;
  final VoidCallback onStartStreaming;
  final VoidCallback onStopStreaming;
  final VoidCallback onFreezeSample;
  final Future<void> Function() onRefreshRemote;
  final VoidCallback onOpenFaults;
  final VoidCallback onReconnect;

  const LiveTelemetryContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onStartStreaming,
    required this.onStopStreaming,
    required this.onFreezeSample,
    required this.onRefreshRemote,
    required this.onOpenFaults,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final haptics = rememberAtelierHaptics();
    final isRemote = state.isRemoteMode;
    final totalPending = state.syncState.pendingReadings + state.syncState.pendingFaults;
    final syncSubtitle = totalPending > 0 ? strings.diagLiveSyncPending(totalPending) : strings.diagLiveSyncOk;
    final vehicle = state.vehicle;
    final vehicleTitle = vehicle == null || '${vehicle.brand} ${vehicle.model}'.trim().isEmpty
        ? strings.diagLiveTitle
        : '${vehicle.brand} ${vehicle.model}'.trim();
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        backgroundColor: context.scheme.surface,
        bottomNavigationBar: state.planIncludesTelemetry && (state.canUseTelemetry || state.canReadTelemetry)
            ? _BottomBar(
                state: state,
                onStart: () {
                  haptics.confirm();
                  onStartStreaming();
                },
                onStop: () {
                  haptics.toggle();
                  onStopStreaming();
                },
                onFreeze: () {
                  haptics.confirm();
                  onFreezeSample();
                },
                onReconnect: () {
                  haptics.confirm();
                  onReconnect();
                },
                onRefreshRemote: () => onRefreshRemote(),
                onOpenFaults: onOpenFaults,
              )
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AtelierFichaPanel(
              onBack: onBack,
              title: vehicleTitle,
              subtitle: syncSubtitle,
              identity: state.displayPlate.isNotEmpty
                  ? AtelierPlate(plate: state.displayPlate, size: PlateSize.l)
                  : null,
              status: isRemote
                  ? AtelierChip(
                      text: strings.diagBtStatusRemote,
                      kind: ChipKind.info,
                      icon: Icons.cloud_download_outlined,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        if (state.linkState == ObdLinkState.streaming) AtelierLiveBeacon(color: colors.onPanel),
                        AtelierChip(
                          text: obdLinkStateLabel(strings, state.linkState),
                          kind: obdLinkStateChipKind(state.linkState),
                        ),
                      ],
                    ),
            ),
            Expanded(child: _body(context, strings)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations strings) {
    if (!state.planIncludesTelemetry) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierPlanLockedState(text: strings.diagHubPlanLocked),
      );
    }
    if (!state.canUseTelemetry && !state.canReadTelemetry) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierNoPermissionState(text: strings.diagLiveNoPermission),
      );
    }
    final isRemote = state.isRemoteMode;
    return Column(
      children: [
        AtelierRefreshBar(visible: isRemote && state.isLoadingRemote && state.remoteTelemetry != null),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (isRemote) await onRefreshRemote();
            },
            child: DelayedLoading(
              loading: isRemote && state.isLoadingRemote && state.remoteTelemetry == null,
              builder: (context, showSkeleton) => _list(context, strings, showSkeleton),
            ),
          ),
        ),
      ],
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final colors = context.atelier;
    final isRemote = state.isRemoteMode;
    final error = state.error;
    final sampleTime = isRemote ? state.remoteTelemetry?.timestamp : state.liveSample?.timestamp;
    final rows = _chunked(
      metricsForSample(strings, isRemote ? _remoteSample(state.remoteTelemetry) : state.liveSample),
      2,
    );
    final children = <Widget>[
      if (state.connectedToOtherVehicle)
        AtelierBanner(
          message: strings.diagLiveOtherVehicleWarning,
          icon: Icons.warning_amber_outlined,
          kind: BannerKind.wait,
        ),
      if (isRemote)
        AtelierBanner(message: strings.diagLiveRemoteBanner, icon: Icons.info_outline, kind: BannerKind.info),
      if (state.missingCoolantPid0105)
        AtelierBanner(
          message: strings.diagLiveMissingPid0105,
          icon: Icons.warning_amber_outlined,
          kind: BannerKind.wait,
        ),
      if (state.linkState == ObdLinkState.lost)
        AtelierBanner(message: strings.diagErrConnectionLost, icon: Icons.error_outline, kind: BannerKind.bad),
      if (error != null && (!isRemote || state.remoteTelemetry != null))
        AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
    ];
    if (isRemote && state.remoteTelemetry == null && error != null && !state.isOnline) {
      children.add(AtelierOfflineState(onRetry: () => onRefreshRemote()));
    } else if (isRemote && state.remoteTelemetry == null && error != null) {
      children.add(AtelierErrorState(message: error.asString(strings), onRetry: () => onRefreshRemote()));
    } else if (isRemote && !state.isLoadingRemote && state.remoteTelemetry == null) {
      children.add(
        AtelierEmptyState(
          text: strings.diagLiveRemoteEmpty,
          actionLabel: strings.diagLiveRefresh,
          onAction: () => onRefreshRemote(),
        ),
      );
    } else {
      children.add(
        Row(
          spacing: 8,
          children: [
            if (state.linkState == ObdLinkState.streaming) AtelierLiveBeacon(color: context.scheme.primary),
            Flexible(
              child: Text(
                sampleTime == null
                    ? strings.diagLiveWaitingSample
                    : strings.diagLiveLastSample(formatLimaTime(sampleTime)),
                style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
              ),
            ),
          ],
        ),
      );
      for (final pair in rows) {
        children.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              for (final metric in pair)
                Expanded(
                  child: CalibratedPidTile(metric: metric, loading: showSkeleton),
                ),
              if (pair.length == 1) const Spacer(),
            ],
          ),
        );
      }
      if (isRemote && state.telemetryHistory.isNotEmpty) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AtelierSectionHeader(title: strings.diagLiveHistoryHeader, count: state.telemetryHistory.length),
          ),
        );
        for (final bucket in state.telemetryHistory) {
          children.add(HistoryBucketRow(bucket: bucket));
        }
      }
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => children[index],
    );
  }

  static TelemetrySample _remoteSample(TelemetrySample? remote) => TelemetrySample(
    timestamp: remote?.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    engineTempCelsius: remote?.engineTempCelsius,
    engineRpm: remote?.engineRpm,
    speedKmh: remote?.speedKmh,
    batteryVoltage: remote?.batteryVoltage,
    fuelPercentage: remote?.fuelPercentage,
  );

  static List<List<T>> _chunked<T>(List<T> items, int size) => [
    for (var i = 0; i < items.length; i += size) items.sublist(i, i + size > items.length ? items.length : i + size),
  ];
}

class _BottomBar extends StatelessWidget {
  final LiveTelemetryUiState state;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onFreeze;
  final VoidCallback onReconnect;
  final VoidCallback onRefreshRemote;
  final VoidCallback onOpenFaults;

  const _BottomBar({
    required this.state,
    required this.onStart,
    required this.onStop,
    required this.onFreeze,
    required this.onReconnect,
    required this.onRefreshRemote,
    required this.onOpenFaults,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final streaming = state.isStreaming;
    final faults = AtelierButton(
      text: strings.diagLiveFaults,
      onClick: onOpenFaults,
      style: AtelierButtonStyle.outlined,
      icon: Icons.build_outlined,
    );
    final List<Widget> buttons;
    if (state.isBluetoothSessionActive && state.canUseTelemetry) {
      if (state.linkState == ObdLinkState.lost) {
        buttons = [
          Expanded(
            child: AtelierButton(
              text: strings.diagLiveReconnect,
              onClick: onReconnect,
              loading: state.isReconnecting,
              enabled: !state.isReconnecting,
              icon: Icons.refresh_outlined,
            ),
          ),
          if (state.canReadFaults) Expanded(child: faults),
        ];
      } else {
        buttons = [
          Expanded(
            child: AtelierButton(
              text: strings.diagLiveFreeze,
              onClick: onFreeze,
              style: AtelierButtonStyle.outlined,
              enabled: state.liveSample != null,
              icon: Icons.ac_unit_outlined,
            ),
          ),
          if (state.canReadFaults) Expanded(child: faults),
          Expanded(
            child: AtelierButton(
              text: streaming ? strings.diagLiveStop : strings.diagLiveStart,
              onClick: streaming ? onStop : onStart,
              style: streaming ? AtelierButtonStyle.destructive : AtelierButtonStyle.filled,
              icon: streaming ? Icons.stop_outlined : Icons.play_arrow_outlined,
            ),
          ),
        ];
      }
    } else {
      buttons = [
        Expanded(
          child: AtelierButton(
            text: strings.diagLiveRefresh,
            onClick: onRefreshRemote,
            style: AtelierButtonStyle.outlined,
            enabled: !state.isLoadingRemote && state.isOnline,
            loading: state.isLoadingRemote,
            icon: Icons.refresh_outlined,
          ),
        ),
        if (state.canReadFaults)
          Expanded(
            child: AtelierButton(text: strings.diagLiveFaults, onClick: onOpenFaults, icon: Icons.build_outlined),
          ),
      ];
    }
    return Material(
      color: context.scheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(spacing: 8, children: buttons),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una ventana de promedios del historial remoto.
class HistoryBucketRow extends StatelessWidget {
  final TelemetryHistoryBucket bucket;

  const HistoryBucketRow({super.key, required this.bucket});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final time = bucket.bucketTime;
    final parts = [
      if (bucket.avgEngineRpm != null) '${bucket.avgEngineRpm} rpm',
      if (bucket.avgEngineTempCelsius != null) '${bucket.avgEngineTempCelsius!.round()} °C',
      if (bucket.avgBatteryVoltage != null) '${bucket.avgBatteryVoltage!.toStringAsFixed(1)} V',
      if (bucket.avgSpeedKmh != null) '${bucket.avgSpeedKmh} km/h',
    ].join(' · ');
    return AtelierListRow(
      title: time == null ? '—' : formatLimaDateTime(time),
      subtitle: parts.isEmpty ? null : parts,
      trailing: AtelierChip(text: strings.diagLiveHistorySamples(bucket.sampleCount), kind: ChipKind.idle),
    );
  }
}

/// Las ocho fichas calibradas de una muestra; las que rebasan un umbral cambian de nivel (US18 E1).
List<PidMetric> metricsForSample(AppLocalizations strings, TelemetrySample? sample) {
  String number(num? value, {int decimals = 0}) => value == null ? '—' : value.toStringAsFixed(decimals);
  double fraction(num value, num max, {num min = 0}) => ((value - min) / (max - min)).clamp(0.0, 1.0).toDouble();

  final rpm = sample?.engineRpm;
  final rpmSeverity = rpm == null
      ? PidSeverity.normal
      : rpm > TelemetryThresholds.maxEngineRpm
      ? PidSeverity.critical
      : rpm > 5000
      ? PidSeverity.warning
      : PidSeverity.normal;
  final rpmStatus = rpmSeverity != PidSeverity.normal
      ? strings.diagPidStatusHighRpm
      : rpm != null
      ? strings.diagPidStatusNormal
      : null;

  final temp = sample?.engineTempCelsius;
  final tempSeverity = temp == null
      ? PidSeverity.normal
      : temp > TelemetryThresholds.maxCoolantCelsius
      ? PidSeverity.critical
      : temp > 98.0
      ? PidSeverity.warning
      : PidSeverity.normal;
  final tempStatus = switch (tempSeverity) {
    PidSeverity.critical => strings.diagPidStatusOverheat,
    PidSeverity.warning => strings.diagPidStatusTempHigh,
    PidSeverity.normal => temp != null ? strings.diagPidStatusNormal : null,
  };

  final volt = sample?.batteryVoltage;
  final voltSeverity = volt == null
      ? PidSeverity.normal
      : volt < TelemetryThresholds.minBatteryVolts || volt > TelemetryThresholds.maxBatteryVolts
      ? PidSeverity.critical
      : volt < 12.4
      ? PidSeverity.warning
      : PidSeverity.normal;
  final voltStatus = volt == null
      ? null
      : volt < TelemetryThresholds.minBatteryVolts || volt < 12.4
      ? strings.diagPidStatusLowVolt
      : volt > TelemetryThresholds.maxBatteryVolts
      ? strings.diagPidStatusHighVolt
      : strings.diagPidStatusNormal;

  final load = sample?.engineLoadPercentage;
  final loadSeverity = load != null && load > 90.0 ? PidSeverity.warning : PidSeverity.normal;
  final loadStatus = load == null
      ? null
      : loadSeverity == PidSeverity.warning
      ? strings.diagPidStatusHighLoad
      : strings.diagPidStatusNormal;

  final speed = sample?.speedKmh;
  final throttle = sample?.throttlePositionPercentage;
  final fuel = sample?.fuelPercentage;
  final fuelSeverity = fuel != null && fuel < 15.0 ? PidSeverity.warning : PidSeverity.normal;
  final fuelStatus = fuel == null
      ? null
      : fuelSeverity == PidSeverity.warning
      ? strings.diagPidStatusLowFuel
      : strings.diagPidStatusNormal;
  final intake = sample?.intakePressureKpa;

  return [
    PidMetric(
      label: strings.diagPidRpm,
      value: number(rpm),
      unit: rpm != null ? strings.diagPidUnitRpm : '',
      severity: rpmSeverity,
      statusText: rpmStatus,
      progress: rpm == null ? null : fraction(rpm, 7000),
    ),
    PidMetric(
      label: strings.diagPidCoolant,
      value: temp == null ? '—' : temp.round().toString(),
      unit: temp != null ? strings.diagPidUnitCelsius : '',
      severity: tempSeverity,
      statusText: tempStatus,
      progress: temp == null ? null : fraction(temp, 120),
      markerAt: 0.82,
    ),
    PidMetric(
      label: strings.diagPidVoltage,
      value: number(volt, decimals: 1),
      unit: volt != null ? strings.diagPidUnitVolts : '',
      severity: voltSeverity,
      statusText: voltStatus,
      progress: volt == null ? null : fraction(volt, 16, min: 10),
    ),
    PidMetric(
      label: strings.diagPidLoad,
      value: load == null ? '—' : load.round().toString(),
      unit: load != null ? strings.diagPidUnitPercent : '',
      severity: loadSeverity,
      statusText: loadStatus,
      progress: load == null ? null : fraction(load, 100),
    ),
    PidMetric(
      label: strings.diagPidSpeed,
      value: number(speed),
      unit: speed != null ? strings.diagPidUnitKmh : '',
      progress: speed == null ? null : fraction(speed, 180),
    ),
    PidMetric(
      label: strings.diagPidThrottle,
      value: throttle == null ? '—' : throttle.round().toString(),
      unit: throttle != null ? strings.diagPidUnitPercent : '',
      progress: throttle == null ? null : fraction(throttle, 100),
    ),
    PidMetric(
      label: strings.diagPidFuel,
      value: fuel == null ? '—' : fuel.round().toString(),
      unit: fuel != null ? strings.diagPidUnitPercent : '',
      severity: fuelSeverity,
      statusText: fuelStatus,
      progress: fuel == null ? null : fraction(fuel, 100),
    ),
    PidMetric(
      label: strings.diagPidIntakePressure,
      value: number(intake),
      unit: intake != null ? strings.diagPidUnitKpa : '',
      statusText: intake != null ? strings.diagPidStatusNormal : null,
      progress: intake == null ? null : fraction(intake, 255),
    ),
  ];
}

/// Ficha calibrada: [AtelierPidTile] más su barra métrica con marca de umbral.
class CalibratedPidTile extends StatelessWidget {
  final PidMetric metric;
  final bool loading;

  const CalibratedPidTile({super.key, required this.metric, required this.loading});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final barColor = switch (metric.severity) {
      PidSeverity.critical => colors.badMark,
      PidSeverity.warning => colors.warnMark,
      PidSeverity.normal => context.scheme.primary,
    };
    return AtelierSurface(
      tier: metric.severity == PidSeverity.normal ? SurfaceTier.card : SurfaceTier.elevated,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          AtelierPidTile(
            label: metric.label,
            value: metric.value,
            unit: metric.unit,
            severity: metric.severity,
            statusText: metric.statusText,
            loading: loading,
          ),
          if (!loading) AtelierMetricBar(progress: metric.progress ?? 0, color: barColor, markerAt: metric.markerAt),
        ],
      ),
    );
  }
}

/// Muestra congelada (US18 E2): ya está guardada localmente y viajará en el próximo lote.
class FrozenSampleSheet extends StatelessWidget {
  final TelemetrySnapshot snapshot;
  final VoidCallback onDismiss;

  const FrozenSampleSheet({super.key, required this.snapshot, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final rows = LiveTelemetryContent._chunked(metricsForSample(strings, snapshot.sample), 2);
    return AtelierBottomSheet(
      title: strings.diagLiveFrozenTitle,
      actions: [AtelierButton(text: strings.commonCancel, onClick: onDismiss, style: AtelierButtonStyle.outlined)],
      content: [
        Text(
          strings.diagLiveFrozenSaved,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        Text(
          strings.diagLiveLastSample(formatLimaDateTime(snapshot.sample.timestamp)),
          style: context.text.labelLarge?.copyWith(color: context.scheme.onSurface),
        ),
        for (final pair in rows)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              for (final metric in pair) Expanded(child: CalibratedPidTile(metric: metric, loading: false)),
              if (pair.length == 1) const Spacer(),
            ],
          ),
      ],
    );
  }
}
