import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_voucher_document_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_voucher_payments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/refresh_voucher_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_forms.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// "Cobrar y entregar" de una orden: comprobante SUNAT (US37) y cobros multi-medio (US38). Todo en línea y de
/// una acción a la vez (docs/06-offline-sync.md). Sin pase de salida ni entrega (US39).
class WorkOrderCheckoutViewModel extends ChangeNotifier {
  final String workOrderId;
  final ObserveSessionUseCase observeSession;
  final ObserveWorkOrderUseCase observeOrder;
  final GetWorkOrderDetailUseCase getWorkOrderDetail;
  final ObserveWorkOrderVouchersUseCase observeVouchers;
  final GetWorkOrderVouchersUseCase getVouchers;
  final PrepareVoucherUseCase prepareVoucher;
  final IssueVoucherUseCase issueVoucher;
  final VoidVoucherUseCase voidVoucher;
  final IssueCreditNoteUseCase issueCreditNote;
  final GetVoucherPaymentsUseCase getPayments;
  final RegisterPaymentUseCase registerPayment;
  final ConnectivityObserver connectivity;
  final DownloadVoucherDocumentUseCase? downloadVoucherDocument;
  final RefreshVoucherStatusUseCase? refreshVoucherStatus;

  WorkOrderCheckoutViewModel({
    required this.workOrderId,
    required this.observeSession,
    required this.observeOrder,
    required this.getWorkOrderDetail,
    required this.observeVouchers,
    required this.getVouchers,
    required this.prepareVoucher,
    required this.issueVoucher,
    required this.voidVoucher,
    required this.issueCreditNote,
    required this.getPayments,
    required this.registerPayment,
    required this.connectivity,
    this.downloadVoucherDocument,
    this.refreshVoucherStatus,
  }) {
    _state = WorkOrderCheckoutUiState(
      workOrderId: workOrderId,
      isOnline: connectivity.isOnline,
    );
    _subs.add(observeSession.execute().listen(_onSession));
    _subs.add(
      observeOrder.execute(WorkOrderId(workOrderId)).listen((order) {
        if (order != null) _mergeOrder(order);
      }),
    );
    _subs.add(
      observeVouchers.execute(workOrderId).listen((cached) {
        _update(_state.copyWith(cachedVouchers: cached));
      }),
    );
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  late WorkOrderCheckoutUiState _state;
  WorkOrderCheckoutUiState get state => _state;

  final List<StreamSubscription<Object?>> _subs = [];
  bool _disposed = false;

  void _onSession(Session? session) {
    final prevCanRead = _state.canReadInvoices;
    final canReadInvoices = session?.has(Permission.invoicesRead) == true;
    final canIssueVoucher = session?.has(Permission.invoicesIssueSunat) == true;
    _update(
      _state.copyWith(
        canReadInvoices: canReadInvoices,
        canIssueVoucher: canIssueVoucher,
        canRegisterPayment: session?.has(Permission.paymentsCreate) == true,
      ),
    );
    if (canReadInvoices && !prevCanRead && !_state.isRefreshing) {
      refresh();
    }
  }

  void _onConnectivity() {
    _update(_state.copyWith(isOnline: connectivity.isOnline));
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, error: null));
    await _load();
  }

  Future<void> _load() async {
    Object? failure;
    try {
      final detail = await getWorkOrderDetail.execute(WorkOrderId(workOrderId));
      _mergeOrder(detail.workOrder);
    } on Object catch (e) {
      failure = e;
    }
    if (_state.canReadInvoices) {
      try {
        final vouchers = await getVouchers.execute(workOrderId);
        _update(_state.copyWith(liveVouchers: vouchers));
        final active = _state.activeVoucher;
        if (active != null) await _loadPayments(active.id);
      } on Object catch (e) {
        failure ??= e;
      }
    }
    _update(
      _state.copyWith(
        isRefreshing: false,
        hasLoaded: true,
        error: failure == null ? null : toCashierText(failure),
      ),
    );
  }

  /// Historial de cobros (US38). Si falla se conserva el anterior: el saldo sale del comprobante.
  Future<void> _loadPayments(String voucherId) async {
    try {
      final payments = await getPayments.execute(voucherId);
      _update(_state.copyWith(payments: payments));
    } on Object {
      // Sin historial nuevo: el saldo del comprobante sigue siendo la fuente.
    }
  }

  void _mergeOrder(WorkOrder next) {
    final current = _state.order;
    _update(
      _state.copyWith(
        order: WorkOrder(
          id: next.id,
          internalNumber: next.internalNumber,
          branchId: next.branchId,
          vehicleId: next.vehicleId,
          customerId: next.customerId,
          currentBayId: next.currentBayId,
          bayName: next.bayName,
          status: next.status,
          diagnosticSummary: next.diagnosticSummary,
          mileageIn: next.mileageIn,
          subtotal: next.subtotal,
          taxAmount: next.taxAmount,
          totalAmount: next.totalAmount,
          plate: next.plate ?? current?.plate,
          customerName: next.customerName ?? current?.customerName,
        ),
      ),
    );
  }

  bool get _canAct => _state.isOnline && _state.busy == null;

  Future<void> onPrepareVoucher() async {
    if (!_state.canIssueVoucher || !_canAct) return;
    _update(_state.copyWith(busy: CheckoutAction.preparing, actionError: null, notice: null));
    try {
      final draft = await prepareVoucher.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          sheet: IssueCheckoutSheet(_toIssueForm(draft)),
          sheetError: null,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(actionError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  void onIssueType(VoucherType type) => _updateIssue((form) => form.withType(type));
  void onIssueDocumentType(FiscalDocumentType type) =>
      _updateIssue((form) => form.copyWith(documentType: type));

  void onIssueTaxId(String value) {
    final filtered = value.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final clipped = filtered.length > 20 ? filtered.substring(0, 20) : filtered;
    _updateIssue((form) => form.copyWith(taxId: clipped));
  }

  void onIssueName(String value) => _updateIssue((form) => form.copyWith(legalName: value));
  void onIssueAddress(String value) => _updateIssue((form) => form.copyWith(address: value));

  void onIssueLineName(int index, String value) => _updateIssue(
    (form) => form.copyWith(
      lines: [
        for (var i = 0; i < form.lines.length; i++)
          i == index ? form.lines[i].copyWith(description: value) : form.lines[i],
      ],
    ),
  );

  void _updateIssue(IssueForm Function(IssueForm) change) {
    final current = _state.sheet;
    if (current is! IssueCheckoutSheet) return;
    _update(_state.copyWith(sheet: IssueCheckoutSheet(change(current.form)), sheetError: null));
  }

  Future<void> onConfirmIssue() async {
    final current = _state.sheet;
    if (current is! IssueCheckoutSheet) return;
    if (!current.form.canSubmit || !_canAct) return;
    _update(_state.copyWith(busy: CheckoutAction.issuing, sheetError: null));
    try {
      final outcome = await issueVoucher.execute(current.form.toDraft());
      final notice = switch (outcome) {
        Issued() => UiText.resource((s) => s.cashierIssueDone),
        AlreadyIssued() => UiText.resource((s) => s.cashierIssueAlready),
        IssuedPendingDetails() => UiText.resource((s) => s.cashierIssueDetailsPending),
      };
      _update(_state.copyWith(sheet: null, notice: notice));
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  IssueForm _toIssueForm(VoucherDraft draft) => IssueForm(
    base: draft,
    type: draft.type,
    documentType: draft.type == VoucherType.factura
        ? FiscalDocumentType.ruc
        : (draft.customerInfo.documentType ?? FiscalDocumentType.dni),
    taxId: draft.customerInfo.taxId,
    legalName: draft.customerInfo.legalName,
    address: draft.customerInfo.fiscalAddress ?? '',
    lines: draft.lines,
  );

  void onOpenVoid(VoucherView voucher) {
    if (!_state.canIssueVoucher || !voucher.canVoidOrCreditNote || !_canAct) return;
    final label = formatVoucherCode(voucher.serie, voucher.number);
    _update(
      _state.copyWith(
        sheet: VoidCheckoutSheet(
          voucher: voucher,
          form: VoidForm(voucherId: voucher.id, voucherLabel: label),
        ),
        sheetError: null,
        notice: null,
        actionError: null,
      ),
    );
  }

  void onVoidReason(String value) {
    final current = _state.sheet;
    if (current is! VoidCheckoutSheet) return;
    final clipped = value.length > CashierValidation.maxReasonLength
        ? value.substring(0, CashierValidation.maxReasonLength)
        : value;
    _update(
      _state.copyWith(
        sheet: VoidCheckoutSheet(
          voucher: current.voucher,
          form: current.form.copyWith(reason: clipped),
        ),
        sheetError: null,
      ),
    );
  }

  Future<void> onConfirmVoid() async {
    final current = _state.sheet;
    if (current is! VoidCheckoutSheet) return;
    if (!_state.canIssueVoucher || !current.form.canSubmit || !_canAct) return;
    _update(_state.copyWith(busy: CheckoutAction.voiding, sheetError: null));
    try {
      await voidVoucher.execute(current.voucher.id, current.form.reason);
      _update(
        _state.copyWith(
          sheet: null,
          notice: UiText.resource((s) => s.cashierVoidDone),
        ),
      );
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  void onOpenCreditNote(VoucherView voucher) {
    if (!_state.canIssueVoucher || !voucher.canVoidOrCreditNote || !_canAct) return;
    final label = formatVoucherCode(voucher.serie, voucher.number);
    final initialAmount = voucher.total.toStringAsFixed(2);
    _update(
      _state.copyWith(
        sheet: CreditNoteCheckoutSheet(
          voucher: voucher,
          form: CreditNoteForm(
            referenceVoucherId: voucher.id,
            referenceLabel: label,
            maxAmount: voucher.total,
            currency: voucher.currency,
            amount: initialAmount,
          ),
        ),
        sheetError: null,
        notice: null,
        actionError: null,
      ),
    );
  }

  void onCreditNoteReason(String value) {
    final current = _state.sheet;
    if (current is! CreditNoteCheckoutSheet) return;
    final clipped = value.length > CashierValidation.maxReasonLength
        ? value.substring(0, CashierValidation.maxReasonLength)
        : value;
    _update(
      _state.copyWith(
        sheet: CreditNoteCheckoutSheet(
          voucher: current.voucher,
          form: current.form.copyWith(reason: clipped),
        ),
        sheetError: null,
      ),
    );
  }

  void onCreditNoteAmount(String value) {
    final current = _state.sheet;
    if (current is! CreditNoteCheckoutSheet) return;
    _update(
      _state.copyWith(
        sheet: CreditNoteCheckoutSheet(
          voucher: current.voucher,
          form: current.form.copyWith(amount: value),
        ),
        sheetError: null,
      ),
    );
  }

  Future<void> onConfirmCreditNote() async {
    final current = _state.sheet;
    if (current is! CreditNoteCheckoutSheet) return;
    final amount = current.form.parsedAmount;
    if (amount == null || !_state.canIssueVoucher || !current.form.canSubmit || !_canAct) return;
    _update(_state.copyWith(busy: CheckoutAction.issuingCreditNote, sheetError: null));
    try {
      final serie = current.form.selectedSerie.trim();
      await issueCreditNote.execute(
        referenceVoucherId: current.voucher.id,
        reason: current.form.reason,
        amount: amount,
        serieOverride: serie.isEmpty ? null : serie,
      );
      _update(
        _state.copyWith(
          sheet: null,
          notice: UiText.resource((s) => s.cashierNcDone),
        ),
      );
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  Future<void> onRefreshVoucherSunat(VoucherView voucher) async {
    final refreshUseCase = refreshVoucherStatus;
    if (refreshUseCase == null || !_canAct) return;
    _update(
      _state.copyWith(busy: CheckoutAction.refreshingSunat, actionError: null, notice: null),
    );
    try {
      final updated = await refreshUseCase.execute(voucher.id);
      final notice = switch (updated.status) {
        VoucherStatus.acceptedSunat => UiText.resource((s) => s.cashierSunatStatusAcceptedNotice),
        VoucherStatus.rejectedSunat => UiText.resource((s) => s.cashierSunatStatusRejectedNotice),
        _ => UiText.resource((s) => s.cashierSunatStatusPendingPseNotice),
      };
      _update(_state.copyWith(notice: notice));
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(actionError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  void onOpenVoucherPdf(VoucherView voucher) => _downloadFiscalFile(
    voucher.pdfUrl,
    '${voucher.serie}-${voucher.number}.pdf',
    DocumentIntents.mimePdf,
    CheckoutDocumentActionMode.open,
  );

  void onShareVoucherPdf(VoucherView voucher) => _downloadFiscalFile(
    voucher.pdfUrl,
    '${voucher.serie}-${voucher.number}.pdf',
    DocumentIntents.mimePdf,
    CheckoutDocumentActionMode.share,
  );

  void onShareVoucherXml(VoucherView voucher) => _downloadFiscalFile(
    voucher.xmlUrl,
    '${voucher.serie}-${voucher.number}.xml',
    DocumentIntents.mimeXml,
    CheckoutDocumentActionMode.share,
  );

  void onShareVoucherCdr(VoucherView voucher) => _downloadFiscalFile(
    voucher.cdrUrl,
    'cdr-${voucher.serie}-${voucher.number}.zip',
    DocumentIntents.mimeZip,
    CheckoutDocumentActionMode.share,
  );

  Future<void> _downloadFiscalFile(
    String? url,
    String fileNamePrefix,
    String mimeType,
    CheckoutDocumentActionMode mode,
  ) async {
    final targetUrl = url?.trim();
    final downloader = downloadVoucherDocument;
    if (targetUrl == null || targetUrl.isEmpty || downloader == null || !_canAct) return;
    _update(
      _state.copyWith(busy: CheckoutAction.downloadingDocument, actionError: null, notice: null),
    );
    try {
      final file = await downloader.execute(targetUrl, fileNamePrefix);
      _update(
        _state.copyWith(
          pendingDocument: PendingDocumentFile(file: file, mimeType: mimeType, mode: mode),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(actionError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  void onDocumentHandled() => _update(_state.copyWith(pendingDocument: null));

  void onDocumentOpenFailed() => _update(
    _state.copyWith(
      pendingDocument: null,
      actionError: UiText.resource((s) => s.cashierExitPassNoApp),
    ),
  );

  // region Cobros (US38)

  /// Abre la hoja con el saldo pendiente del comprobante como monto sugerido (pago íntegro, E1); el cajero
  /// puede bajarlo para un abono parcial (E2).
  void onOpenPayment() {
    final voucher = _state.activeVoucher;
    if (voucher == null || !_state.canRegisterPayment || !_canAct || voucher.pending <= Decimal.zero) return;
    _update(
      _state.copyWith(
        sheet: PaymentCheckoutSheet(
          PaymentForm(voucher: voucher, amount: voucher.pending.toStringAsFixed(2)),
        ),
        sheetError: null,
        notice: null,
        actionError: null,
      ),
    );
  }

  void onPaymentAmount(String value) => _updatePayment((form) => form.copyWith(amount: value));

  void onPaymentMethod(PaymentMethod method) => _updatePayment((form) => form.copyWith(method: method));

  void onPaymentReference(String value) {
    final clipped = value.length > PaymentForm.maxReference ? value.substring(0, PaymentForm.maxReference) : value;
    _updatePayment((form) => form.copyWith(reference: clipped));
  }

  void _updatePayment(PaymentForm Function(PaymentForm) change) {
    final current = _state.sheet;
    if (current is! PaymentCheckoutSheet) return;
    _update(_state.copyWith(sheet: PaymentCheckoutSheet(change(current.form)), sheetError: null));
  }

  /// `POST /invoicing/payments`. Nunca se reintenta solo (H28): si no se sabe si cobró, se cierra la hoja y se
  /// relee el historial para que el cajero lo vea antes de volver a cobrar.
  Future<void> onConfirmPayment() async {
    final current = _state.sheet;
    if (current is! PaymentCheckoutSheet) return;
    final form = current.form;
    final amount = form.parsedAmount;
    if (amount == null || !form.canSubmit || !_canAct) return;
    _update(_state.copyWith(busy: CheckoutAction.paying, sheetError: null));
    try {
      final reference = form.reference.trim();
      await registerPayment.execute(
        form.voucher.id,
        amount,
        form.method,
        transactionReference: reference.isEmpty ? null : reference,
      );
      _update(
        _state.copyWith(sheet: null, notice: UiText.resource((s) => s.cashierPaymentDone)),
      );
      await _load();
    } on PaymentOutcomeUnknownException catch (e) {
      _update(_state.copyWith(sheet: null, actionError: toCashierText(e)));
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(sheetError: toCashierText(e)));
    } finally {
      _update(_state.copyWith(busy: null));
    }
  }

  // endregion

  void onDismissSheet() {
    if (_state.busy != null) return;
    _update(_state.copyWith(sheet: null, sheetError: null));
  }

  void _update(WorkOrderCheckoutUiState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _subs) {
      sub.cancel();
    }
    connectivity.removeListener(_onConnectivity);
    super.dispose();
  }
}
