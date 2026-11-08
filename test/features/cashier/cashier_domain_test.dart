import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

Decimal d(String value) => Decimal.parse(value);

Money? pen(String? amount) =>
    amount == null ? null : Money(amount: d(amount), currency: Money.pen);

TaskDetail task({
  TaskStatus status = TaskStatus.completed,
  Money? price,
  bool noPrice = false,
  String? serviceId = 'srv1',
  List<TaskProduct> products = const [],
}) {
  return TaskDetail(
    id: TaskId('t'),
    workOrderId: 'wo1',
    serviceId: serviceId,
    status: status,
    description: 'Cambio de aceite',
    price: noPrice ? null : (price ?? pen('100')),
    totalPausedSeconds: 0,
    products: products,
  );
}

TaskProduct product(String? unitPrice, {String currency = Money.pen}) {
  return TaskProduct(
    id: 'tp',
    productId: 'p1',
    productName: 'Product 3fa85f64-5717-4562-b3fc-2c963f66afa6',
    quantity: d('2'),
    unitPrice: unitPrice == null
        ? null
        : Money(amount: d(unitPrice), currency: currency),
  );
}

WorkOrderDetail detail(List<TaskDetail> tasks) {
  return WorkOrderDetail(
    workOrder: WorkOrder(
      id: WorkOrderId('wo1'),
      branchId: 'b1',
      vehicleId: 'v1',
      customerId: 'c1',
      status: WorkOrderStatus.completed,
    ),
    tasks: tasks,
    proposals: const [],
    intakeImages: const [],
  );
}

Matcher invalid(String field) => throwsA(
  isA<InvalidCashierInputException>().having((e) => e.field, 'field', field),
);

void main() {
  test('IGV por unidad y por línea, mitad hacia arriba', () {
    expect(CashierValidation.withIgv(d('100')), d('118'));
    expect(CashierValidation.withIgv(d('84.75')), d('100.01')); // 100.005
    expect(CashierValidation.withIgv(d('0.01')), d('0.01'));
  });

  test('RUC, DNI, series y descripciones genéricas', () {
    expect(CashierValidation.isRuc('20123456789'), isTrue);
    expect(CashierValidation.isRuc('2012345678A'), isFalse);
    expect(CashierValidation.isDni('12345678'), isTrue);
    expect(CashierValidation.isDni('1234567'), isFalse);
    expect(CashierValidation.isSeriesFor(VoucherType.factura, 'F001'), isTrue);
    expect(CashierValidation.isSeriesFor(VoucherType.factura, 'B001'), isFalse);
    expect(CashierValidation.isSeriesFor(VoucherType.boleta, 'B0A1'), isTrue);
    expect(
      CashierValidation.isSeriesFor(VoucherType.notaCredito, 'F001'),
      isFalse,
    );
    expect(CashierValidation.isPlaceholderDescription('  '), isTrue);
    expect(
      CashierValidation.isPlaceholderDescription('Standard Service'),
      isTrue,
    );
    expect(
      CashierValidation.isPlaceholderDescription(
        'Product 3fa85f64-5717-4562-b3fc-2c963f66afa6',
      ),
      isTrue,
    );
    expect(CashierValidation.isPlaceholderDescription('Filtro'), isFalse);
    expect(CashierValidation.isPaymentAmount(d('0.01')), isTrue);
    expect(CashierValidation.isPaymentAmount(d('10.005')), isFalse);
    expect(CashierValidation.isPaymentAmount(d('0')), isFalse);
  });

  test('código SUNAT o nombre; venta vigente', () {
    expect(VoucherType.fromApi('01'), VoucherType.factura);
    expect(VoucherType.fromApi('boleta'), VoucherType.boleta);
    expect(VoucherType.fromApi('99'), isNull);
    expect(isActiveSale(VoucherType.boleta, null), isTrue);
    expect(isActiveSale(VoucherType.boleta, VoucherStatus.draft), isTrue);
    expect(isActiveSale(VoucherType.factura, VoucherStatus.voided), isFalse);
    expect(
      isActiveSale(VoucherType.factura, VoucherStatus.rejectedSunat),
      isFalse,
    );
    expect(
      isActiveSale(VoucherType.notaCredito, VoucherStatus.issued),
      isFalse,
    );
  });

  group('líneas del borrador (H26)', () {
    test(
      'servicio y repuestos con IGV; nombres del catálogo y de la caché',
      () {
        final (lines, currency) = VoucherDrafts.linesOf(
          detail([
            task(products: [product('10')]),
            task(status: TaskStatus.cancelled, price: pen('999')),
          ]),
          serviceNames: {'srv1': 'Mantenimiento'},
        );
        expect(currency, Money.pen);
        expect(lines.map((l) => l.description), [
          'Mantenimiento',
          startsWith('Product '),
        ]);
        expect(lines.map((l) => l.unitPriceWithIgv), [d('118'), d('11.8')]);
        expect(lines.last.needsDescription, isTrue);
      },
    );

    test('precio en 0 no da línea; precio nulo falla con lines', () {
      final (lines, _) = VoucherDrafts.linesOf(
        detail([
          task(price: pen('0'), products: [product('10')]),
        ]),
      );
      expect(lines.single.itemType, VoucherItemType.product);
      expect(
        () => VoucherDrafts.linesOf(detail([task(noPrice: true)])),
        invalid('lines'),
      );
      expect(
        () => VoucherDrafts.linesOf(
          detail([
            task(products: [product(null)]),
          ]),
        ),
        invalid('lines'),
      );
    });

    test('sin nada que cobrar falla con lines antes que con la moneda', () {
      expect(
        () => VoucherDrafts.linesOf(detail([task(price: pen('0'))])),
        invalid('lines'),
      );
      expect(
        () => VoucherDrafts.linesOf(
          detail([
            task(products: [product('5', currency: Money.usd)]),
          ]),
        ),
        invalid('currency'),
      );
    });

    test('el total puede diferir en céntimos del de la orden', () {
      final draft = VoucherDraft(
        workOrderId: 'wo1',
        customerId: 'c1',
        type: VoucherType.boleta,
        customerInfo: const CustomerFiscalInfo(
          taxId: '12345678',
          legalName: 'Ana',
        ),
        currency: Money.pen,
        lines: [
          VoucherLineDraft(
            itemType: VoucherItemType.product,
            description: 'x',
            quantity: d('3'),
            unitPriceWithIgv: CashierValidation.withIgv(
              d('0.85'),
            ), // 1.003 → 1.00
          ),
        ],
      );
      expect(draft.total, d('3')); // la orden diría 3.009 → 3.01
    });
  });

  test('sugerencia de comprobante (H27)', () {
    Customer customer(CustomerType type, String taxId) =>
        Customer(id: 'c1', type: type, displayName: 'Cliente', taxId: taxId);

    final company = VoucherDrafts.suggestFiscalInfo(
      customer(CustomerType.company, '20123456789'),
    );
    expect(company.$1, VoucherType.factura);
    expect(company.$2.documentType, FiscalDocumentType.ruc);
    final person = VoucherDrafts.suggestFiscalInfo(
      customer(CustomerType.individual, '12345678'),
    );
    expect(person.$1, VoucherType.boleta);
    expect(person.$2.documentType, FiscalDocumentType.dni);
    final other = VoucherDrafts.suggestFiscalInfo(
      customer(CustomerType.company, '123'),
    );
    expect(other.$1, VoucherType.boleta);
    expect(other.$2.documentType, FiscalDocumentType.ce);
  });
}
