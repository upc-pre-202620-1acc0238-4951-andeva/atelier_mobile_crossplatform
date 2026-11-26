import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/start_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/stop_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:flutter/foundation.dart';

/// US18: muestreo en vivo, avisos por umbral y muestra congelada; sin sesión OBD, la última lectura remota.
/// Conectar el adaptador es del escáner: la sesión es compartida.
class LiveTelemetryViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveVehicleUseCase observeVehicle;
  final ObserveLiveTelemetryUseCase observeLiveTelemetry;
  final ObserveDiagnosticsSyncStateUseCase observeSyncState;
  final StartLiveTelemetryUseCase startTelemetry;
  final StopLiveTelemetryUseCase stopTelemetry;
  final FreezeTelemetryUseCase freezeTelemetry;
  final GetLatestTelemetryUseCase getLatestTelemetry;
  final RequestNotificationPermissionUseCase requestNotificationPermission;
  final ConnectivityObserver connectivity;

  LiveTelemetryViewModel({
    required String vehicleId,
    String? plate,
    required this.observeSession,
    required this.observeVehicle,
    required this.observeLiveTelemetry,
    required this.observeSyncState,
    required this.startTelemetry,
    required this.stopTelemetry,
    required this.freezeTelemetry,
    required this.getLatestTelemetry,
    required this.requestNotificationPermission,
    required this.connectivity,
  }) {
    _state = LiveTelemetryUiState(vehicleId: vehicleId, plate: plate, isOnline: connectivity.isOnline);
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(
      observeVehicle.execute(vehicleId).listen((vehicle) => _update(_state.copyWith(plate: vehicle?.plate))),
    );
    _subscriptions.add(
      observeLiveTelemetry.execute().listen((live) => _update(_state.copyWith(live: live))),
    );
    _subscriptions.add(
      observeSyncState.execute(vehicleId).listen((sync) => _update(_state.copyWith(sync: sync))),
    );
    connectivity.addListener(_onConnectivity);
  }

  late LiveTelemetryUiState _state;
  LiveTelemetryUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onSession(Session? session) {
    final canReadRemote =
        session != null && session.has(Permission.telemetryRead) && session.canReadTelemetry();
    final firstGrant = canReadRemote && !_state.canReadRemote;
    _update(
      _state.copyWith(canIngest: session?.canUseTelemetry() ?? false, canReadRemote: canReadRemote),
    );
    if (firstGrant) refreshRemote();
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final reconnected = online && !_state.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (reconnected && _state.showRemote) refreshRemote();
  }

  /// Última lectura del servidor. Sin red o sin permiso no llama.
  Future<void> refreshRemote() async {
    if (!_state.canReadRemote || !_state.isOnline || _state.isLoadingRemote) return;
    _update(_state.copyWith(isLoadingRemote: true, clearError: true));
    try {
      final sample = await getLatestTelemetry.execute(_state.vehicleId);
      _update(
        _state.copyWith(
          isLoadingRemote: false,
          remoteLoaded: true,
          remoteSample: sample,
          clearRemoteSample: sample == null,
        ),
      );
    } on Object catch (error) {
      _update(_state.copyWith(isLoadingRemote: false, error: toDiagnosticsUiText(error)));
    }
  }

  Future<void> startStreaming() async {
    if (!_state.canStart) return;
    _update(_state.copyWith(isBusy: true, clearError: true, clearFrozen: true));
    try {
      // Sin permiso de notificaciones el aviso del servicio no se ve, pero el muestreo funciona igual.
      try {
        await requestNotificationPermission.execute();
      } on Object {
        // No impide muestrear.
      }
      await startTelemetry.execute(_state.vehicleId);
      _update(_state.copyWith(isBusy: false));
    } on Object catch (error) {
      _update(_state.copyWith(isBusy: false, error: toDiagnosticsUiText(error)));
    }
  }

  Future<void> stopStreaming() async {
    if (_state.isBusy || !_state.isStreamingHere) return;
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
    if (!_state.canFreeze) return;
    try {
      _update(_state.copyWith(frozen: freezeTelemetry.execute(), clearError: true));
    } on Object catch (error) {
      _update(_state.copyWith(error: toDiagnosticsUiText(error)));
    }
  }

  void clearFrozenSnapshot() => _update(_state.copyWith(clearFrozen: true));

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
