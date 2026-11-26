import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
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
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockObserveOrder extends Mock implements ObserveWorkOrderUseCase {}

class _MockGetDetail extends Mock implements GetWorkOrderDetailUseCase {}

class _MockObserveVouchers extends Mock implements ObserveWorkOrderVouchersUseCase {}

class _MockGetVouchers extends Mock implements GetWorkOrderVouchersUseCase {}

class _MockPrepareVoucher extends Mock implements PrepareVoucherUseCase {}

class _MockIssueVoucher extends Mock implements IssueVoucherUseCase {}

class _MockVoidVoucher extends Mock implements VoidVoucherUseCase {}

class _MockIssueCreditNote extends Mock implements IssueCreditNoteUseCase {}

class _MockDownloadDoc extends Mock implements DownloadVoucherDocumentUseCase {}

class _MockRefreshSunat extends Mock implements RefreshVoucherStatusUseCase {}

class _MockGetPayments extends Mock implements GetVoucherPaymentsUseCase {}

class _MockRegisterPayment extends Mock implements RegisterPaymentUseCase {}

class _FakeVoucherDraft extends Fake implements VoucherDraft {}

Session _session() => const Session(
  userId: 'u1',
  email: 'cajero@atelier.pe',
  fullName: 'Adiel',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: {'invoicing:invoices:read', 'invoicing:invoices:issue_sunat'},
  plan: null,
  branchId: 'b1',
);

WorkOrder _order({WorkOrderStatus status = WorkOrderStatus.completed}) => WorkOrder(
  id: const WorkOrderId('wo1'),
  internalNumber: 424,
  branchId: 'b1',
  vehicleId: 'v1',
  customerId: 'c1',
  status: status,
  subtotal: Money.of('100.00', Money.pen),
  taxAmount: Money.of('18.00', Money.pen),
  totalAmount: Money.of('118.00', Money.pen),
  plate: 'BKR418',
  customerName: 'Rosa Quispe',
);

Voucher _voucher({VoucherStatus status = VoucherStatus.acceptedSunat}) => Voucher(
  id: 'vch1',
  branchId: 'b1',
  customerId: 'c1',
  workOrderId: 'wo1',
  type: VoucherType.factura,
  serie: 'F001',
  number: 45,
  currency: Money.pen,
  subtotal: Money.of('100.00', Money.pen),
  igvAmount: Money.of('18.00', Money.pen),
  totalAmount: Money.of('118.00', Money.pen),
  paidAmount: Money.of('0.00', Money.pen),
  pendingBalance: Money.of('118.00', Money.pen),
  paymentStatus: VoucherPaymentStatus.pending,
  status: status,
  pdfUrl: 'https://pse.test/f001-45.pdf',
  xmlUrl: 'https://pse.test/f001-45.xml',
  cdrUrl: 'https://pse.test/cdr-45.zip',
  sunatResponseCode: '0',
  sunatDescription: 'Aceptada por SUNAT',
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() {
    registerFallbackValue(const WorkOrderId('wo1'));
    registerFallbackValue(_FakeVoucherDraft());
  });

  late _MockObserveSession observeSession;
  late _MockObserveOrder observeOrder;
  late _MockGetDetail getDetail;
  late _MockObserveVouchers observeVouchers;
  late _MockGetVouchers getVouchers;
  late _MockPrepareVoucher prepareVoucher;
  late _MockIssueVoucher issueVoucher;
  late _MockVoidVoucher voidVoucher;
  late _MockIssueCreditNote issueCreditNote;
  late _MockDownloadDoc downloadDoc;
  late _MockRefreshSunat refreshSunat;
  late _MockGetPayments getPayments;
  late StreamController<Session?> sessions;
  late StreamController<WorkOrder?> orders;
  late StreamController<List<VoucherSummary>> cachedVouchers;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  WorkOrderCheckoutViewModel? vm;

  setUp(() async {
    observeSession = _MockObserveSession();
    observeOrder = _MockObserveOrder();
    getDetail = _MockGetDetail();
    observeVouchers = _MockObserveVouchers();
    getVouchers = _MockGetVouchers();
    prepareVoucher = _MockPrepareVoucher();
    issueVoucher = _MockIssueVoucher();
    voidVoucher = _MockVoidVoucher();
    issueCreditNote = _MockIssueCreditNote();
    downloadDoc = _MockDownloadDoc();
    refreshSunat = _MockRefreshSunat();
    getPayments = _MockGetPayments();
    when(() => getPayments.execute(any())).thenAnswer((_) async => []);
    sessions = StreamController<Session?>.broadcast();
    orders = StreamController<WorkOrder?>.broadcast();
    cachedVouchers = StreamController<List<VoucherSummary>>.broadcast();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
    when(() => observeOrder.execute(any())).thenAnswer((_) => orders.stream);
    when(() => observeVouchers.execute('wo1')).thenAnswer((_) => cachedVouchers.stream);
    when(() => getDetail.execute(any())).thenAnswer(
      (_) async => WorkOrderDetail(
        workOrder: _order(),
        tasks: const [],
        proposals: const [],
        intakeImages: const [],
      ),
    );
    when(() => getVouchers.execute('wo1')).thenAnswer((_) async => []);
  });

  tearDown(() async {
    vm?.dispose();
    vm = null;
    connectivity.dispose();
    await sessions.close();
    await orders.close();
    await cachedVouchers.close();
    await network.close();
  });

  WorkOrderCheckoutViewModel create() => vm = WorkOrderCheckoutViewModel(
    workOrderId: 'wo1',
    observeSession: observeSession,
    observeOrder: observeOrder,
    getWorkOrderDetail: getDetail,
    observeVouchers: observeVouchers,
    getVouchers: getVouchers,
    prepareVoucher: prepareVoucher,
    issueVoucher: issueVoucher,
    voidVoucher: voidVoucher,
    issueCreditNote: issueCreditNote,
    getPayments: getPayments,
    registerPayment: _MockRegisterPayment(),
    connectivity: connectivity,
    downloadVoucherDocument: downloadDoc,
    refreshVoucherStatus: refreshSunat,
  );

  test('prepara borrador, exige descripción de línea genérica y emite factura SUNAT', () async {
    final draft = VoucherDraft(
      workOrderId: 'wo1',
      customerId: 'c1',
      type: VoucherType.boleta,
      customerInfo: const CustomerFiscalInfo(
        documentType: FiscalDocumentType.dni,
        taxId: '45871236',
        legalName: 'Rosa Quispe',
      ),
      currency: Money.pen,
      lines: [
        VoucherLineDraft(
          itemType: VoucherItemType.product,
          itemId: 'p1',
          description: 'Product 1a2b3c4d-1111-2222-3333-444455556666',
          quantity: Decimal.one,
          unitPriceWithIgv: Decimal.parse('118.00'),
        ),
      ],
    );
    when(() => prepareVoucher.execute(const WorkOrderId('wo1'))).thenAnswer((_) async => draft);
    when(() => issueVoucher.execute(any())).thenAnswer((_) async => Issued(_voucher()));

    create();
    sessions.add(_session());
    await _settle();

    await vm!.onPrepareVoucher();
    final sheet = vm!.state.sheet as IssueCheckoutSheet;
    // Línea genérica bloquea envío hasta editarla
    expect(sheet.form.canSubmit, isFalse);

    vm!.onIssueType(VoucherType.factura);
    vm!.onIssueTaxId('20612345679');
    vm!.onIssueName('Taller Demo S.A.C.');
    vm!.onIssueLineName(0, 'Pastillas de freno Bosch');

    final updatedSheet = vm!.state.sheet as IssueCheckoutSheet;
    expect(updatedSheet.form.documentType, FiscalDocumentType.ruc);
    expect(updatedSheet.form.canSubmit, isTrue);

    when(() => getVouchers.execute('wo1')).thenAnswer((_) async => [_voucher()]);
    await vm!.onConfirmIssue();

    expect(vm!.state.sheet, isNull);
    expect(vm!.state.activeVoucher?.serie, 'F001');
    expect(vm!.state.notice, isNotNull);
  });

  test('refresca estado SUNAT en contingencia y descarga PDF/XML/CDR', () async {
    final issued = _voucher(status: VoucherStatus.issued);
    final accepted = _voucher(status: VoucherStatus.acceptedSunat);
    when(() => getVouchers.execute('wo1')).thenAnswer((_) async => [issued]);
    when(() => refreshSunat.execute('vch1')).thenAnswer((_) async => accepted);
    when(() => downloadDoc.execute('https://pse.test/f001-45.xml', 'F001-45.xml'))
        .thenAnswer((_) async => File('f001-45.xml'));

    create();
    sessions.add(_session());
    await _settle();

    final view = vm!.state.activeVoucher!;
    when(() => getVouchers.execute('wo1')).thenAnswer((_) async => [accepted]);
    await vm!.onRefreshVoucherSunat(view);
    expect(vm!.state.activeVoucher?.status, VoucherStatus.acceptedSunat);

    vm!.onShareVoucherXml(vm!.state.activeVoucher!);
    await _settle();
    expect(vm!.state.pendingDocument?.mimeType, 'application/xml');
    expect(vm!.state.pendingDocument?.mode, CheckoutDocumentActionMode.share);
  });
}
