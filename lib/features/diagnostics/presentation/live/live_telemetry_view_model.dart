import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_vehicle_telemetry_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/reconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/start_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/stop_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:flutter/foundation.dart';

/// US18: muestreo en vivo, avisos por umbral y muestra congelada; sin sesión OBD, la última lectura remota con su
/// historial por ventanas de una hora. Conectar el adaptador es del escáner: la sesión es compartida.
class LiveTelemetryViewModel extends ChangeNotifier {
  /// Ventana del historial remoto y tamaño de cada cubo (`time_bucket`).
  static const historyWindow = Duration(hours: 24);
  static const historyBucket = '1 hour';

  final ObserveSessionUseCase observeSession;
  final ObserveVehicleUseCase observeVehicle;
  final ObserveLiveTelemetryUseCase observeLiveTelemetry;
  final ObserveDiagnosticsSyncStateUseCase observeSyncState;
  final StartLiveTelemetryUseCase startTelemetry;
  final StopLiveTelemetryUseCase stopTelemetry;
  final ReconnectObdUseCase reconnectObd;
  final FreezeTelemetryUseCase freezeTelemetry;
  final GetLatestTelemetryUseCase getLatestTelemetry;
  final GetVehicleTelemetryHistoryUseCase getTelemetryHistory;
  final RequestNotificationPermissionUseCase requestNotificationPermission;
  final ConnectivityObserver connectivity;
  final DateTime Function() now;

  LiveTelemetryViewModel({
    required String vehicleId,
    String? plate,
    required this.observeSession,
    required this.observeVehicle,
    required this.observeLiveTelemetry,
    required this.observeSyncState,
    required this.startTelemetry,
    required this.stopTelemetry,
    required this.reconnectObd,
    required this.freezeTelemetry,
    required this.getLatestTelemetry,
    required this.getTelemetryHistory,
    required this.requestNotificationPermission,
    required this.connectivity,
    this.now = DateTime.now,
  }) : _vehicleId = vehicleId {
    _state = LiveTelemetryUiState(vehicleId: vehicleId, plate: plate, isOnline: connectivity.isOnline);
    _subscriptions.add(observeSession.execute().listen(_onSession));
    if (vehicleId.isNotEmpty) {
      _subscriptions.add(
        observeVehicle.execute(vehicleId).listen((vehicle) {
          if (vehicle != null) _update(_state.copyWith(vehicle: vehicle));
        }),
      );
      _subscriptions.add(
        observeSyncState.execute(vehicleId).listen((sync) => _update(_state.copyWith(syncState: sync))),
      );
    }
    _subscriptions.add(observeLiveTelemetry.execute().listen(_onLive));
    connectivity.addListener(_onConnectivity);
  }

  final String _vehicleId;
  late LiveTelemetryUiState _state;
  LiveTelemetryUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onSession(Session? session) {
    final canRead = session != null && session.has(Permission.telemetryRead) && session.canReadTelemetry();
    final firstGrant = canRead && !_state.canReadTelemetry;
    _update(
      _state.copyWith(
        canUseTelemetry: session?.canUseTelemetry() ?? false,
        canReadTelemetry: canRead,
        canReadFaults: session?.has(Permission.faultsRead) ?? false,
        planIncludesTelemetry: session?.plan?.iotTelemetryEnabled ?? true,
      ),
    );
    if (firstGrant && !_state.isBluetoothSessionActive) loadRemoteTelemetry();
  }

  void _onLive(LiveTelemetry live) {
    final previous = _state.linkState;
    final matchesVehicle = live.vehicleId == null || live.vehicleId == _vehicleId;
    final activeOnOther =
        !matchesVehicle &&
        (live.state == ObdLinkState.connected ||
            live.state == ObdLinkState.streaming ||
            live.state == ObdLinkState.reconnecting);
    if (activeOnOther) {
      _update(
        _state.copyWith(
          linkState: ObdLinkState.disconnected,
          clearLiveSample: true,
          liveWarnings: const {},
          connectedToOtherVehicle: true,
        ),
      );
    } else {
      _update(
        _state.copyWith(
          linkState: live.state,
          liveSample: live.sample,
          clearLiveSample: live.sample == null,
          liveWarnings: live.warnings,
          connectedToOtherVehicle: false,
        ),
      );
    }
    final fromScanner = previous == ObdLinkState.disconnected || previous == ObdLinkState.connecting;
    if (!activeOnOther && live.state == ObdLinkState.connected && fromScanner) startStreamingIfEligible();
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final reconnected = online && !_state.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (reconnected && _state.isRemoteMode) loadRemoteTelemetry();
  }

  /// Reconecta el escáner cuando la sesión cayó a `lost` y, si lo logra, retoma el muestreo.
  Future<void> reconnect() async {
    if (!_state.canUseTelemetry || _state.isReconnecting) return;
    _update(_state.copyWith(isReconnecting: true, clearError: true));
    try {
      await reconnectObd.execute();
      _update(_state.copyWith(isReconnecting: false));
      if (_vehicleId.isNotEmpty) await startStreamingIfEligible();
    } on Object catch (error) {
      _update(_state.copyWith(isReconnecting: false, error: toDiagnosticsUiText(error)));
    }
  }

  /// Inicia el muestreo si el escáner está conectado a este vehículo y no está ya muestreando.
  Future<void> startStreamingIfEligible() async {
    if (!_state.canUseTelemetry || _vehicleId.isEmpty || _state.isBusy) return;
    if (_state.isStreaming) return;
    _update(_state.copyWith(isBusy: true, clearError: true, clearFrozenSnapshot: true));
    try {
      // Sin permiso de notificaciones el aviso del servicio no se ve, pero el muestreo funciona igual.
      try {
        await requestNotificationPermission.execute();
      } on Object {
        // No impide muestrear.
      }
      await startTelemetry.execute(_vehicleId);
      _update(_state.copyWith(isBusy: false));
    } on Object catch (error) {
      _update(_state.copyWith(isBusy: false, error: toDiagnosticsUiText(error)));
    }
  }

  Future<void> stopStreaming() async {
    if (_state.isBusy) return;
    _update(_state.copyWith(isBusy: true, clearError: true));
    try {
      await stopTelemetry.execute();
      _update(_state.copyWith(isBusy: false));
    } on Object catch (error) {
      _update(_state.copyWith(isBusy: false, error: toDiagnosticsUiText(error)));
    }
  }

  /// US18 E2: fija los parámetros del instante. No hay endpoint que los ligue a la orden (H19).
  void freezeSample() {
    try {
      _update(_state.copyWith(frozenSnapshot: freezeTelemetry.execute(), clearError: true));
    } on Object catch (error) {
      _update(_state.copyWith(error: toDiagnosticsUiText(error)));
    }
  }

  void dismissFrozenSnapshot() => _update(_state.copyWith(clearFrozenSnapshot: true));

  /// Última lectura del servidor y su serie de las últimas 24 h por hora. Un fallo del historial no cuenta como error.
  Future<void> loadRemoteTelemetry() async {
    if (!_state.canReadTelemetry || _vehicleId.isEmpty || _state.isLoadingRemote) return;
    _update(_state.copyWith(isLoadingRemote: true, clearError: true));
    TelemetrySample? latest;
    Object? latestError;
    try {
      latest = await getLatestTelemetry.execute(_vehicleId);
    } on Object catch (error) {
      latestError = error;
    }
    final to = now();
    List<TelemetryHistoryBucket>? history;
    try {
      history = await getTelemetryHistory.execute(
        _vehicleId,
        from: to.subtract(historyWindow),
        to: to,
        bucket: historyBucket,
      );
    } on Object {
      history = null;
    }
    _update(
      _state.copyWith(
        isLoadingRemote: false,
        remoteTelemetry: latest,
        telemetryHistory: history,
        error: latestError == null ? null : toDiagnosticsUiText(latestError),
        clearError: latestError == null,
      ),
    );
  }

  void _update(LiveTelemetryUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
