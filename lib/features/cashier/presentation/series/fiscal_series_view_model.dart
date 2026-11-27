import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_tenant_fiscal_profile_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/update_tenant_fiscal_profile_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// Series de comprobantes de la sede y datos fiscales del taller (US42). La emisión la hace el PSE administrado por
/// la plataforma: aquí se configura la numeración (`invoicing:fiscal_config:manage`) y se lee o edita el perfil fiscal
/// (`iam:tenants:read` / `iam:tenants:update`). Todo es en línea; una serie repetida la rechaza el backend (409) y su
/// mensaje se muestra tal cual en la hoja (E2).
class FiscalSeriesViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final GetBranchSeriesUseCase getBranchSeries;
  final ConfigureSeriesUseCase configureSeries;
  final SetSeriesActiveUseCase setSeriesActive;
  final ConnectivityObserver connectivity;
  final GetTenantFiscalProfileUseCase? getTenantFiscalProfile;
  final UpdateTenantFiscalProfileUseCase? updateTenantFiscalProfile;

  FiscalSeriesViewModel({
    required this.observeSession,
    required this.getBranchSeries,
    required this.configureSeries,
    required this.setSeriesActive,
    required this.connectivity,
    this.getTenantFiscalProfile,
    this.updateTenantFiscalProfile,
  }) {
    _subscription = observeSession.execute().listen(_onSession);
    _state = FiscalSeriesUiState(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  late FiscalSeriesUiState _state;
  FiscalSeriesUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onSession(Session? session) {
    _update(
      _state.copyWith(
        canManage: session?.has(Permission.fiscalConfigManage) ?? false,
        canReadTenant: session?.has(Permission.tenantsRead) ?? false,
        canUpdateTenant: session?.has(Permission.tenantsUpdate) ?? false,
      ),
    );
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.series.isEmpty && _state.tenantProfile == null;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    await _load();
  }

  Future<void> _load() async {
    Session? session;
    try {
      session = await observeSession.execute().first;
    } on Object {
      session = null;
    }
    final canManage = (session?.has(Permission.fiscalConfigManage) ?? false) || _state.canManage;
    final canReadTenant =
        (session?.has(Permission.tenantsRead) ?? false) ||
        (session?.has(Permission.tenantsUpdate) ?? false) ||
        _state.canReadTenant ||
        _state.canUpdateTenant;

    Object? failure;
    final tenantLoader = getTenantFiscalProfile;
    if (canReadTenant && tenantLoader != null) {
      try {
        final profile = await tenantLoader.execute();
        _update(_state.copyWith(tenantProfile: profile));
      } on Object catch (e) {
        failure = e;
      }
    }
    if (canManage || session == null) {
      try {
        final series = await getBranchSeries.execute();
        _update(_state.copyWith(series: _sorted(series)));
      } on Object catch (e) {
        failure ??= e;
      }
    }
    _update(
      _state.copyWith(
        hasLoaded: true,
        isRefreshing: false,
        error: failure == null ? null : toCashierText(failure),
        clearError: failure == null,
      ),
    );
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

  // ---- Datos fiscales del taller

  void onEditTenant() {
    if (!_state.canUpdateTenant) return;
    final profile = _state.tenantProfile;
    final name = profile?.name ?? '';
    final legalName = profile?.legalName ?? '';
    _update(
      _state.copyWith(
        sheet: EditTenantSheet(
          TenantProfileForm(
            name: name,
            legalName: legalName.trim().isEmpty ? name : legalName,
            taxId: profile?.taxId ?? '',
          ),
        ),
        clearSheetError: true,
        clearNotice: true,
      ),
    );
  }

  void onTenantName(String value) =>
      _updateTenantForm((form) => form.copyWith(name: value.length > 100 ? value.substring(0, 100) : value));

  void onTenantLegalName(String value) =>
      _updateTenantForm((form) => form.copyWith(legalName: value.length > 150 ? value.substring(0, 150) : value));

  void _updateTenantForm(TenantProfileForm Function(TenantProfileForm form) change) {
    final sheet = _state.sheet;
    if (sheet is! EditTenantSheet) return;
    _update(_state.copyWith(sheet: EditTenantSheet(change(sheet.form)), clearSheetError: true));
  }

  Future<void> onSaveTenant() async {
    final state = _state;
    final sheet = state.sheet;
    final updater = updateTenantFiscalProfile;
    if (sheet is! EditTenantSheet || updater == null) return;
    final form = sheet.form;
    if (!state.canUpdateTenant || !form.canSubmit || !state.isOnline || state.isSaving) return;
    _update(_state.copyWith(isSaving: true, clearSheetError: true));
    try {
      final updated = await updater.execute(form.name, form.legalName);
      _update(
        _state.copyWith(
          tenantProfile: updated,
          clearSheet: true,
          notice: UiText.resource((s) => s.cashierFiscalTenantSaved),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e), hapticEvent: _state.hapticEvent + 1, hapticIsError: true));
    }
    _update(_state.copyWith(isSaving: false));
  }

  // ---- Series (E1 / E2)

  void onAdd() {
    if (!_state.canManage) return;
    _update(
      _state.copyWith(sheet: const CreateSeriesSheet(SeriesForm()), clearSheetError: true, clearNotice: true),
    );
  }

  void onOpenSeries(FiscalSeries series) {
    if (!_state.canManage) return;
    _update(_state.copyWith(sheet: SeriesDetailSheet(series), clearSheetError: true, clearNotice: true));
  }

  void onType(VoucherType type) => _updateForm((form) => form.copyWith(type: type));

  void onSerie(String value) {
    final cleaned = value.replaceAll(RegExp('[^A-Za-z0-9]'), '').toUpperCase();
    _updateForm((form) => form.copyWith(serie: cleaned.length > 4 ? cleaned.substring(0, 4) : cleaned));
  }

  void onInitial(String value) {
    final digits = value.replaceAll(RegExp('[^0-9]'), '');
    _updateForm((form) => form.copyWith(initial: digits.length > 9 ? digits.substring(0, 9) : digits));
  }

  void _updateForm(SeriesForm Function(SeriesForm form) change) {
    final sheet = _state.sheet;
    if (sheet is! CreateSeriesSheet) return;
    _update(_state.copyWith(sheet: CreateSeriesSheet(change(sheet.form)), clearSheetError: true));
  }

  Future<void> onSave() async {
    final state = _state;
    final sheet = state.sheet;
    if (sheet is! CreateSeriesSheet) return;
    final form = sheet.form;
    if (!form.canSubmit || !state.isOnline || state.isSaving) return;
    _update(_state.copyWith(isSaving: true, clearSheetError: true));
    try {
      await configureSeries.execute(form.type, form.serie, initialCorrelative: form.initialCorrelative);
      _update(
        _state.copyWith(
          clearSheet: true,
          notice: UiText.resource((s) => s.cashierSeriesSaved),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      await _load();
    } on Object catch (e) {
      // 409 (serie repetida, E2) y demás: el `message` del backend se muestra tal cual.
      _update(_state.copyWith(sheetError: toCashierText(e), hapticEvent: _state.hapticEvent + 1, hapticIsError: true));
    }
    _update(_state.copyWith(isSaving: false));
  }

  Future<void> onToggleActive() async {
    final state = _state;
    final sheet = state.sheet;
    if (sheet is! SeriesDetailSheet || !state.isOnline || state.isSaving) return;
    final series = sheet.series;
    _update(_state.copyWith(isSaving: true, clearSheetError: true));
    try {
      await setSeriesActive.execute(series.id, !series.active);
      _update(
        _state.copyWith(
          clearSheet: true,
          notice: UiText.resource((s) => s.cashierSeriesUpdated),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e), hapticEvent: _state.hapticEvent + 1, hapticIsError: true));
    }
    _update(_state.copyWith(isSaving: false));
  }

  void onDismissSheet() {
    if (_state.isSaving || _state.sheet == null) return;
    _update(_state.copyWith(clearSheet: true, clearSheetError: true));
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
