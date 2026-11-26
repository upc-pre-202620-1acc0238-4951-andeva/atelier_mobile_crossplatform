import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Series fiscales de la sede (US42, `invoicing:fiscal_config:manage`). La emisión la hace el PSE administrado por
/// la plataforma: aquí solo se configura la numeración. Todo es en línea; una serie repetida la rechaza el backend
/// (409) y su mensaje se muestra tal cual en la hoja (E2).
class FiscalSeriesViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final GetBranchSeriesUseCase getBranchSeries;
  final ConfigureSeriesUseCase configureSeries;
  final SetSeriesActiveUseCase setSeriesActive;
  final ConnectivityObserver connectivity;

  FiscalSeriesViewModel({
    required this.observeSession,
    required this.getBranchSeries,
    required this.configureSeries,
    required this.setSeriesActive,
    required this.connectivity,
  }) {
    _subscription = observeSession.execute().listen(
      (session) => _update(
        _state.copyWith(
          canManage: session?.has(Permission.fiscalConfigManage) ?? false,
        ),
      ),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  FiscalSeriesUiState _state = const FiscalSeriesUiState();
  FiscalSeriesUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.series.isEmpty;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final series = await getBranchSeries.execute();
      _update(_state.copyWith(series: _sorted(series), isLoading: false));
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, error: toCashierText(e)));
    }
  }

  /// Facturas antes que boletas; dentro de cada tipo, por serie.
  static List<FiscalSeries> _sorted(List<FiscalSeries> series) {
    final copy = [...series];
    copy.sort((a, b) {
      final byType = (a.type?.index ?? 99).compareTo(b.type?.index ?? 99);
      return byType != 0 ? byType : a.serie.compareTo(b.serie);
    });
    return copy;
  }

  // ---- Agregar serie (E1 / E2)

  void onOpenSheet() => _update(
    _state.copyWith(
      showSheet: true,
      type: VoucherType.factura,
      serie: '',
      initialCorrelative: '',
      clearFieldErrors: true,
      clearFormError: true,
      clearBanner: true,
    ),
  );

  void onDismissSheet() {
    if (!_state.showSheet || _state.isSaving) return;
    _update(_state.copyWith(showSheet: false, clearFormError: true));
  }

  void onTypeChange(VoucherType type) => _update(
    _state.copyWith(type: type, clearFieldErrors: true, clearFormError: true),
  );

  void onSerieChange(String value) => _update(
    _state.copyWith(
      serie: value.toUpperCase(),
      clearFieldErrors: true,
      clearFormError: true,
    ),
  );

  void onInitialChange(String value) => _update(
    _state.copyWith(
      initialCorrelative: value,
      clearFieldErrors: true,
      clearFormError: true,
    ),
  );

  Future<void> onConfirm() async {
    final state = _state;
    if (state.isSaving || !state.isOnline) return;
    final serie = state.serie.trim();
    final initialText = state.initialCorrelative.trim();
    final initial = initialText.isEmpty ? null : int.tryParse(initialText);
    final serieInvalid = !CashierValidation.isSeriesFor(state.type, serie);
    final initialInvalid =
        initialText.isNotEmpty && (initial == null || initial < 0);
    if (serieInvalid || initialInvalid) {
      _update(
        _state.copyWith(
          clearFieldErrors: true,
          serieError: serieInvalid
              ? UiText.resource((s) => s.cashierErrSerie)
              : null,
          initialError: initialInvalid
              ? UiText.resource((s) => s.cashierErrInitial)
              : null,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(
      _state.copyWith(
        isSaving: true,
        clearFieldErrors: true,
        clearFormError: true,
      ),
    );
    try {
      final created = await configureSeries.execute(
        state.type,
        serie,
        initialCorrelative: initial,
      );
      _update(
        _state.copyWith(
          isSaving: false,
          showSheet: false,
          banner: UiText.resource(
            (s) => s.fiscalSeriesCreatedOk(
              created.serie,
              voucherTypeLabel(s, created.type ?? state.type),
            ),
          ),
          clearActionError: true,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      await refresh();
    } on Object catch (e) {
      // 409 (serie repetida, E2) y demás: el `message` del backend se muestra tal cual.
      _update(
        _state.copyWith(
          isSaving: false,
          formError: toCashierText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  // ---- Activar / desactivar

  Future<void> onToggleActive(FiscalSeries series) async {
    if (_state.togglingId != null || !_state.isOnline) return;
    _update(
      _state.copyWith(
        togglingId: series.id,
        clearActionError: true,
        clearBanner: true,
      ),
    );
    try {
      await setSeriesActive.execute(series.id, !series.active);
      _update(
        _state.copyWith(
          clearTogglingId: true,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      await refresh();
    } on Object catch (e) {
      _update(
        _state.copyWith(
          clearTogglingId: true,
          actionError: toCashierText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void _update(FiscalSeriesUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
