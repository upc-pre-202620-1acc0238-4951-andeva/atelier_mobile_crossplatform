import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/deliver_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_exit_pass_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_voucher_payments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/mark_work_order_paid_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockObserveOrder extends Mock implements ObserveWorkOrderUseCase {}

class _MockGetDetail extends Mock implements GetWorkOrderDetailUseCase {}

class _MockObserveVouchers extends Mock implements ObserveWorkOrderVouchersUseCase {}

class _MockGetVouchers extends Mock implements GetWorkOrderVouchersUseCase {}

class _MockGetPayments extends Mock implements GetVoucherPaymentsUseCase {}

class _MockRegisterPayment extends Mock implements RegisterPaymentUseCase {}

class _MockMarkPaid extends Mock implements MarkWorkOrderPaidUseCase {}

class _MockDownloadExitPass extends Mock implements DownloadExitPassUseCase {}

class _MockDeliver extends Mock implements DeliverVehicleUseCase {}

/// Cajero con cobro y pase; asesor con entrega (docs/02-roles-and-permissions.md).
Session _session({Set<String>? permissions}) => Session(
  userId: 'u1',
  email: 'cajero@atelier.pe',
  fullName: 'Cajero Demo',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions:
      permissions ??
      const {
        'invoicing:invoices:read',
        'invoicing:payments:create',
        'invoicing:exit_passes:issue',
        'operations:vehicle_handover:execute',
      },
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
  totalAmount: Money.of('118.00', Money.pen),
  plate: 'BKR418',
  customerName: 'Rosa Quispe',
);

Voucher _voucher({
  String paid = '0.00',
  String pending = '118.00',
  VoucherPaymentStatus paymentStatus = VoucherPaymentStatus.pending,
}) => Voucher(
  id: 'vch1',
  branchId: 'b1',
  customerId: 'c1',
  workOrderId: 'wo1',
  type: VoucherType.boleta,
  serie: 'B001',
  number: 45,
  currency: Money.pen,
  subtotal: Money.of('100.00', Money.pen),
  igvAmount: Money.of('18.00', Money.pen),
  totalAmount: Money.of('118.00', Money.pen),
  paidAmount: Money.of(paid, Money.pen),
  pendingBalance: Money.of(pending, Money.pen),
  paymentStatus: paymentStatus,
  status: VoucherStatus.acceptedSunat,
);

Payment _payment(String id, String amount, PaymentMethod method, {String? reference}) => Payment(
  id: id,
  voucherId: 'vch1',
  amount: Money.of(amount, Money.pen),
  method: method,
  transactionReference: reference,
  status: 'COMPLETED',
  paidAt: DateTime.utc(2026, 11, 25, 19, 35),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() {
    registerFallbackValue(const WorkOrderId('wo1'));
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(PaymentMethod.cash);
  });

  late _MockObserveSession observeSession;
  late _MockObserveOrder observeOrder;
  late _MockGetDetail getDetail;
  late _MockObserveVouchers observeVouchers;
  late _MockGetVouchers getVouchers;
  late _MockGetPayments getPayments;
  late _MockRegisterPayment registerPayment;
  late _MockMarkPaid markPaid;
  late _MockDownloadExitPass downloadExitPass;
  late _MockDeliver deliver;
  late StreamController<Session?> sessions;
  late StreamController<WorkOrder?> orders;
  late StreamController<List<VoucherSummary>> cachedVouchers;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  late WorkOrder currentOrder;
  WorkOrderCheckoutViewModel? vm;

  setUp(() async {
    observeSession = _MockObserveSession();
    observeOrder = _MockObserveOrder();
    getDetail = _MockGetDetail();
    observeVouchers = _MockObserveVouchers();
    getVouchers = _MockGetVouchers();
    getPayments = _MockGetPayments();
    registerPayment = _MockRegisterPayment();
    markPaid = _MockMarkPaid();
    downloadExitPass = _MockDownloadExitPass();
    deliver = _MockDeliver();
    sessions = StreamController<Session?>.broadcast();
    orders = StreamController<WorkOrder?>.broadcast();
    cachedVouchers = StreamController<List<VoucherSummary>>.broadcast();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    currentOrder = _order();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
    when(() => observeOrder.execute(any())).thenAnswer((_) => orders.stream);
    when(() => observeVouchers.execute('wo1')).thenAnswer((_) => cachedVouchers.stream);
    when(() => getDetail.execute(any())).thenAnswer(
      (_) async => WorkOrderDetail(
        workOrder: currentOrder,
        tasks: const [],
        proposals: const [],
        intakeImages: const [],
      ),
    );
    when(() => getVouchers.execute('wo1')).thenAnswer((_) async => [_voucher()]);
    when(() => getPayments.execute('vch1')).thenAnswer((_) async => []);
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

  Future<WorkOrderCheckoutViewModel> create({Session? session}) async {
    vm = WorkOrderCheckoutViewModel(
      workOrderId: 'wo1',
      observeSession: observeSession,
      observeOrder: observeOrder,
      getWorkOrderDetail: getDetail,
      observeVouchers: observeVouchers,
      getVouchers: getVouchers,
      prepareVoucher: PrepareVoucherUseCaseFake(),
      issueVoucher: IssueVoucherUseCaseFake(),
      voidVoucher: VoidVoucherUseCaseFake(),
      issueCreditNote: IssueCreditNoteUseCaseFake(),
      getPayments: getPayments,
      registerPayment: registerPayment,
      markPaid: markPaid,
      downloadExitPass: downloadExitPass,
      deliverVehicle: deliver,
      connectivity: connectivity,
    );
    sessions.add(session ?? _session());
    await _settle();
    await vm!.refresh();
    await _settle();
    return vm!;
  }

  group('PaymentForm', () {
    final voucher = VoucherView.fromVoucher(_voucher(paid: '50.00', pending: '68.00'));

    test('el monto va de 0.01 al saldo, con a lo sumo 2 decimales; acepta coma', () {
      PaymentForm form(String amount) => PaymentForm(voucher: voucher, amount: amount);
      expect(form('68').parsedAmount, Decimal.parse('68'));
      expect(form('20,50').parsedAmount, Decimal.parse('20.5'));
      expect(form('0.01').parsedAmount, Decimal.parse('0.01'));
      expect(form('0').parsedAmount, isNull);
      expect(form('68.01').parsedAmount, isNull); // Más que el saldo.
      expect(form('10.555').parsedAmount, isNull);
      expect(form('abc').parsedAmount, isNull);
    });

    test('efectivo no pide referencia; tarjeta, transferencia y billeteras sí', () {
      final cash = PaymentForm(voucher: voucher, amount: '10');
      expect(cash.requiresReference, isFalse);
      expect(cash.canSubmit, isTrue);

      for (final method in PaymentMethod.values.where((m) => m != PaymentMethod.cash)) {
        final form = cash.copyWith(method: method);
        expect(form.requiresReference, isTrue, reason: method.name);
        expect(form.canSubmit, isFalse, reason: method.name);
        expect(form.copyWith(reference: 'OP-123').canSubmit, isTrue, reason: method.name);
      }
    });
  });

  group('US38 — cobros', () {
    test('E1: pago íntegro con tarjeta y referencia; el cobro sugiere el saldo', () async {
      when(
        () => registerPayment.execute(
          any(),
          any(),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      ).thenAnswer((_) async => _voucher(paid: '118.00', pending: '0.00', paymentStatus: VoucherPaymentStatus.paid));
      final model = await create();

      model.onOpenPayment();
      final sheet = model.state.sheet as PaymentCheckoutSheet;
      expect(sheet.form.amount, '118.00');

      model.onPaymentMethod(PaymentMethod.debitCard);
      expect((model.state.sheet as PaymentCheckoutSheet).form.canSubmit, isFalse);
      model.onPaymentReference('  VISA-883201 ');

      when(() => getVouchers.execute('wo1')).thenAnswer(
        (_) async => [_voucher(paid: '118.00', pending: '0.00', paymentStatus: VoucherPaymentStatus.paid)],
      );
      when(() => getPayments.execute('vch1')).thenAnswer(
        (_) async => [_payment('p1', '118.00', PaymentMethod.debitCard, reference: 'VISA-883201')],
      );
      await model.onConfirmPayment();

      verify(
        () => registerPayment.execute(
          'vch1',
          Decimal.parse('118.00'),
          PaymentMethod.debitCard,
          transactionReference: 'VISA-883201',
        ),
      ).called(1);
      expect(model.state.sheet, isNull);
      expect(model.state.notice, isNotNull);
      expect(model.state.payments, hasLength(1));
      expect(model.state.activeVoucher?.paymentStatus, VoucherPaymentStatus.paid);
      // Saldado pero la orden aún COMPLETED: se ofrece marcarla pagada (US39 E2).
      expect(model.state.canMarkPaid, isTrue);
    });

    test('E2: abonos parciales en efectivo y transferencia hasta saldar', () async {
      when(
        () => registerPayment.execute(
          any(),
          any(),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      ).thenAnswer((_) async => _voucher());
      final model = await create();

      model.onOpenPayment();
      model.onPaymentAmount('50');
      when(() => getVouchers.execute('wo1')).thenAnswer(
        (_) async => [_voucher(paid: '50.00', pending: '68.00', paymentStatus: VoucherPaymentStatus.partial)],
      );
      await model.onConfirmPayment();

      verify(() => registerPayment.execute('vch1', Decimal.parse('50'), PaymentMethod.cash)).called(1);
      expect(model.state.activeVoucher?.pending, Decimal.parse('68.00'));
      expect(model.state.activeVoucher?.paymentStatus, VoucherPaymentStatus.partial);
      expect(model.state.canMarkPaid, isFalse); // Sigue pendiente mientras quede saldo.

      model.onOpenPayment();
      expect((model.state.sheet as PaymentCheckoutSheet).form.amount, '68.00');
      model.onPaymentAmount('70'); // Más que el saldo: no se envía.
      await model.onConfirmPayment();
      verifyNever(
        () => registerPayment.execute(
          any(),
          Decimal.parse('70'),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      );

      model
        ..onPaymentAmount('68')
        ..onPaymentMethod(PaymentMethod.bankTransfer)
        ..onPaymentReference('TRX-0091');
      when(() => getVouchers.execute('wo1')).thenAnswer(
        (_) async => [_voucher(paid: '118.00', pending: '0.00', paymentStatus: VoucherPaymentStatus.paid)],
      );
      await model.onConfirmPayment();

      verify(
        () => registerPayment.execute(
          'vch1',
          Decimal.parse('68'),
          PaymentMethod.bankTransfer,
          transactionReference: 'TRX-0091',
        ),
      ).called(1);
      expect(model.state.activeVoucher?.paymentStatus, VoucherPaymentStatus.paid);
    });

    test('resultado desconocido (H28): cierra la hoja, avisa y relee sin reintentar', () async {
      when(
        () => registerPayment.execute(
          any(),
          any(),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      ).thenThrow(const PaymentOutcomeUnknownException(NetworkException()));
      final model = await create();
      clearInteractions(getVouchers);

      model.onOpenPayment();
      await model.onConfirmPayment();

      expect(model.state.sheet, isNull);
      expect(model.state.actionError, isNotNull);
      verify(() => getVouchers.execute('wo1')).called(1);
      verify(
        () => registerPayment.execute(
          any(),
          any(),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      ).called(1);
    });

    test('un 4xx queda dentro de la hoja con el message del backend', () async {
      when(
        () => registerPayment.execute(
          any(),
          any(),
          any(),
          transactionReference: any(named: 'transactionReference'),
        ),
      ).thenThrow(const ApiException(httpStatus: 422, code: 'X', message: 'El monto supera el saldo'));
      final model = await create();

      model.onOpenPayment();
      await model.onConfirmPayment();

      expect(model.state.sheet, isA<PaymentCheckoutSheet>());
      expect(model.state.sheetError, isNotNull);
    });

    test('sin permiso de cobro o sin red no se abre la hoja', () async {
      final model = await create(session: _session(permissions: const {'invoicing:invoices:read'}));
      model.onOpenPayment();
      expect(model.state.sheet, isNull);

      sessions.add(_session());
      await _settle();
      network.add([ConnectivityResult.none]);
      await _settle();
      model.onOpenPayment();
      expect(model.state.sheet, isNull);
    });
  });

  group('US39 — pagada, pase de salida y entrega', () {
    test('E2: marcar pagada cuando el comprobante está saldado', () async {
      when(() => getVouchers.execute('wo1')).thenAnswer(
        (_) async => [_voucher(paid: '118.00', pending: '0.00', paymentStatus: VoucherPaymentStatus.paid)],
      );
      when(() => markPaid.execute(any())).thenAnswer((_) async => _order(status: WorkOrderStatus.paid));
      final model = await create();

      expect(model.state.canMarkPaid, isTrue);
      await model.onMarkPaid();

      verify(() => markPaid.execute(const WorkOrderId('wo1'))).called(1);
      expect(model.state.isOrderPaid, isTrue);
      expect(model.state.canMarkPaid, isFalse);
      expect(model.state.notice, isNotNull);
    });

    test('E3: con la orden sin pagar no se pide el pase de salida', () async {
      final model = await create();

      await model.onDownloadExitPass();

      verifyNever(() => downloadExitPass.execute(any()));
      expect(model.state.exitPass, isNull);
    });

    test('E3: si el backend responde 422 se muestra su message', () async {
      currentOrder = _order(status: WorkOrderStatus.paid);
      when(() => downloadExitPass.execute(any())).thenThrow(
        const ApiException(httpStatus: 422, code: 'X', message: 'La orden debe estar pagada'),
      );
      final model = await create();

      await model.onDownloadExitPass();

      expect(model.state.actionError, isNotNull);
      expect(model.state.exitPass, isNull);
    });

    test('E2: orden pagada descarga el pase (abrir o compartir) y entrega el vehículo', () async {
      currentOrder = _order(status: WorkOrderStatus.paid);
      final pdf = File('${Directory.systemTemp.path}/pase-wo1.pdf');
      when(() => downloadExitPass.execute(any())).thenAnswer((_) async => pdf);
      when(() => deliver.execute(any())).thenAnswer((_) async => _order(status: WorkOrderStatus.paid));
      final model = await create();

      model.onShareExitPass();
      await _settle();
      expect(model.state.exitPass, pdf);
      expect(model.state.exitPassActionMode, CheckoutDocumentActionMode.share);
      model.onExitPassHandled();
      expect(model.state.exitPass, isNull);

      model.onOpenDeliver();
      expect(model.state.sheet, isA<DeliverCheckoutSheet>());
      await model.onConfirmDeliver();

      verify(() => deliver.execute(const WorkOrderId('wo1'))).called(1);
      expect(model.state.delivered, isTrue);
      expect(model.state.sheet, isNull);
      model.onOpenDeliver(); // Ya entregado: no se vuelve a abrir.
      expect(model.state.sheet, isNull);
    });

    test('sin app para abrir el PDF se avisa', () async {
      currentOrder = _order(status: WorkOrderStatus.paid);
      final model = await create();

      model.onExitPassOpenFailed();

      expect(model.state.actionError, isNotNull);
    });
  });

  group('WorkOrderCheckoutContent', () {
    Future<void> pump(WidgetTester tester, WorkOrderCheckoutUiState state, {VoidCallback? onPay}) async {
      // Ancho holgado: en pruebas el texto usa la fuente Ahem (más ancha que Plus Jakarta Sans) y la placa L
      // con el chip de estado desbordaría la cabecera solo aquí.
      tester.view.physicalSize = const Size(480 * 3, 2600 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AtelierTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: WorkOrderCheckoutContent(
            state: state,
            onBack: () {},
            onRefresh: () async {},
            onPrepareVoucher: () {},
            onOpenVoid: (_) {},
            onOpenCreditNote: (_) {},
            onOpenVoucherPdf: (_) {},
            onShareVoucherPdf: (_) {},
            onShareVoucherXml: (_) {},
            onShareVoucherCdr: (_) {},
            onRefreshVoucherSunat: (_) {},
            onOpenPayment: onPay ?? () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('pasos 1–4 con historial de cobros, saldo y pase bloqueado sin pagar', (tester) async {
      var pay = 0;
      await pump(
        tester,
        WorkOrderCheckoutUiState(
          workOrderId: 'wo1',
          order: _order(),
          liveVouchers: [_voucher(paid: '50.00', pending: '68.00', paymentStatus: VoucherPaymentStatus.partial)],
          payments: [_payment('p1', '50.00', PaymentMethod.yape, reference: 'YP-883201')],
          hasLoaded: true,
          canReadInvoices: true,
          canRegisterPayment: true,
          canIssueExitPass: true,
          canDeliver: true,
        ),
        onPay: () => pay++,
      );

      expect(find.text('Etapa 2 de 4'), findsOneWidget);
      expect(find.text('2. Cobros'), findsOneWidget);
      expect(find.text('3. Pase de salida'), findsOneWidget);
      expect(find.text('4. Entrega'), findsOneWidget);
      expect(find.text('Cobrado'), findsOneWidget);
      expect(find.text('Saldo'), findsOneWidget);
      expect(find.text('Yape'), findsOneWidget);
      expect(find.textContaining('YP-883201'), findsOneWidget);
      expect(find.text('Disponible cuando la orden esté pagada.'), findsNWidgets(2));

      await tester.tap(find.text('Registrar cobro'));
      expect(pay, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('entregado: riel completo y chip "Entregado"', (tester) async {
      await pump(
        tester,
        WorkOrderCheckoutUiState(
          workOrderId: 'wo1',
          order: _order(status: WorkOrderStatus.paid),
          liveVouchers: [_voucher(paid: '118.00', pending: '0.00', paymentStatus: VoucherPaymentStatus.paid)],
          hasLoaded: true,
          delivered: true,
          canReadInvoices: true,
          canDeliver: true,
        ),
      );

      expect(find.text('Flujo completado'), findsOneWidget);
      expect(find.text('Entregado'), findsWidgets);
      expect(find.text('Entregar vehículo'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

class PrepareVoucherUseCaseFake extends Mock implements PrepareVoucherUseCase {}

class IssueVoucherUseCaseFake extends Mock implements IssueVoucherUseCase {}

class VoidVoucherUseCaseFake extends Mock implements VoidVoucherUseCase {}

class IssueCreditNoteUseCaseFake extends Mock implements IssueCreditNoteUseCase {}
