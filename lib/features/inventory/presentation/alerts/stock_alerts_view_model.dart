import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Bandeja de alertas de stock mínimo (US34, `inventory:alerts:read`). La lista sale de la caché observada: al
/// recibir una compra el stock sube y la alerta desaparece sola (E2), también sin red.
class StockAlertsViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final GetStockAlertsUseCase getAlerts;
  final ObserveStockAlertsUseCase observeAlerts;
  final ConnectivityObserver connectivity;

  StockAlertsViewModel({
    required this.observeSession,
    required this.getAlerts,
    required this.observeAlerts,
    required this.connectivity,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(
          _state.copyWith(
            canRead: session?.has(Permission.alertsRead) ?? false,
          ),
        ),
      ),
    );
    _subscriptions.add(
      observeAlerts.execute().listen(
        (alerts) => _update(
          _state.copyWith(
            alerts: _sorted(alerts),
            isLoading: false,
            clearError: true,
          ),
        ),
        onError: (Object e) =>
            _update(_state.copyWith(isLoading: false, error: toUiText(e))),
      ),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  StockAlertsUiState _state = const StockAlertsUiState();
  StockAlertsUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  /// Las más urgentes primero: mayor faltante arriba.
  static List<StockAlert> _sorted(List<StockAlert> alerts) {
    final copy = [...alerts];
    copy.sort((a, b) => b.deficit.compareTo(a.deficit));
    return copy;
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final reconnected = online && !_state.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (reconnected) refresh();
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final alerts = await getAlerts.execute();
      _update(_state.copyWith(alerts: _sorted(alerts), isLoading: false));
    } on Object catch (e) {
      // Con alertas de la caché a la vista no se tapa la lista con un error.
      _update(
        _state.copyWith(
          isLoading: false,
          error: _state.alerts.isEmpty ? toUiText(e) : null,
        ),
      );
    }
  }

  void _update(StockAlertsUiState state) {
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
