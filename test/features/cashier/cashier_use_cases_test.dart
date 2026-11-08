import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'cashier_domain_test.dart' show d, detail, invalid, product, task;

class _MockCashier extends Mock implements CashierRepository {}

class _MockWorkOrders extends Mock implements WorkOrderRepository {}

class _MockReception extends Mock implements ReceptionRepository {}

class _MockInventory extends Mock implements InventoryRepository {}

VoucherDraft draft({
  VoucherType type = VoucherType.boleta,
  FiscalDocumentType document = FiscalDocumentType.dni,
  String taxId = '12345678',
  String description = 'Cambio de aceite',
}) {
  return VoucherDraft(
    workOrderId: 'wo1',
    customerId: 'c1',
    type: type,
    customerInfo: CustomerFiscalInfo(
      documentType: document,
      taxId: taxId,
      legalName: 'Ana',
    ),
    currency: Money.pen,
    lines: [
      VoucherLineDraft(
        itemType: VoucherItemType.service,
        description: description,
        quantity: Decimal.one,
        unitPriceWithIgv: d('118'),
      ),
    ],
  );
}

Voucher voucher({VoucherPaymentStatus status = VoucherPaymentStatus.paid}) {
  final zero = Money(amount: Decimal.zero, currency: Money.pen);
  return Voucher(
    id: 'v1',
    workOrderId: 'wo1',
    type: VoucherType.boleta,
    serie: 'B001',
    number: 1,
    subtotal: zero,
    igvAmount: zero,
    totalAmount: zero,
    paidAmount: zero,
    pendingBalance: zero,
    paymentStatus: status,
  );
}

void main() {
  late _MockCashier cashier;
  late _MockWorkOrders workOrders;

  setUpAll(() {
    registerFallbackValue(draft());
    registerFallbackValue(WorkOrderId('x'));
    registerFallbackValue(PaymentMethod.cash);
    registerFallbackValue(Decimal.zero);
  });

  setUp(() {
    cashier = _MockCashier();
    workOrders = _MockWorkOrders();
  });

  group('PrepareVoucherUseCase', () {
    late _MockReception reception;
    late _MockInventory inventory;
    late PrepareVoucherUseCase useCase;

    setUp(() {
      reception = _MockReception();
      inventory = _MockInventory();
      useCase = PrepareVoucherUseCase(
        workOrders: workOrders,
        reception: reception,
        inventory: inventory,
      );
      when(() => reception.getCustomer('c1')).thenAnswer(
        (_) async => const Customer(
          id: 'c1',
          type: CustomerType.individual,
          displayName: 'Ana',
          taxId: '12345678',
        ),
      );
      when(() => inventory.observePart(any()))
          .thenAnswer((_) => Stream.value(null));
    });

    test('solo una orden completada', () async {
      final open = detail([task()]);
      when(() => workOrders.getDetail(any())).thenAnswer(
        (_) async => WorkOrderDetail(
          workOrder: WorkOrder(
            id: WorkOrderId('wo1'),
            branchId: 'b1',
            vehicleId: 'v1',
            customerId: 'c1',
            status: WorkOrderStatus.inProgress,
          ),
          tasks: open.tasks,
          proposals: const [],
          intakeImages: const [],
        ),
      );
      await expectLater(useCase.execute(WorkOrderId('wo1')), invalid('status'));
    });

    test('un fallo del catálogo no tumba el borrador; repuestos con nombre de la caché', () async {
      when(() => workOrders.getDetail(any())).thenAnswer(
        (_) async => detail([
          task(products: [product('10')]),
        ]),
      );
      when(() => workOrders.getServiceCatalog()).thenThrow(StateError('403'));
      when(() => inventory.observePart('p1')).thenAnswer(
        (_) => Stream.value(
          Part(
            id: 'p1',
            name: 'Filtro',
            sku: 'F1',
            totalStock: Decimal.one,
            minimumStock: Decimal.zero,
            unitOfMeasure: 'UND',
          ),
        ),
      );
      final result = await useCase.execute(WorkOrderId('wo1'));
      expect(result.lines.map((l) => l.description), [
        'Cambio de aceite',
        'Filtro',
      ]);
      expect(result.type, VoucherType.boleta);
      expect(result.customerInfo.legalName, 'Ana');
    });

    test('el nombre del servicio sale del catálogo', () async {
      when(() => workOrders.getDetail(any()))
          .thenAnswer((_) async => detail([task()]));
      when(() => workOrders.getServiceCatalog()).thenAnswer(
        (_) async => [const ServiceOption(id: 'srv1', name: 'Mantenimiento')],
      );
      final result = await useCase.execute(WorkOrderId('wo1'));
      expect(result.lines.single.description, 'Mantenimiento');
      expect(task().status, TaskStatus.completed);
    });
  });

  group('IssueVoucherUseCase', () {
    late IssueVoucherUseCase useCase;

    setUp(() => useCase = IssueVoucherUseCase(repository: cashier));

    test('una descripción genérica bloquea la emisión', () async {
      await expectLater(
        useCase.execute(draft(description: 'Standard Service')),
        invalid('lines'),
      );
      verifyNever(() => cashier.issue(any(), any()));
    });

    test('factura sin RUC válido', () async {
      await expectLater(
        useCase.execute(
          draft(
            type: VoucherType.factura,
            document: FiscalDocumentType.ruc,
            taxId: '123',
          ),
        ),
        invalid('taxId'),
      );
      await expectLater(
        useCase.execute(draft(type: VoucherType.factura)),
        invalid('taxId'),
      );
    });

    test('sin serie activa del tipo', () async {
      when(() => cashier.getBranchSeries()).thenAnswer(
        (_) async => [
          const FiscalSeries(
            id: '1',
            type: VoucherType.factura,
            serie: 'F001',
            currentCorrelative: 0,
            active: true,
          ),
          const FiscalSeries(
            id: '2',
            type: VoucherType.boleta,
            serie: 'B001',
            currentCorrelative: 0,
            active: false,
          ),
        ],
      );
      await expectLater(
        useCase.execute(draft()),
        throwsA(isA<MissingFiscalSeriesException>()),
      );
    });

    test('emite con la primera serie activa del tipo', () async {
      when(() => cashier.getBranchSeries()).thenAnswer(
        (_) async => [
          const FiscalSeries(
            id: '2',
            type: VoucherType.boleta,
            serie: 'B002',
            currentCorrelative: 0,
            active: true,
          ),
          const FiscalSeries(
            id: '3',
            type: VoucherType.boleta,
            serie: 'B003',
            currentCorrelative: 0,
            active: true,
          ),
        ],
      );
      when(() => cashier.issue(any(), any()))
          .thenAnswer((_) async => IssuedPendingDetails('v1'));
      final outcome = await useCase.execute(draft());
      expect(outcome, isA<IssuedPendingDetails>());
      verify(() => cashier.issue(any(), 'B002')).called(1);
    });
  });

  group('RegisterPaymentUseCase', () {
    test('si queda pagado recarga la orden e ignora ese fallo', () async {
      when(() => cashier.registerPayment(any(), any(), any(), any()))
          .thenAnswer((_) async => voucher());
      when(() => workOrders.getDetail(any())).thenThrow(StateError('sin red'));
      final result = await RegisterPaymentUseCase(
        repository: cashier,
        workOrders: workOrders,
      ).execute('v1', d('118'), PaymentMethod.cash);
      expect(result.id, 'v1');
      verify(() => workOrders.getDetail(WorkOrderId('wo1'))).called(1);
    });

    test('con saldo no recarga la orden', () async {
      when(
        () => cashier.registerPayment(any(), any(), any(), any()),
      ).thenAnswer((_) async => voucher(status: VoucherPaymentStatus.partial));
      await RegisterPaymentUseCase(
        repository: cashier,
        workOrders: workOrders,
      ).execute('v1', d('10'), PaymentMethod.cash);
      verifyNever(() => workOrders.getDetail(any()));
    });
  });
}
