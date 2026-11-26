import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Series de comprobantes de la sede (US42) y el formulario para agregar una.
class FiscalSeriesUiState {
  final List<FiscalSeries> series;
  final bool isLoading;
  final bool isOnline;
  final bool canManage;
  final UiText? error;
  final UiText? banner;
  final UiText? actionError;

  /// Id de la serie que se activa o desactiva en este momento.
  final String? togglingId;

  // Hoja "Agregar serie"
  final bool showSheet;
  final VoucherType type;
  final String serie;
  final String initialCorrelative;
  final UiText? serieError;
  final UiText? initialError;
  final UiText? formError;
  final bool isSaving;
  final int hapticEvent;
  final bool hapticIsError;

  const FiscalSeriesUiState({
    this.series = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.canManage = true,
    this.error,
    this.banner,
    this.actionError,
    this.togglingId,
    this.showSheet = false,
    this.type = VoucherType.factura,
    this.serie = '',
    this.initialCorrelative = '',
    this.serieError,
    this.initialError,
    this.formError,
    this.isSaving = false,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  /// Solo se configuran facturas y boletas; las notas de crédito salen de otra numeración.
  static const configurableTypes = [VoucherType.factura, VoucherType.boleta];

  FiscalSeriesUiState copyWith({
    List<FiscalSeries>? series,
    bool? isLoading,
    bool? isOnline,
    bool? canManage,
    UiText? error,
    bool clearError = false,
    UiText? banner,
    bool clearBanner = false,
    UiText? actionError,
    bool clearActionError = false,
    String? togglingId,
    bool clearTogglingId = false,
    bool? showSheet,
    VoucherType? type,
    String? serie,
    String? initialCorrelative,
    UiText? serieError,
    UiText? initialError,
    bool clearFieldErrors = false,
    UiText? formError,
    bool clearFormError = false,
    bool? isSaving,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return FiscalSeriesUiState(
      series: series ?? this.series,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      canManage: canManage ?? this.canManage,
      error: clearError ? null : error ?? this.error,
      banner: clearBanner ? null : banner ?? this.banner,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      togglingId: clearTogglingId ? null : togglingId ?? this.togglingId,
      showSheet: showSheet ?? this.showSheet,
      type: type ?? this.type,
      serie: serie ?? this.serie,
      initialCorrelative: initialCorrelative ?? this.initialCorrelative,
      serieError: clearFieldErrors ? null : serieError ?? this.serieError,
      initialError: clearFieldErrors ? null : initialError ?? this.initialError,
      formError: clearFormError ? null : formError ?? this.formError,
      isSaving: isSaving ?? this.isSaving,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
