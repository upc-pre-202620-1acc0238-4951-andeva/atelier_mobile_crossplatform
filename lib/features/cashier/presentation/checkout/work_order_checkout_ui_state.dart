import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_forms.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:decimal/decimal.dart';

const _keep = Object();

/// Qué acción fiscal está en vuelo en checkout (US37); deshabilita las demás y pone el botón en carga.
enum CheckoutAction {
  preparing,
  issuing,
  voiding,
  issuingCreditNote,
  refreshingSunat,
  downloadingDocument,
}

enum CheckoutDocumentActionMode { open, share }

class PendingDocumentFile {
  final File file;
  final String mimeType;
  final CheckoutDocumentActionMode mode;

  const PendingDocumentFile({
    required this.file,
    required this.mimeType,
    required this.mode,
  });
}

/// Lo que muestra la pantalla de un comprobante, venga de la red (con IGV desglosado) o de la caché Drift.
class VoucherView {
  final String id;
  final VoucherType? type;
  final String serie;
  final int number;
  final String? currency;
  final Decimal? subtotal;
  final Decimal? igv;
  final Decimal total;
  final Decimal paid;
  final Decimal pending;
  final VoucherPaymentStatus? paymentStatus;
  final VoucherStatus? status;
  final bool isActiveSale;
  final String? pdfUrl;
  final String? xmlUrl;
  final String? cdrUrl;
  final String? sunatResponseCode;
  final String? sunatDescription;

  const VoucherView({
    required this.id,
    this.type,
    required this.serie,
    required this.number,
    this.currency,
    this.subtotal,
    this.igv,
    required this.total,
    required this.paid,
    required this.pending,
    this.paymentStatus,
    this.status,
    required this.isActiveSale,
    this.pdfUrl,
    this.xmlUrl,
    this.cdrUrl,
    this.sunatResponseCode,
    this.sunatDescription,
  });

  bool get canVoidOrCreditNote => isActiveSale && status != VoucherStatus.draft;

  factory VoucherView.fromVoucher(Voucher voucher) => VoucherView(
    id: voucher.id,
    type: voucher.type,
    serie: voucher.serie,
    number: voucher.number,
    currency: voucher.currency,
    subtotal: voucher.subtotal.amount,
    igv: voucher.igvAmount.amount,
    total: voucher.totalAmount.amount,
    paid: voucher.paidAmount.amount,
    pending: voucher.pendingBalance.amount,
    paymentStatus: voucher.paymentStatus,
    status: voucher.status,
    isActiveSale: voucher.activeSale,
    pdfUrl: voucher.pdfUrl,
    xmlUrl: voucher.xmlUrl,
    cdrUrl: voucher.cdrUrl,
    sunatResponseCode: voucher.sunatResponseCode,
    sunatDescription: voucher.sunatDescription,
  );

  factory VoucherView.fromSummary(VoucherSummary summary) => VoucherView(
    id: summary.id,
    type: summary.type,
    serie: summary.serie,
    number: summary.number,
    total: summary.totalAmount,
    paid: summary.paidAmount,
    pending: summary.pendingBalance,
    paymentStatus: summary.paymentStatus,
    status: summary.status,
    isActiveSale: summary.activeSale,
    pdfUrl: summary.pdfUrl,
  );
}

/// Comprobante en edición antes de emitir (US37).
class IssueForm {
  final VoucherDraft base;
  final VoucherType type;
  final FiscalDocumentType documentType;
  final String taxId;
  final String legalName;
  final String address;
  final List<VoucherLineDraft> lines;

  const IssueForm({
    required this.base,
    required this.type,
    required this.documentType,
    required this.taxId,
    required this.legalName,
    required this.address,
    required this.lines,
  });

  bool get isCompany => type == VoucherType.factura;

  VoucherDraft toDraft() {
    final trimmedAddress = address.trim();
    return base.copyWith(
      type: type,
      customerInfo: CustomerFiscalInfo(
        documentType: documentType,
        taxId: taxId.trim(),
        legalName: legalName.trim(),
        fiscalAddress: trimmedAddress.isEmpty ? null : trimmedAddress,
      ),
      lines: lines,
    );
  }

  Decimal get total => toDraft().total;

  /// El total lleva IGV: la base imponible es total / 1.18 y el IGV, la diferencia.
  Decimal get subtotal =>
      (total / CashierValidation.igvFactor).toDecimal(scaleOnInfinitePrecision: 2).round(scale: 2);

  Decimal get igv => total - subtotal;

  bool get taxIdValid {
    final id = taxId.trim();
    return switch (documentType) {
      FiscalDocumentType.ruc => CashierValidation.isRuc(id),
      FiscalDocumentType.dni => CashierValidation.isDni(id),
      FiscalDocumentType.ce || FiscalDocumentType.pasaporte => id.length >= 4 && id.length <= 20,
    };
  }

  bool get nameValid => legalName.trim().isNotEmpty;
  bool get linesValid => lines.every((line) => !line.needsDescription);
  bool get canSubmit => taxIdValid && nameValid && linesValid;

  IssueForm withType(VoucherType newType) => copyWith(
    type: newType,
    documentType: switch ((newType, documentType)) {
      (VoucherType.factura, _) => FiscalDocumentType.ruc,
      (_, FiscalDocumentType.ruc) => FiscalDocumentType.dni,
      _ => documentType,
    },
  );

  IssueForm copyWith({
    VoucherType? type,
    FiscalDocumentType? documentType,
    String? taxId,
    String? legalName,
    String? address,
    List<VoucherLineDraft>? lines,
  }) => IssueForm(
    base: base,
    type: type ?? this.type,
    documentType: documentType ?? this.documentType,
    taxId: taxId ?? this.taxId,
    legalName: legalName ?? this.legalName,
    address: address ?? this.address,
    lines: lines ?? this.lines,
  );
}

sealed class CheckoutSheet {
  const CheckoutSheet();
}

class IssueCheckoutSheet extends CheckoutSheet {
  final IssueForm form;

  const IssueCheckoutSheet(this.form);
}

class VoidCheckoutSheet extends CheckoutSheet {
  final VoucherView voucher;
  final VoidForm form;

  const VoidCheckoutSheet({required this.voucher, required this.form});
}

class CreditNoteCheckoutSheet extends CheckoutSheet {
  final VoucherView voucher;
  final CreditNoteForm form;

  const CreditNoteCheckoutSheet({required this.voucher, required this.form});
}

/// Estado de emisión y gestión de comprobantes SUNAT de una orden (US37).
/// Sin pasos de cobro (US38) ni pase de salida/entrega (US39).
class WorkOrderCheckoutUiState {
  final String workOrderId;
  final WorkOrder? order;
  final List<VoucherSummary> cachedVouchers;
  final List<Voucher>? liveVouchers;
  final bool hasLoaded;
  final bool isRefreshing;
  final bool isOnline;
  final UiText? error;
  final CheckoutSheet? sheet;
  final CheckoutAction? busy;
  final UiText? sheetError;
  final UiText? actionError;
  final UiText? notice;
  final PendingDocumentFile? pendingDocument;
  final bool canReadInvoices;
  final bool canIssueVoucher;

  const WorkOrderCheckoutUiState({
    required this.workOrderId,
    this.order,
    this.cachedVouchers = const [],
    this.liveVouchers,
    this.hasLoaded = false,
    this.isRefreshing = false,
    this.isOnline = true,
    this.error,
    this.sheet,
    this.busy,
    this.sheetError,
    this.actionError,
    this.notice,
    this.pendingDocument,
    this.canReadInvoices = false,
    this.canIssueVoucher = false,
  });

  List<VoucherView> get vouchers => liveVouchers != null
      ? [for (final v in liveVouchers!) VoucherView.fromVoucher(v)]
      : [for (final s in cachedVouchers) VoucherView.fromSummary(s)];

  VoucherView? get activeVoucher {
    for (final v in vouchers) {
      if (v.isActiveSale) return v;
    }
    return null;
  }

  bool get hasRejectedVoucherWithoutActive =>
      activeVoucher == null && vouchers.any((v) => v.status == VoucherStatus.rejectedSunat);

  /// H26: diferencia por redondeo o IGV por línea entre el estimado de la orden y el total fiscal.
  bool get hasDifferentialCascadeNote {
    final orderTotal = order?.totalAmount?.amount;
    final voucherTotal = activeVoucher?.total;
    if (orderTotal == null || voucherTotal == null) return false;
    return voucherTotal != orderTotal;
  }

  bool get isCompleted => order?.status == WorkOrderStatus.completed;
  bool get isOrderPaid => order?.status == WorkOrderStatus.paid;
  bool get hasAnyAccess => canReadInvoices || canIssueVoucher;
  bool get showSkeleton => !hasLoaded && vouchers.isEmpty && error == null;

  WorkOrderCheckoutUiState copyWith({
    Object? order = _keep,
    List<VoucherSummary>? cachedVouchers,
    Object? liveVouchers = _keep,
    bool? hasLoaded,
    bool? isRefreshing,
    bool? isOnline,
    Object? error = _keep,
    Object? sheet = _keep,
    Object? busy = _keep,
    Object? sheetError = _keep,
    Object? actionError = _keep,
    Object? notice = _keep,
    Object? pendingDocument = _keep,
    bool? canReadInvoices,
    bool? canIssueVoucher,
  }) => WorkOrderCheckoutUiState(
    workOrderId: workOrderId,
    order: identical(order, _keep) ? this.order : order as WorkOrder?,
    cachedVouchers: cachedVouchers ?? this.cachedVouchers,
    liveVouchers: identical(liveVouchers, _keep)
        ? this.liveVouchers
        : liveVouchers as List<Voucher>?,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isOnline: isOnline ?? this.isOnline,
    error: identical(error, _keep) ? this.error : error as UiText?,
    sheet: identical(sheet, _keep) ? this.sheet : sheet as CheckoutSheet?,
    busy: identical(busy, _keep) ? this.busy : busy as CheckoutAction?,
    sheetError: identical(sheetError, _keep) ? this.sheetError : sheetError as UiText?,
    actionError: identical(actionError, _keep) ? this.actionError : actionError as UiText?,
    notice: identical(notice, _keep) ? this.notice : notice as UiText?,
    pendingDocument: identical(pendingDocument, _keep)
        ? this.pendingDocument
        : pendingDocument as PendingDocumentFile?,
    canReadInvoices: canReadInvoices ?? this.canReadInvoices,
    canIssueVoucher: canIssueVoucher ?? this.canIssueVoucher,
  );
}
