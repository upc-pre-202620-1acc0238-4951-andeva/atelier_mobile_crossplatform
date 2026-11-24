import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_ui_state.dart';
import 'package:flutter/foundation.dart';

class ReportsViewModel extends ChangeNotifier {
  final GetCashFlowSummaryUseCase getCashFlow;
  final ObserveSessionUseCase observeSession;
  final ConnectivityObserver connectivity;

  ReportsViewModel({
    required this.getCashFlow,
    required this.observeSession,
    required this.connectivity,
    DateTime Function()? now,
  }) {
    final today = BusinessTime.limaDate((now ?? DateTime.now)());
    _state = ReportsUiState(
      today: today,
      choice: PeriodChoice.thisMonth,
      period: periodFor(PeriodChoice.thisMonth, today),
      isOnline: connectivity.isOnline,
    );
    _subscription = observeSession.execute().listen((session) {
      final wasAllowed = _state.canReadCashFlow;
      final canRead = session?.has(Permission.cashflowExportPdf) ?? false;
      _update(_state.copyWith(canReadCashFlow: canRead));
      if (canRead && !wasAllowed) load();
    });
    connectivity.addListener(_onConnectivity);
  }

  late ReportsUiState _state;
  ReportsUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  int _loadSeq = 0;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.canReadCashFlow && _state.summary == null;
    _update(_state.copyWith(isOnline: online));
    if (retry) load();
  }

  /// Carga el periodo vigente. Una carga nueva descarta la respuesta de la anterior.
  Future<void> load() async {
    final period = _state.period;
    final seq = ++_loadSeq;
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final summary = await getCashFlow.execute(period);
      if (seq != _loadSeq) return;
      _update(_state.copyWith(summary: summary, isLoading: false));
    } on Object catch (e) {
      if (seq != _loadSeq) return;
      _update(_state.copyWith(clearSummary: true, isLoading: false, error: toUiText(e)));
    }
  }

  void onChoice(PeriodChoice choice) {
    if (choice == _state.choice && !_state.showCustomRangePicker) return;
    _update(
      _state.copyWith(
        choice: choice,
        period: periodFor(choice, _state.today),
        clearSummary: true,
        showCustomRangePicker: false,
      ),
    );
    load();
  }

  void onOpenCustomRange() => _update(_state.copyWith(showCustomRangePicker: true));

  void onDismissCustomRange() => _update(_state.copyWith(showCustomRangePicker: false));

  /// El selector de rango entrega fechas de calendario (sin hora que importe): se toman año, mes y día tal cual,
  /// sin pasar por zonas horarias. Sin fin elegido, el rango es el día de inicio.
  void onCustomRangePicked(DateTime? start, DateTime? end) {
    if (start == null) return;
    final first = _day(start);
    final second = _day(end ?? start);
    final from = first.compareTo(second) <= 0 ? first : second;
    final to = first.compareTo(second) <= 0 ? second : first;
    onChoice(CustomChoice(from, to));
  }

  static String _day(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-$month-$day';
  }

  void _update(ReportsUiState next) {
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
