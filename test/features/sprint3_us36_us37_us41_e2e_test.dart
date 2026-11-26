import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> _pumpApp(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: home,
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

void main() {
  setUpAll(_loadSatoshi);

  group('E2E Sprint 3 — US36, US37 y US41', () {
    testWidgets('US36: liquidación en cascada (mano de obra + repuestos + IGV 18 %) y FAB hacia checkout', (
      tester,
    ) async {
      var openedCheckout = false;
      final completedOrder = WorkOrder(
        id: const WorkOrderId('wo-36'),
        internalNumber: 360,
        branchId: 'b1',
        vehicleId: 'v1',
        customerId: 'c1',
        status: WorkOrderStatus.completed,
        subtotal: Money.of('500.00', Money.pen),
        taxAmount: Money.of('90.00', Money.pen),
        totalAmount: Money.of('590.00', Money.pen),
        plate: 'ABC123',
        customerName: 'Transportes Andinos S.A.C.',
      );
      final detail = WorkOrderDetail(
        workOrder: completedOrder,
        tasks: [
          TaskDetail(
            id: const TaskId('t1'),
            workOrderId: 'wo-36',
            serviceName: 'Mantenimiento 40,000 km',
            status: TaskStatus.completed,
            description: 'Mantenimiento 40,000 km',
            price: Money.of('300.00', Money.pen),
            totalPausedSeconds: 0,
            products: [
              TaskProduct(
                id: 'tp1',
                productId: 'p1',
                productName: 'Filtro de aceite Toyota',
                quantity: Decimal.parse('2'),
                unitPrice: Money.of('100.00', Money.pen),
                totalAmount: Money.of('200.00', Money.pen),
              ),
            ],
          ),
        ],
        proposals: const [],
        intakeImages: const [],
      );

      await _pumpApp(
        tester,
        WorkOrderDetailContent(
          state: WorkOrderDetailUiState(
            isLoading: false,
            detail: detail,
            hasCheckoutPermission: true,
            canReadQuotation: true,
          ),
          actions: WorkOrderDetailActions(onOpenCheckout: () => openedCheckout = true),
        ),
      );

      // Total en el panel superior + desglose completo en cascada
      expect(find.textContaining('Total: S/ 590.00'), findsOneWidget);
      expect(find.text('Subtotal mano de obra'), findsOneWidget);
      expect(find.text('S/ 300.00'), findsWidgets);
      expect(find.text('Subtotal repuestos'), findsOneWidget);
      expect(find.text('S/ 200.00'), findsWidgets);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('S/ 500.00'), findsWidgets);
      expect(find.text('IGV 18 %'), findsOneWidget);
      expect(find.text('S/ 90.00'), findsOneWidget);
      expect(find.text('S/ 590.00'), findsWidgets);

      // FAB Cobrar y entregar navega a checkout
      await tester.tap(find.text('Cobrar y entregar'));
      await tester.pump();
      expect(openedCheckout, isTrue);
      await _teardown(tester);
    });

    testWidgets('US37: WorkOrderCheckoutContent muestra Paso 1 Comprobante SUNAT; sin permisos de cobro ni entrega', (
      tester,
    ) async {
      var refreshedSunat = 0;
      var openedPdf = 0;
      final voucher = Voucher(
        id: 'vch-1',
        branchId: 'b1',
        customerId: 'c1',
        workOrderId: 'wo-37',
        type: VoucherType.factura,
        serie: 'F001',
        number: 128,
        currency: Money.pen,
        subtotal: Money.of('500.00', Money.pen),
        igvAmount: Money.of('90.00', Money.pen),
        totalAmount: Money.of('590.00', Money.pen),
        paidAmount: Money.of('0.00', Money.pen),
        pendingBalance: Money.of('590.00', Money.pen),
        paymentStatus: VoucherPaymentStatus.pending,
        status: VoucherStatus.issued,
        pdfUrl: 'https://pse.test/f001-128.pdf',
        xmlUrl: 'https://pse.test/f001-128.xml',
        cdrUrl: 'https://pse.test/cdr-128.zip',
        sunatResponseCode: 'PENDING',
        sunatDescription: 'Pendiente de envío PSE',
      );
      final order = WorkOrder(
        id: const WorkOrderId('wo-37'),
        internalNumber: 370,
        branchId: 'b1',
        vehicleId: 'v1',
        customerId: 'c1',
        status: WorkOrderStatus.completed,
        totalAmount: Money.of('590.00', Money.pen),
        plate: 'BKR418',
        customerName: 'Transportes Lima S.A.C.',
      );

      await _pumpApp(
        tester,
        WorkOrderCheckoutContent(
          state: WorkOrderCheckoutUiState(
            workOrderId: 'wo-37',
            order: order,
            liveVouchers: [voucher],
            hasLoaded: true,
            canReadInvoices: true,
            canIssueVoucher: true,
          ),
          onBack: () {},
          onRefresh: () async {},
          onPrepareVoucher: () {},
          onOpenVoid: (_) {},
          onOpenCreditNote: (_) {},
          onOpenVoucherPdf: (_) => openedPdf++,
          onShareVoucherPdf: (_) {},
          onShareVoucherXml: (_) {},
          onShareVoucherCdr: (_) {},
          onRefreshVoucherSunat: (_) => refreshedSunat++,
        ),
      );

      expect(find.text('1. Comprobante'), findsOneWidget);
      expect(find.text('Factura F001-00000128'), findsOneWidget);
      expect(find.text('Abrir PDF'), findsOneWidget);
      expect(find.text('Compartir XML UBL 2.1'), findsOneWidget);
      expect(find.text('Compartir CDR SUNAT'), findsOneWidget);
      expect(find.text('Actualizar estado SUNAT'), findsOneWidget);
      expect(find.text('Nota de crédito'), findsOneWidget);
      expect(find.text('Anular'), findsOneWidget);
      // Con `invoicing:invoices:read` el paso de cobros (US38) se ve en solo lectura, sin "Registrar cobro";
      // sin `invoicing:exit_passes:issue` ni `operations:vehicle_handover:execute` no hay pasos 3 y 4 (US39).
      expect(find.text('2. Cobros'), findsOneWidget);
      expect(find.text('Registrar cobro'), findsNothing);
      expect(find.text('3. Pase de salida'), findsNothing);
      expect(find.text('4. Entrega'), findsNothing);

      await tester.tap(find.text('Abrir PDF'));
      await tester.tap(find.text('Actualizar estado SUNAT'));
      await tester.pump();
      expect(openedPdf, 1);
      expect(refreshedSunat, 1);
      await _teardown(tester);
    });

    testWidgets('US37: DailyCashContent navega a Comprobantes SUNAT y VouchersContent filtra comprobantes', (
      tester,
    ) async {
      var openedVouchers = false;
      final voucher = Voucher(
        id: 'v1',
        type: VoucherType.boleta,
        serie: 'B001',
        number: 45,
        currency: Money.pen,
        subtotal: Money.of('100.00', Money.pen),
        igvAmount: Money.of('18.00', Money.pen),
        totalAmount: Money.of('118.00', Money.pen),
        paidAmount: Money.of('118.00', Money.pen),
        pendingBalance: Money.of('0.00', Money.pen),
        paymentStatus: VoucherPaymentStatus.paid,
        status: VoucherStatus.acceptedSunat,
        customerInfo: const CustomerFiscalInfo(
          documentType: FiscalDocumentType.dni,
          taxId: '45871236',
          legalName: 'Rosa Quispe',
        ),
        issuedAt: DateTime.utc(2026, 11, 20, 15, 0),
      );

      await _pumpApp(
        tester,
        DailyCashContent(
          state: DailyCashUiState(
            today: '2026-11-20',
            date: '2026-11-20',
            canRead: true,
            summary: DailyCashSummary(
              date: '2026-11-20',
              totalCollected: Money.of('118.00', Money.pen),
              paymentCount: 1,
              byMethod: {PaymentMethod.cash: Money.of('118.00', Money.pen)},
              payments: const [],
            ),
          ),
          onBack: () {},
          onOpenVouchers: () => openedVouchers = true,
          onRetry: () {},
          onPreviousDay: () {},
          onNextDay: () {},
          onToday: () {},
        ),
      );

      await tester.tap(find.text('Comprobantes SUNAT'));
      await tester.pump();
      expect(openedVouchers, isTrue);

      Voucher? tapped;
      await _pumpApp(
        tester,
        VouchersContent(
          state: VouchersUiState(
            vouchers: [voucher],
            hasLoaded: true,
            canRead: true,
            canIssueSunat: true,
          ),
          onBack: () {},
          onRefresh: () async {},
          onFilterChange: (_) {},
          onOpenVoucher: (v) => tapped = v,
        ),
      );

      expect(find.text('Comprobantes SUNAT'), findsOneWidget);
      expect(find.text('Boleta B001-00000045'), findsOneWidget);
      await tester.tap(find.text('Boleta B001-00000045'));
      await tester.pump();
      expect(tapped?.id, 'v1');
      await _teardown(tester);
    });

    testWidgets('US41: ReportsContent dispara Abrir PDF y Compartir PDF y deshabilita offline', (
      tester,
    ) async {
      var opened = 0;
      var shared = 0;
      final summary = CashFlowSummary(
        totalIncome: Money.of('2500.00', Money.pen),
        totalExpenses: Money.of('0.00', Money.pen),
        accountsReceivable: Money.of('0.00', Money.pen),
        netCashFlow: Decimal.parse('2500.00'),
        currency: Money.pen,
        movements: const [],
      );

      await _pumpApp(
        tester,
        ReportsContent(
          state: ReportsUiState(
            today: '2026-11-20',
            choice: PeriodChoice.thisMonth,
            period: periodFor(PeriodChoice.thisMonth, '2026-11-20'),
            summary: summary,
            canReadCashFlow: true,
          ),
          onBack: () {},
          onRetry: () async {},
          onChoice: (_) {},
          onOpenCustomRange: () {},
          onOpenCashFlowPdf: () => opened++,
          onShareCashFlowPdf: () => shared++,
        ),
      );

      await tester.tap(find.text('Abrir PDF'));
      await tester.tap(find.text('Compartir PDF'));
      await tester.pump();
      expect([opened, shared], [1, 1]);

      // Sin conexión muestra aviso y no dispara
      await _pumpApp(
        tester,
        ReportsContent(
          state: ReportsUiState(
            today: '2026-11-20',
            choice: PeriodChoice.thisMonth,
            period: periodFor(PeriodChoice.thisMonth, '2026-11-20'),
            summary: summary,
            canReadCashFlow: true,
            isOnline: false,
            pdf: File('dummy.pdf'),
          ),
          onBack: () {},
          onRetry: () async {},
          onChoice: (_) {},
          onOpenCustomRange: () {},
          onOpenCashFlowPdf: () => opened++,
          onShareCashFlowPdf: () => shared++,
        ),
      );
      await tester.tap(find.text('Abrir PDF'));
      await tester.pump();
      expect(opened, 1);
      await _teardown(tester);
    });
  });
}
