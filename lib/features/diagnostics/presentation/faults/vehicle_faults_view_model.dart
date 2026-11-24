import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/clear_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/scan_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_vehicle_use_case.dart';
import 'package:flutter/foundation.dart';

class VehicleFaultsViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveVehicleUseCase observeVehicle;
  final ObserveVehicleFaultsUseCase observeVehicleFaults;
  final ObserveDiagnosticsSyncStateUseCase observeSyncState;
  final ObserveLiveTelemetryUseCase observeLiveTelemetry;
  final ConnectivityObserver connectivity;
  final RefreshVehicleFaultsUseCase refreshVehicleFaults;
  final ScanFaultsUseCase scanFaultsUseCase;
  final ClearFaultsUseCase clearFaultsUseCase;
  final String vehicleId;

  VehicleFaultsViewModel({
    required this.observeSession,
    required this.observeVehicle,
    required this.observeVehicleFaults,
    required this.observeSyncState,
    required this.observeLiveTelemetry,
    required this.connectivity,
    required this.refreshVehicleFaults,
    required this.scanFaultsUseCase,
    required this.clearFaultsUseCase,
    required this.vehicleId,
    String? plate,
  }) : _state = VehicleFaultsUiState(vehicleId: vehicleId, plate: plate, isOnline: connectivity.isOnline) {
    _subscriptions.add(
      observeSession.execute().listen((session) {
        final canUseTelemetry = session?.canUseTelemetry() ?? false;
        final planIncludes = session?.plan?.iotTelemetryEnabled ?? true;
        final canResolve = (session?.has(Permission.faultsResolve) ?? false) && planIncludes;
        _update(
          _state.copyWith(
            planIncludesTelemetry: planIncludes,
            canReadFaults: session?.has(Permission.faultsRead) ?? false,
            canScanFaults: canUseTelemetry || canResolve,
            canResolveFaults: canResolve,
          ),
        );
      }),
    );
    if (vehicleId.trim().isNotEmpty) {
      _subscriptions.add(
        observeVehicle.execute(vehicleId).listen((vehicle) {
          if (vehicle != null) _update(_state.copyWith(vehicle: vehicle));
        }),
      );
      _subscriptions.add(
        observeVehicleFaults
            .execute(vehicleId)
            .listen((faults) => _update(_state.copyWith(faults: faults, isLoaded: true))),
      );
      _subscriptions.add(
        observeSyncState.execute(vehicleId).listen((sync) => _update(_state.copyWith(syncState: sync))),
      );
    } else {
      _state = _state.copyWith(isLoaded: true);
    }
    _subscriptions.add(
      observeLiveTelemetry.execute().listen((live) => _update(_state.copyWith(linkState: live.state))),
    );
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  VehicleFaultsUiState _state;
  VehicleFaultsUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  void _update(VehicleFaultsUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (vehicleId.trim().isEmpty || _state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    try {
      await refreshVehicleFaults.execute(vehicleId);
      _update(_state.copyWith(isRefreshing: false, isLoaded: true));
    } on Object catch (e) {
      _update(_state.copyWith(isRefreshing: false, isLoaded: true, error: toDiagnosticsUiText(e)));
    }
  }

  Future<void> scanDtcs() async {
    final state = _state;
    if (!state.canScanFaults || !state.isBluetoothConnected || state.isScanning || vehicleId.trim().isEmpty) {
      return;
    }
    _update(_state.copyWith(isScanning: true, clearError: true, clearNotice: true, clearLastClearResult: true));
    try {
      final result = await scanFaultsUseCase.execute(vehicleId);
      _update(
        _state.copyWith(
          isScanning: false,
          freezeFrame: result.freezeFrame,
          clearFreezeFrame: result.freezeFrame == null,
          notice: result.isClean ? UiText.resource((s) => s.diagFaultsScanClean) : null,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isScanning: false, error: toDiagnosticsUiText(e)));
    }
  }

  void openClearConfirm() {
    final state = _state;
    if (!state.canResolveFaults || !state.isBluetoothConnected || state.isClearing) return;
    _update(_state.copyWith(confirmClearOpen: true, clearError: true));
  }

  void dismissClearConfirm() {
    if (_state.isClearing) return;
    _update(_state.copyWith(confirmClearOpen: false));
  }

  Future<void> confirmClearDtcs() async {
    final state = _state;
    if (!state.canResolveFaults || !state.isBluetoothConnected || state.isClearing || vehicleId.trim().isEmpty) {
      return;
    }
    _update(_state.copyWith(isClearing: true, clearError: true, clearNotice: true));
    try {
      final result = await clearFaultsUseCase.execute(vehicleId);
      final cleared = result.cleared.length;
      final persistent = result.persistent.length;
      final notice = result.isClean
          ? UiText.resource((s) => s.diagFaultsClearResultClean(cleared))
          : UiText.resource((s) => s.diagFaultsClearResultPersistent(cleared, persistent));
      _update(
        _state.copyWith(
          isClearing: false,
          confirmClearOpen: false,
          lastClearResult: result,
          clearFreezeFrame: result.isClean,
          notice: notice,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isClearing: false, error: toDiagnosticsUiText(e)));
    }
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
