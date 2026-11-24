import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_inventory_valuation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Valorización del inventario (`GET /inventory/items/valuation`, `inventory:batches:read`): una cifra en soles.
/// En línea: sin red no se calcula. El desglose sale de las existencias de la caché, no de valores en soles.
class InventoryValuationViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObservePartsCatalogUseCase observeCatalog;
  final GetInventoryValuationUseCase getValuation;
  final ConnectivityObserver connectivity;

  InventoryValuationViewModel({
    required this.observeSession,
    required this.observeCatalog,
    required this.getValuation,
    required this.connectivity,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(_state.copyWith(canRead: session?.has(Permission.batchesRead) ?? false)),
      ),
    );
    _subscriptions.add(
      observeCatalog.execute().listen((parts) => _update(_state.copyWith(parts: parts))),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  InventoryValuationUiState _state = const InventoryValuationUiState();
  InventoryValuationUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.valuation == null;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final valuation = await getValuation.execute();
      _update(_state.copyWith(valuation: valuation.total, isLoading: false));
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  void _update(InventoryValuationUiState state) {
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
