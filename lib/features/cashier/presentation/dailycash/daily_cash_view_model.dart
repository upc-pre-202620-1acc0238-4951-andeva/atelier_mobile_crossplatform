import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

class DailyCashViewModel extends ChangeNotifier {
  final GetDailyCashSummaryUseCase getDailyCashSummary;
  final ObserveSessionUseCase observeSession;
  final ConnectivityObserver connectivity;

  DailyCashViewModel({
    required this.getDailyCashSummary,
    required this.observeSession,
    required this.connectivity,
    DateTime Function()? now,
  }) {
    final today = BusinessTime.limaDate((now ?? DateTime.now)());
    _state = DailyCashUiState(today: today, date: today, isOnline: connectivity.isOnline);
    _subscription = observeSession.execute().listen(
      (session) => _update(_state.copyWith(canRead: session?.has(Permission.invoicesRead) ?? false)),
    );
    connectivity.addListener(_onConnectivity);
    load();
  }

  late DailyCashUiState _state;
  DailyCashUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  int _loadSeq = 0;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.summary == null;
    _update(_state.copyWith(isOnline: online));
    if (retry) load();
  }

  /// Carga el día vigente. Una carga nueva descarta la respuesta de la anterior.
  Future<void> load() async {
    final date = _state.date;
    final seq = ++_loadSeq;
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final summary = await getDailyCashSummary.execute(date);
      if (seq != _loadSeq) return;
      _update(_state.copyWith(summary: summary, isLoading: false));
    } on Object catch (e) {
      if (seq != _loadSeq) return;
      _update(_state.copyWith(clearSummary: true, isLoading: false, error: toCashierText(e)));
    }
  }

  void onPreviousDay() => _goTo(BusinessTime.addDays(_state.date, -1));

  void onNextDay() {
    if (_state.canGoNext) _goTo(BusinessTime.addDays(_state.date, 1));
  }

  void onToday() => _goTo(_state.today);

  void _goTo(String date) {
    _update(_state.copyWith(date: date, clearSummary: true));
    load();
  }

  void _update(DailyCashUiState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    connectivity.removeListener(_onConnectivity);
    super.dispose();
  }
}
