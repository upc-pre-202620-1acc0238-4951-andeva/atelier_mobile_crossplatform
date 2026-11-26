import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Serie nueva en edición; [initial] es texto para no perder lo que se escribe.
class SeriesForm {
  final VoucherType type;
  final String serie;
  final String initial;

  const SeriesForm({this.type = VoucherType.boleta, this.serie = '', this.initial = ''});

  bool get serieValid => type == VoucherType.notaCredito
      ? CashierValidation.isCreditNoteSeries(serie)
      : CashierValidation.isSeriesFor(type, serie);

  /// Vacío es válido (el backend parte de 0); si hay texto, un entero no negativo.
  int? get initialCorrelative {
    final value = int.tryParse(initial);
    return value != null && value >= 0 ? value : null;
  }

  bool get initialValid => initial.isEmpty || initialCorrelative != null;

  bool get canSubmit => serieValid && initialValid;

  SeriesForm copyWith({VoucherType? type, String? serie, String? initial}) =>
      SeriesForm(type: type ?? this.type, serie: serie ?? this.serie, initial: initial ?? this.initial);
}

/// Datos fiscales del taller en edición (US42). [taxId] es solo lectura desde el perfil del tenant.
class TenantProfileForm {
  final String name;
  final String legalName;
  final String taxId;

  const TenantProfileForm({this.name = '', this.legalName = '', this.taxId = ''});

  bool get nameValid => name.trim().isNotEmpty && name.trim().length <= CashierValidation.maxTenantNameLength;

  bool get legalNameValid =>
      legalName.trim().isNotEmpty && legalName.trim().length <= CashierValidation.maxTenantLegalNameLength;

  bool get canSubmit => nameValid && legalNameValid;

  TenantProfileForm copyWith({String? name, String? legalName}) =>
      TenantProfileForm(name: name ?? this.name, legalName: legalName ?? this.legalName, taxId: taxId);
}

/// Hoja abierta de la pantalla de series.
sealed class SeriesSheet {
  const SeriesSheet();
}

final class CreateSeriesSheet extends SeriesSheet {
  final SeriesForm form;

  const CreateSeriesSheet(this.form);
}

final class SeriesDetailSheet extends SeriesSheet {
  final FiscalSeries series;

  const SeriesDetailSheet(this.series);
}

final class EditTenantSheet extends SeriesSheet {
  final TenantProfileForm form;

  const EditTenantSheet(this.form);
}

/// Perfil fiscal del taller y series SUNAT de la sede (US42). Solo en línea y sin caché.
class FiscalSeriesUiState {
  final List<FiscalSeries> series;
  final TenantFiscalProfile? tenantProfile;
  final bool hasLoaded;
  final bool isRefreshing;
  final bool isOnline;
  final UiText? error;
  final bool canManage;
  final bool canReadTenant;
  final bool canUpdateTenant;
  final SeriesSheet? sheet;
  final bool isSaving;
  final UiText? sheetError;
  final UiText? notice;

  /// Sube con cada aviso o error de una hoja para disparar la respuesta háptica.
  final int hapticEvent;
  final bool hapticIsError;

  const FiscalSeriesUiState({
    this.series = const [],
    this.tenantProfile,
    this.hasLoaded = false,
    this.isRefreshing = false,
    this.isOnline = true,
    this.error,
    this.canManage = false,
    this.canReadTenant = false,
    this.canUpdateTenant = false,
    this.sheet,
    this.isSaving = false,
    this.sheetError,
    this.notice,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  bool get hasAccess => canManage || canReadTenant || canUpdateTenant;

  bool get showSkeleton => !hasLoaded && series.isEmpty && tenantProfile == null && error == null;

  FiscalSeriesUiState copyWith({
    List<FiscalSeries>? series,
    TenantFiscalProfile? tenantProfile,
    bool? hasLoaded,
    bool? isRefreshing,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canManage,
    bool? canReadTenant,
    bool? canUpdateTenant,
    SeriesSheet? sheet,
    bool clearSheet = false,
    bool? isSaving,
    UiText? sheetError,
    bool clearSheetError = false,
    UiText? notice,
    bool clearNotice = false,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return FiscalSeriesUiState(
      series: series ?? this.series,
      tenantProfile: tenantProfile ?? this.tenantProfile,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canManage: canManage ?? this.canManage,
      canReadTenant: canReadTenant ?? this.canReadTenant,
      canUpdateTenant: canUpdateTenant ?? this.canUpdateTenant,
      sheet: clearSheet ? null : sheet ?? this.sheet,
      isSaving: isSaving ?? this.isSaving,
      sheetError: clearSheetError ? null : sheetError ?? this.sheetError,
      notice: clearNotice ? null : notice ?? this.notice,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
