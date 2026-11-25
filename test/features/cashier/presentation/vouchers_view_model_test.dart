import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_voucher_document_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/refresh_voucher_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetVouchers extends Mock implements GetVouchersUseCase {}

class _MockVoidVoucher extends Mock implements VoidVoucherUseCase {}

class _MockIssueCreditNote extends Mock implements IssueCreditNoteUseCase {}

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockDownloadDocument extends Mock implements DownloadVoucherDocumentUseCase {}

class _MockRefreshSunat extends Mock implements RefreshVoucherStatusUseCase {}

class _MockGetSeries extends Mock implements GetBranchSeriesUseCase {}

Session _session(Set<String> permissions) => Session(
  userId: 'u1',
  email: 'cajero@atelier.pe',
  fullName: 'Adiel',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: permissions,
  plan: null,
  branchId: 'b1',
);

Voucher _voucher({
  String id = 'v1',
  VoucherType type = VoucherType.factura,
  String serie = 'F001',
  int number = 10,
  VoucherStatus status = VoucherStatus.acceptedSunat,
  String total = '118.00',
  String pending = '0.00',
  DateTime? issuedAt,
  String? pdfUrl,
}) => Voucher(
  id: id,
  branchId: 'b1',
  customerId: 'c1',
  workOrderId: 'wo1',
  type: type,
  serie: serie,
  number: number,
  currency: Money.pen,
  subtotal: Money.of('100.00', Money.pen),
  igvAmount: Money.of('18.00', Money.pen),
  totalAmount: Money.of(total, Money.pen),
  paidAmount: Money.of(total, Money.pen),
  pendingBalance: Money.of(pending, Money.pen),
  paymentStatus: pending == '0.00' ? VoucherPaymentStatus.paid : VoucherPaymentStatus.pending,
  status: status,
  pdfUrl: pdfUrl,
  issuedAt: issuedAt ?? DateTime.utc(2026, 11, 20, 15, 0),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() => registerFallbackValue(Decimal.zero));

  late _MockGetVouchers getVouchers;
  late _MockVoidVoucher voidVoucher;
  late _MockIssueCreditNote issueCreditNote;
  late _MockObserveSession observeSession;
  late _MockDownloadDocument downloadDocument;
  late _MockRefreshSunat refreshSunat;
  late _MockGetSeries getSeries;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  VouchersViewModel? vm;

  setUp(() async {
    getVouchers = _MockGetVouchers();
    voidVoucher = _MockVoidVoucher();
    issueCreditNote = _MockIssueCreditNote();
    observeSession = _MockObserveSession();
    downloadDocument = _MockDownloadDocument();
    refreshSunat = _MockRefreshSunat();
    getSeries = _MockGetSeries();
    sessions = StreamController<Session?>.broadcast();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
  });

  tearDown(() async {
    vm?.dispose();
    vm = null;
    connectivity.dispose();
    await sessions.close();
    await network.close();
  });

  VouchersViewModel create() => vm = VouchersViewModel(
    getVouchers: getVouchers,
    voidVoucher: voidVoucher,
    issueCreditNote: issueCreditNote,
    observeSession: observeSession,
    connectivity: connectivity,
    downloadVoucherDocument: downloadDocument,
    refreshVoucherStatus: refreshSunat,
    getBranchSeries: getSeries,
  );

  test('carga, ordena descendente por fecha y filtra correctamente', () async {
    final vAccepted = _voucher(
      id: 'v1',
      status: VoucherStatus.acceptedSunat,
      pending: '50.00',
      issuedAt: DateTime.utc(2026, 11, 18),
    );
    final vVoided = _voucher(
      id: 'v2',
      status: VoucherStatus.voided,
      issuedAt: DateTime.utc(2026, 11, 20),
    );
    final vNc = _voucher(
      id: 'v3',
      type: VoucherType.notaCredito,
      serie: 'FC01',
      status: VoucherStatus.acceptedSunat,
      issuedAt: DateTime.utc(2026, 11, 19),
    );
    when(() => getVouchers.execute()).thenAnswer((_) async => [vAccepted, vVoided, vNc]);

    create();
    sessions.add(_session({'invoicing:invoices:read', 'invoicing:invoices:issue_sunat'}));
    await _settle();

    expect(vm!.state.hasLoaded, isTrue);
    expect(vm!.state.vouchers.map((v) => v.id), ['v2', 'v3', 'v1']);

    vm!.onFilterChange(VoucherFilter.accepted);
    expect(vm!.state.filteredVouchers.map((v) => v.id), ['v3', 'v1']);

    vm!.onFilterChange(VoucherFilter.withBalance);
    expect(vm!.state.filteredVouchers.map((v) => v.id), ['v1']);

    vm!.onFilterChange(VoucherFilter.voided);
    expect(vm!.state.filteredVouchers.map((v) => v.id), ['v2']);

    vm!.onFilterChange(VoucherFilter.creditNotes);
    expect(vm!.state.filteredVouchers.map((v) => v.id), ['v3']);
  });

  test('refresca estado SUNAT desde contingencia ISSUED y actualiza hoja', () async {
    final pending = _voucher(id: 'v1', status: VoucherStatus.issued);
    final accepted = _voucher(id: 'v1', status: VoucherStatus.acceptedSunat);
    when(() => getVouchers.execute()).thenAnswer((_) async => [pending]);
    when(() => refreshSunat.execute('v1')).thenAnswer((_) async => accepted);

    create();
    sessions.add(_session({'invoicing:invoices:read', 'invoicing:invoices:issue_sunat'}));
    await _settle();

    vm!.onOpenVoucher(pending);
    await vm!.onRefreshSunat();

    expect(vm!.state.vouchers.first.status, VoucherStatus.acceptedSunat);
    expect(vm!.state.notice, isNotNull);
  });

  test('anulación y nota de crédito validan motivo, envían y recargan', () async {
    final v = _voucher(id: 'v1', pdfUrl: 'https://pse.test/f001.pdf');
    when(() => getVouchers.execute()).thenAnswer((_) async => [v]);
    when(() => voidVoucher.execute('v1', 'Error en RUC')).thenAnswer((_) async => v);
    when(() => getSeries.execute()).thenAnswer(
      (_) async => const [
        FiscalSeries(
          id: 's1',
          type: VoucherType.notaCredito,
          serie: 'FC01',
          currentCorrelative: 1,
          active: true,
        ),
      ],
    );
    when(
      () => issueCreditNote.execute(
        referenceVoucherId: 'v1',
        reason: 'Descuento acordado',
        amount: Decimal.parse('50.00'),
        serieOverride: 'FC01',
      ),
    ).thenAnswer((_) async => v);
    when(
      () => downloadDocument.execute('https://pse.test/f001.pdf', 'F001-10.pdf'),
    ).thenAnswer((_) async => File('f001.pdf'));

    create();
    sessions.add(_session({'invoicing:invoices:read', 'invoicing:invoices:issue_sunat'}));
    await _settle();

    // Descarga PDF
    vm!.onOpenVoucher(v);
    vm!.onOpenPdf();
    await _settle();
    expect(vm!.state.pendingDocument?.mode, CheckoutDocumentActionMode.open);
    vm!.onDocumentHandled();
    expect(vm!.state.pendingDocument, isNull);

    // Anular
    vm!.onStartVoid();
    vm!.onVoidReason('Error en RUC');
    await vm!.onConfirmVoid();
    verify(() => voidVoucher.execute('v1', 'Error en RUC')).called(1);
    expect(vm!.state.sheet, isNull);

    // Nota de crédito
    vm!.onOpenVoucher(v);
    await vm!.onStartCreditNote();
    vm!.onCreditNoteReason('Descuento acordado');
    vm!.onCreditNoteAmount('50.00');
    await vm!.onConfirmCreditNote();
    verify(
      () => issueCreditNote.execute(
        referenceVoucherId: 'v1',
        reason: 'Descuento acordado',
        amount: Decimal.parse('50.00'),
        serieOverride: 'FC01',
      ),
    ).called(1);
    expect(vm!.state.sheet, isNull);
  });

  test('error de red al cargar deja mensaje de error', () async {
    when(() => getVouchers.execute()).thenThrow(
      const ApiException(httpStatus: 500, code: 'ERR', message: 'Error SUNAT'),
    );
    create();
    sessions.add(_session({'invoicing:invoices:read'}));
    await _settle();

    expect(vm!.state.error, isNotNull);
    expect(vm!.state.hasLoaded, isTrue);
  });
}
