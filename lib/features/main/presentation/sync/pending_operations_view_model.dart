import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/discard_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operations_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/retry_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/sync_now_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_ui_state.dart';
import 'package:flutter/foundation.dart';

class PendingOperationsViewModel extends ChangeNotifier {
  final ObservePendingOperationsUseCase observeOperations;
  final RetryPendingOperationUseCase retryOperation;
  final DiscardPendingOperationUseCase discardOperation;
  final SyncNowUseCase syncNow;
  final ConnectivityObserver connectivity;

  PendingOperationsViewModel({
    required this.observeOperations,
    required this.retryOperation,
    required this.discardOperation,
    required this.syncNow,
    required this.connectivity,
  }) {
    _state = PendingOperationsUiState(isOnline: connectivity.isOnline);
    _subscription = observeOperations.execute().listen(
      (operations) => _update(
        PendingOperationsUiState(
          operations: operations,
          isOnline: _state.isOnline,
          isSyncingNow: false,
          hasLoaded: true,
          notice: _state.notice,
        ),
      ),
    );
    connectivity.addListener(_onConnectivity);
  }

  late PendingOperationsUiState _state;
  PendingOperationsUiState get state => _state;

  late final StreamSubscription<List<PendingOperation>> _subscription;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  /// Reactiva las que fallaron y pide enviar la cola ya, sin esperar al worker.
  Future<void> onSyncNow() async {
    _update(
      _state.copyWith(
        isSyncingNow: true,
        notice: UiText.resource((strings) => strings.syncRequestedNotice),
      ),
    );
    final failed = _state.operations.where((o) => o.status == PendingOperationStatus.failed);
    for (final operation in failed.toList()) {
      await retryOperation.execute(operation.id);
    }
    await syncNow.execute();
    // Si la cola no cambia (nada que enviar, sin señal), el aviso no puede quedarse para siempre.
    unawaited(
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (_state.isSyncingNow) _update(_state.copyWith(isSyncingNow: false));
      }),
    );
  }

  Future<void> onRetry(String id) async {
    await retryOperation.execute(id);
    await syncNow.execute();
  }

  Future<void> onDiscard(String id) => discardOperation.execute(id);

  void _update(PendingOperationsUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    _subscription.cancel();
    super.dispose();
  }
}
