import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:flutter/foundation.dart';

/// Pestañas, acción principal y contador de pendientes de la barra flotante. Todo sale de la sesión:
/// por permiso, nunca por rol.
class MainViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSessionUseCase;
  final ObservePendingOperationCountUseCase observePendingCountUseCase;

  /// [initialSession] evita un cuadro sin pestañas mientras llega la primera emisión de la sesión.
  MainViewModel({
    required this.observeSessionUseCase,
    required this.observePendingCountUseCase,
    Session? initialSession,
  }) {
    if (initialSession != null) _state = _fromSession(initialSession, _state);
    _sessionSubscription = observeSessionUseCase.execute().listen(
      (session) => _update(_fromSession(session, _state)),
    );
    _pendingSubscription = observePendingCountUseCase.execute().listen(
      (count) => _update(_state.copyWith(pendingCount: count)),
    );
  }

  late final StreamSubscription<Session?> _sessionSubscription;
  late final StreamSubscription<int> _pendingSubscription;
  bool _disposed = false;

  MainUiState _state = const MainUiState();
  MainUiState get state => _state;

  /// Cambia de pestaña. Una que no está en la barra no hace nada.
  void select(MainTab tab) {
    if (!_state.tabs.contains(tab) || _state.selected == tab) return;
    _update(_state.copyWith(selected: tab));
  }

  /// Conserva la pestaña a la vista mientras siga en la barra; si ya no, vuelve a la primera (el inicio).
  static MainUiState _fromSession(Session? session, MainUiState previous) {
    if (session == null) {
      return previous.copyWith(
        clearSession: true,
        tabs: const [],
        clearSelected: true,
        primaryAction: BarPrimaryAction.none,
      );
    }
    final tabs = MainTab.tabsFor(session);
    final keep = previous.selected != null && tabs.contains(previous.selected) ? previous.selected : null;
    return previous.copyWith(
      session: session,
      tabs: tabs,
      selected: keep ?? (tabs.isEmpty ? null : tabs.first),
      clearSelected: keep == null && tabs.isEmpty,
      showModules: MainTab.hasModules(session),
      primaryAction: BarPrimaryAction.forSession(session),
    );
  }

  void _update(MainUiState state) {
    if (_disposed) return; // Una emisión puede llegar con la pantalla ya cerrada.
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_sessionSubscription.cancel());
    unawaited(_pendingSubscription.cancel());
    super.dispose();
  }
}
