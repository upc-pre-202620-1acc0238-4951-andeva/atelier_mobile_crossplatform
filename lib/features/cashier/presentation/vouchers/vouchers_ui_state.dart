import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_forms.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:decimal/decimal.dart';

const _keep = Object();

/// Filtros de la lista de comprobantes emitidos (US37).
enum VoucherFilter { all, accepted, withBalance, voided, creditNotes }

sealed class VoucherSheet {
  const VoucherSheet();
}

class VoucherDetailSheet extends VoucherSheet {
  final Voucher voucher;

  const VoucherDetailSheet(this.voucher);
}

class VoucherVoidSheet extends VoucherSheet {
  final Voucher voucher;
  final VoidForm form;

  const VoucherVoidSheet({required this.voucher, required this.form});
}

class VoucherCreditNoteSheet extends VoucherSheet {
  final Voucher voucher;
  final CreditNoteForm form;

  const VoucherCreditNoteSheet({required this.voucher, required this.form});
}

/// Comprobantes SUNAT emitidos en la sede: boletas, facturas y notas de crédito.
class VouchersUiState {
  final List<Voucher> vouchers;
  final VoucherFilter filter;
  final bool hasLoaded;
  final bool isRefreshing;
  final bool isOnline;
  final UiText? error;
  final bool canRead;
  final bool canIssueSunat;
  final VoucherSheet? sheet;
  final bool isSubmitting;
  final bool isRefreshingSunat;
  final bool isDownloadingDocument;
  final PendingDocumentFile? pendingDocument;
  final UiText? sheetError;
  final UiText? notice;

  const VouchersUiState({
    this.vouchers = const [],
    this.filter = VoucherFilter.all,
    this.hasLoaded = false,
    this.isRefreshing = false,
    this.isOnline = true,
    this.error,
    this.canRead = false,
    this.canIssueSunat = false,
    this.sheet,
    this.isSubmitting = false,
    this.isRefreshingSunat = false,
    this.isDownloadingDocument = false,
    this.pendingDocument,
    this.sheetError,
    this.notice,
  });

  bool get showSkeleton => !hasLoaded && vouchers.isEmpty && error == null;

  List<Voucher> get filteredVouchers => switch (filter) {
    VoucherFilter.all => vouchers,
    VoucherFilter.accepted => vouchers
        .where(
          (v) => v.status == VoucherStatus.acceptedSunat || v.status == VoucherStatus.issued,
        )
        .toList(),
    VoucherFilter.withBalance => vouchers
        .where((v) => v.activeSale && v.pendingBalance.amount > Decimal.zero)
        .toList(),
    VoucherFilter.voided => vouchers.where((v) => v.status == VoucherStatus.voided).toList(),
    VoucherFilter.creditNotes =>
      vouchers.where((v) => v.type == VoucherType.notaCredito).toList(),
  };

  VouchersUiState copyWith({
    List<Voucher>? vouchers,
    VoucherFilter? filter,
    bool? hasLoaded,
    bool? isRefreshing,
    bool? isOnline,
    Object? error = _keep,
    bool? canRead,
    bool? canIssueSunat,
    Object? sheet = _keep,
    bool? isSubmitting,
    bool? isRefreshingSunat,
    bool? isDownloadingDocument,
    Object? pendingDocument = _keep,
    Object? sheetError = _keep,
    Object? notice = _keep,
  }) => VouchersUiState(
    vouchers: vouchers ?? this.vouchers,
    filter: filter ?? this.filter,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isOnline: isOnline ?? this.isOnline,
    error: identical(error, _keep) ? this.error : error as UiText?,
    canRead: canRead ?? this.canRead,
    canIssueSunat: canIssueSunat ?? this.canIssueSunat,
    sheet: identical(sheet, _keep) ? this.sheet : sheet as VoucherSheet?,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isRefreshingSunat: isRefreshingSunat ?? this.isRefreshingSunat,
    isDownloadingDocument: isDownloadingDocument ?? this.isDownloadingDocument,
    pendingDocument: identical(pendingDocument, _keep)
        ? this.pendingDocument
        : pendingDocument as PendingDocumentFile?,
    sheetError: identical(sheetError, _keep) ? this.sheetError : sheetError as UiText?,
    notice: identical(notice, _keep) ? this.notice : notice as UiText?,
  );
}
