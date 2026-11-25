import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_voucher_document_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/refresh_voucher_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_forms.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

class VouchersViewModel extends ChangeNotifier {
  final GetVouchersUseCase getVouchers;
  final VoidVoucherUseCase voidVoucher;
  final IssueCreditNoteUseCase issueCreditNote;
  final ObserveSessionUseCase observeSession;
  final ConnectivityObserver connectivity;
  final DownloadVoucherDocumentUseCase? downloadVoucherDocument;
  final RefreshVoucherStatusUseCase? refreshVoucherStatus;
  final GetBranchSeriesUseCase? getBranchSeries;

  VouchersViewModel({
    required this.getVouchers,
    required this.voidVoucher,
    required this.issueCreditNote,
    required this.observeSession,
    required this.connectivity,
    this.downloadVoucherDocument,
    this.refreshVoucherStatus,
    this.getBranchSeries,
  }) {
    _state = VouchersUiState(isOnline: connectivity.isOnline);
    _sessionSub = observeSession.execute().listen(_onSession);
    connectivity.addListener(_onConnectivity);
  }

  late VouchersUiState _state;
  VouchersUiState get state => _state;

  StreamSubscription<Session?>? _sessionSub;
  bool _disposed = false;
  bool _sessionReceived = false;

  void _onSession(Session? session) {
    final wasAllowed = _state.canRead;
    final canRead = session?.has(Permission.invoicesRead) == true;
    final canIssueSunat = session?.has(Permission.invoicesIssueSunat) == true;
    final firstSession = !_sessionReceived;
    _sessionReceived = true;
    _update(_state.copyWith(canRead: canRead, canIssueSunat: canIssueSunat));
    if (canRead && (!wasAllowed || firstSession)) {
      refresh();
    } else if (!canRead && firstSession) {
      _update(_state.copyWith(hasLoaded: true, isRefreshing: false));
    }
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.canRead && _state.vouchers.isEmpty;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, error: null));
    await _load();
  }

  Future<void> _load() async {
    if (!_state.canRead) {
      _update(_state.copyWith(hasLoaded: true, isRefreshing: false));
      return;
    }
    try {
      final list = await getVouchers.execute();
      final sorted = [...list]
        ..sort((a, b) {
          final da = a.issuedAt;
          final db = b.issuedAt;
          if (da == null && db == null) return 0;
          if (da == null) return 1;
          if (db == null) return -1;
          return db.compareTo(da);
        });
      _update(
        _state.copyWith(
          vouchers: sorted,
          hasLoaded: true,
          isRefreshing: false,
          error: null,
        ),
      );
    } on Object catch (e) {
      _update(
        _state.copyWith(
          hasLoaded: true,
          isRefreshing: false,
          error: toCashierText(e),
        ),
      );
    }
  }

  void onFilterChange(VoucherFilter filter) => _update(_state.copyWith(filter: filter));

  void onOpenVoucher(Voucher voucher) {
    _update(
      _state.copyWith(
        sheet: VoucherDetailSheet(voucher),
        sheetError: null,
        notice: null,
      ),
    );
  }

  void onStartVoid() {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final voucher = current.voucher;
    if (!_state.canIssueSunat || !voucher.canIssueActions) return;
    final label = formatVoucherCode(voucher.serie, voucher.number);
    _update(
      _state.copyWith(
        sheet: VoucherVoidSheet(
          voucher: voucher,
          form: VoidForm(voucherId: voucher.id, voucherLabel: label),
        ),
        sheetError: null,
      ),
    );
  }

  void onVoidReason(String value) {
    final current = _state.sheet;
    if (current is! VoucherVoidSheet) return;
    final clipped = value.length > CashierValidation.maxReasonLength
        ? value.substring(0, CashierValidation.maxReasonLength)
        : value;
    _update(
      _state.copyWith(
        sheet: VoucherVoidSheet(
          voucher: current.voucher,
          form: current.form.copyWith(reason: clipped),
        ),
        sheetError: null,
      ),
    );
  }

  Future<void> onConfirmVoid() async {
    final current = _state.sheet;
    if (current is! VoucherVoidSheet) return;
    if (!_state.canIssueSunat || !_state.isOnline || _state.isSubmitting || !current.form.canSubmit) {
      return;
    }
    _update(_state.copyWith(isSubmitting: true, sheetError: null));
    try {
      await voidVoucher.execute(current.voucher.id, current.form.reason);
      _update(
        _state.copyWith(
          sheet: null,
          isSubmitting: false,
          notice: UiText.resource((s) => s.cashierVoidDone),
        ),
      );
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(isSubmitting: false, sheetError: toCashierText(e)));
    }
  }

  Future<void> onStartCreditNote() async {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final voucher = current.voucher;
    if (!_state.canIssueSunat || !voucher.canIssueActions) return;
    final label = formatVoucherCode(voucher.serie, voucher.number);
    final initialAmount = voucher.totalAmount.amount.toStringAsFixed(2);
    final form = CreditNoteForm(
      referenceVoucherId: voucher.id,
      referenceLabel: label,
      maxAmount: voucher.totalAmount.amount,
      currency: voucher.totalAmount.currency,
      amount: initialAmount,
    );
    _update(
      _state.copyWith(
        sheet: VoucherCreditNoteSheet(voucher: voucher, form: form),
        sheetError: null,
      ),
    );
    final loadSeries = getBranchSeries;
    if (loadSeries == null) return;
    try {
      final allSeries = await loadSeries.execute();
      final series = allSeries
          .where(
            (s) =>
                s.active &&
                s.type == VoucherType.notaCredito &&
                CashierValidation.isCreditNoteSeries(s.serie, voucher.type),
          )
          .toList();
      if (series.isNotEmpty) {
        final activeSheet = _state.sheet;
        if (activeSheet is VoucherCreditNoteSheet && activeSheet.voucher.id == voucher.id) {
          _update(
            _state.copyWith(
              sheet: VoucherCreditNoteSheet(
                voucher: activeSheet.voucher,
                form: activeSheet.form.copyWith(
                  availableSeries: series,
                  selectedSerie: series.first.serie,
                ),
              ),
            ),
          );
        }
      }
    } on Object {
      // Sin series precargadas; el caso de uso elegirá la serie activa al confirmar.
    }
  }

  void onCreditNoteSerie(String value) {
    final current = _state.sheet;
    if (current is! VoucherCreditNoteSheet) return;
    _update(
      _state.copyWith(
        sheet: VoucherCreditNoteSheet(
          voucher: current.voucher,
          form: current.form.copyWith(selectedSerie: value),
        ),
        sheetError: null,
      ),
    );
  }

  void onCreditNoteReason(String value) {
    final current = _state.sheet;
    if (current is! VoucherCreditNoteSheet) return;
    final clipped = value.length > CashierValidation.maxReasonLength
        ? value.substring(0, CashierValidation.maxReasonLength)
        : value;
    _update(
      _state.copyWith(
        sheet: VoucherCreditNoteSheet(
          voucher: current.voucher,
          form: current.form.copyWith(reason: clipped),
        ),
        sheetError: null,
      ),
    );
  }

  void onCreditNoteAmount(String value) {
    final current = _state.sheet;
    if (current is! VoucherCreditNoteSheet) return;
    _update(
      _state.copyWith(
        sheet: VoucherCreditNoteSheet(
          voucher: current.voucher,
          form: current.form.copyWith(amount: value),
        ),
        sheetError: null,
      ),
    );
  }

  Future<void> onConfirmCreditNote() async {
    final current = _state.sheet;
    if (current is! VoucherCreditNoteSheet) return;
    final amount = current.form.parsedAmount;
    if (amount == null) return;
    if (!_state.canIssueSunat || !_state.isOnline || _state.isSubmitting || !current.form.canSubmit) {
      return;
    }
    _update(_state.copyWith(isSubmitting: true, sheetError: null));
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
          isSubmitting: false,
          notice: UiText.resource((s) => s.cashierNcDone),
        ),
      );
      await _load();
    } on Object catch (e) {
      _update(_state.copyWith(isSubmitting: false, sheetError: toCashierText(e)));
    }
  }

  Future<void> onRefreshSunat() async {
    final current = _state.sheet;
    final refreshUseCase = refreshVoucherStatus;
    if (current is! VoucherDetailSheet || refreshUseCase == null) return;
    if (!_state.isOnline || _state.isRefreshingSunat || _state.isSubmitting) return;
    _update(_state.copyWith(isRefreshingSunat: true, sheetError: null));
    try {
      final updated = await refreshUseCase.execute(current.voucher.id);
      final notice = switch (updated.status) {
        VoucherStatus.acceptedSunat => UiText.resource((s) => s.cashierSunatStatusAcceptedNotice),
        VoucherStatus.rejectedSunat => UiText.resource((s) => s.cashierSunatStatusRejectedNotice),
        _ => UiText.resource((s) => s.cashierSunatStatusPendingPseNotice),
      };
      _update(
        _state.copyWith(
          isRefreshingSunat: false,
          vouchers: [
            for (final v in _state.vouchers) v.id == updated.id ? updated : v,
          ],
          sheet: VoucherDetailSheet(updated),
          notice: notice,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isRefreshingSunat: false, sheetError: toCashierText(e)));
    }
  }

  void onOpenPdf() {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final v = current.voucher;
    _downloadFiscalFile(
      v.pdfUrl,
      '${v.serie}-${v.number}.pdf',
      DocumentIntents.mimePdf,
      CheckoutDocumentActionMode.open,
    );
  }

  void onSharePdf() {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final v = current.voucher;
    _downloadFiscalFile(
      v.pdfUrl,
      '${v.serie}-${v.number}.pdf',
      DocumentIntents.mimePdf,
      CheckoutDocumentActionMode.share,
    );
  }

  void onShareXml() {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final v = current.voucher;
    _downloadFiscalFile(
      v.xmlUrl,
      '${v.serie}-${v.number}.xml',
      DocumentIntents.mimeXml,
      CheckoutDocumentActionMode.share,
    );
  }

  void onShareCdr() {
    final current = _state.sheet;
    if (current is! VoucherDetailSheet) return;
    final v = current.voucher;
    _downloadFiscalFile(
      v.cdrUrl,
      'cdr-${v.serie}-${v.number}.zip',
      DocumentIntents.mimeZip,
      CheckoutDocumentActionMode.share,
    );
  }

  Future<void> _downloadFiscalFile(
    String? url,
    String fileNamePrefix,
    String mimeType,
    CheckoutDocumentActionMode mode,
  ) async {
    final targetUrl = url?.trim();
    final downloader = downloadVoucherDocument;
    if (targetUrl == null || targetUrl.isEmpty || downloader == null) return;
    if (!_state.isOnline || _state.isDownloadingDocument) return;
    _update(_state.copyWith(isDownloadingDocument: true, sheetError: null));
    try {
      final file = await downloader.execute(targetUrl, fileNamePrefix);
      _update(
        _state.copyWith(
          isDownloadingDocument: false,
          pendingDocument: PendingDocumentFile(file: file, mimeType: mimeType, mode: mode),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isDownloadingDocument: false, sheetError: toCashierText(e)));
    }
  }

  void onDocumentHandled() => _update(_state.copyWith(pendingDocument: null));

  void onDocumentOpenFailed() => _update(
    _state.copyWith(
      pendingDocument: null,
      sheetError: UiText.resource((s) => s.cashierExitPassNoApp),
    ),
  );

  void onBackToDetail() {
    if (_state.isSubmitting) return;
    final voucher = switch (_state.sheet) {
      VoucherVoidSheet(:final voucher) => voucher,
      VoucherCreditNoteSheet(:final voucher) => voucher,
      _ => null,
    };
    if (voucher == null) return;
    _update(_state.copyWith(sheet: VoucherDetailSheet(voucher), sheetError: null));
  }

  void onDismissSheet() {
    if (_state.isSubmitting) return;
    _update(_state.copyWith(sheet: null, sheetError: null));
  }

  void _update(VouchersUiState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionSub?.cancel();
    connectivity.removeListener(_onConnectivity);
    super.dispose();
  }
}
