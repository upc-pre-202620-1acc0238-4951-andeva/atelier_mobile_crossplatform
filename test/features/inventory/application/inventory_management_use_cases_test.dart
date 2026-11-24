import 'package:atelier_mobile_crossplatform/features/inventory/application/add_purchase_order_item_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/cancel_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/dispatch_fifo_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_suppliers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/issue_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_direct_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/restore_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/batch_allocation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements InventoryRepository {}

Matcher _invalid(String field) {
  return throwsA(
    isA<InvalidInventoryInputException>().having(
      (e) => e.field,
      'field',
      field,
    ),
  );
}

Decimal _d(String value) => Decimal.parse(value);

void main() {
  late _MockRepository repository;
  final now = DateTime.utc(2026, 11, 24, 14);
  const order = PurchaseOrder(id: 'po1', lines: []);

  setUpAll(() {
    registerFallbackValue(Decimal.zero);
    registerFallbackValue(ItemCategory.filters);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() => repository = _MockRepository());

  group('CreatePartUseCase', () {
    late CreatePartUseCase useCase;

    setUp(() => useCase = CreatePartUseCase(repository: repository));

    Future<Part> create({
      String name = 'Filtro',
      String sku = 'flt-001',
      String basePrice = '25.5',
      String minimumStock = '2',
    }) {
      return useCase.execute(
        name: name,
        sku: sku,
        category: ItemCategory.filters,
        basePrice: _d(basePrice),
        minimumStock: _d(minimumStock),
      );
    }

    test(
      'valida nombre, SKU, precio y mínimo en ese orden, sin llamar',
      () async {
        await expectLater(create(name: ' '), _invalid('name'));
        await expectLater(create(sku: 'a b'), _invalid('sku'));
        await expectLater(create(basePrice: '-1'), _invalid('basePrice'));
        await expectLater(
          create(minimumStock: '-0.1'),
          _invalid('minimumStock'),
        );
        verifyZeroInteractions(repository);
      },
    );

    test('acepta cero y manda la unidad por defecto', () async {
      when(
        () => repository.createPart(
          name: any(named: 'name'),
          sku: any(named: 'sku'),
          category: any(named: 'category'),
          basePrice: any(named: 'basePrice'),
          minimumStock: any(named: 'minimumStock'),
          unitOfMeasure: any(named: 'unitOfMeasure'),
        ),
      ).thenAnswer(
        (_) async => Part(
          id: 'p1',
          name: 'Filtro',
          sku: 'FLT-001',
          totalStock: Decimal.zero,
          minimumStock: Decimal.zero,
        ),
      );

      await create(basePrice: '0', minimumStock: '0');

      verify(
        () => repository.createPart(
          name: 'Filtro',
          sku: 'flt-001',
          category: ItemCategory.filters,
          basePrice: Decimal.zero,
          minimumStock: Decimal.zero,
          unitOfMeasure: 'UNIT',
        ),
      ).called(1);
    });
  });

  group('UpdatePartUseCase', () {
    test('valida id, nombre, precio y mínimo, sin llamar', () async {
      final useCase = UpdatePartUseCase(repository: repository);
      Future<Part> update({
        String id = 'p1',
        String name = 'Filtro',
        String basePrice = '1',
        String minimumStock = '1',
      }) {
        return useCase.execute(
          id,
          name: name,
          category: ItemCategory.brakes,
          basePrice: _d(basePrice),
          minimumStock: _d(minimumStock),
        );
      }

      await expectLater(update(id: ' '), _invalid('id'));
      await expectLater(update(name: ''), _invalid('name'));
      await expectLater(update(basePrice: '-1'), _invalid('basePrice'));
      await expectLater(update(minimumStock: '-1'), _invalid('minimumStock'));
      verifyZeroInteractions(repository);
    });
  });

  group('proveedores', () {
    test('CreateSupplier exige razón social, RUC de 8 a 20 dígitos y correo válido', () async {
      final useCase = CreateSupplierUseCase(repository: repository);

      await expectLater(
        useCase.execute(businessName: ' ', taxId: '20123456789'),
        _invalid('businessName'),
      );
      await expectLater(
        useCase.execute(businessName: 'Repuestos SAC', taxId: '1234567'),
        _invalid('taxId'),
      );
      await expectLater(
        useCase.execute(businessName: 'Repuestos SAC', taxId: '12345678A'),
        _invalid('taxId'),
      );
      await expectLater(
        useCase.execute(
          businessName: 'Repuestos SAC',
          taxId: '20123456789',
          email: 'sin-arroba',
        ),
        _invalid('email'),
      );
      verifyZeroInteractions(repository);
    });

    test(
      'CreateSupplier acepta el correo vacío y el RUC con espacios',
      () async {
        when(
          () => repository.createSupplier(
            businessName: any(named: 'businessName'),
            taxId: any(named: 'taxId'),
            contactName: any(named: 'contactName'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
            address: any(named: 'address'),
          ),
        ).thenAnswer(
          (_) async => const Supplier(
            id: 's1',
            businessName: 'Repuestos SAC',
            taxId: '20123456789',
            active: true,
          ),
        );

        await CreateSupplierUseCase(repository: repository).execute(
          businessName: 'Repuestos SAC',
          taxId: ' 20123456789 ',
          email: '  ',
        );

        verify(
          () => repository.createSupplier(
            businessName: 'Repuestos SAC',
            taxId: ' 20123456789 ',
            email: '  ',
          ),
        ).called(1);
      },
    );

    test('UpdateSupplier solo valida lo que se envía', () async {
      final useCase = UpdateSupplierUseCase(repository: repository);

      await expectLater(useCase.execute(' '), _invalid('id'));
      await expectLater(
        useCase.execute('s1', businessName: ' '),
        _invalid('businessName'),
      );
      await expectLater(useCase.execute('s1', email: 'mal'), _invalid('email'));
      verifyZeroInteractions(repository);

      when(
        () => repository.updateSupplier(
          any(),
          businessName: any(named: 'businessName'),
          contactName: any(named: 'contactName'),
          phone: any(named: 'phone'),
          email: any(named: 'email'),
          address: any(named: 'address'),
          active: any(named: 'active'),
        ),
      ).thenAnswer(
        (_) async => const Supplier(
          id: 's1',
          businessName: 'X',
          taxId: '20123456789',
          active: false,
        ),
      );
      await useCase.execute('s1', active: false);
      verify(() => repository.updateSupplier('s1', active: false)).called(1);
    });

    test('GetSuppliers pasa la búsqueda y el estado', () async {
      when(
        () => repository.getSuppliers(
          search: any(named: 'search'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => const []);

      await GetSuppliersUseCase(repository: repository)
          .execute(search: 'rep', status: 'ACTIVE');

      verify(() => repository.getSuppliers(search: 'rep', status: 'ACTIVE'))
          .called(1);
    });
  });

  group('órdenes de compra', () {
    test('CreatePurchaseOrder valida proveedor y cada línea', () async {
      final useCase = CreatePurchaseOrderUseCase(repository: repository);
      PurchaseOrderLineInput line({
        String itemId = 'p1',
        String quantity = '1',
        String unitCost = '5',
      }) {
        return PurchaseOrderLineInput(
          itemId: itemId,
          quantity: _d(quantity),
          unitCost: _d(unitCost),
        );
      }

      await expectLater(useCase.execute(' '), _invalid('supplierId'));
      await expectLater(
        useCase.execute('s1', items: [line(itemId: ' ')]),
        _invalid('itemId'),
      );
      await expectLater(
        useCase.execute(
          's1',
          items: [
            line(),
            line(quantity: '0.009'),
          ],
        ),
        _invalid('quantity'),
      );
      await expectLater(
        useCase.execute('s1', items: [line(unitCost: '-1')]),
        _invalid('unitCost'),
      );
      verifyZeroInteractions(repository);
    });

    test('CreatePurchaseOrder admite un borrador sin líneas', () async {
      when(
        () => repository.createPurchaseOrder(
          any(),
          items: any(named: 'items'),
          orderNumber: any(named: 'orderNumber'),
          expectedDeliveryDate: any(named: 'expectedDeliveryDate'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => order);

      await CreatePurchaseOrderUseCase(repository: repository).execute('s1');

      verify(() => repository.createPurchaseOrder('s1')).called(1);
    });

    test(
      'AddPurchaseOrderItem exige cantidad mínima de 0.01 y costo no negativo',
      () async {
        final useCase = AddPurchaseOrderItemUseCase(repository: repository);
        Future<PurchaseOrder> add({
          String orderId = 'po1',
          String itemId = 'p1',
          String quantity = '0.01',
          String unitCost = '0',
        }) {
          return useCase.execute(
            orderId,
            itemId: itemId,
            quantity: _d(quantity),
            unitCost: _d(unitCost),
          );
        }

        await expectLater(add(orderId: ' '), _invalid('purchaseOrderId'));
        await expectLater(add(itemId: ''), _invalid('itemId'));
        await expectLater(add(quantity: '0'), _invalid('quantity'));
        await expectLater(add(unitCost: '-0.01'), _invalid('unitCost'));
        verifyZeroInteractions(repository);

        when(
          () => repository.addPurchaseOrderItem(
            any(),
            itemId: any(named: 'itemId'),
            quantity: any(named: 'quantity'),
            unitCost: any(named: 'unitCost'),
          ),
        ).thenAnswer((_) async => order);
        await add();
        verify(
          () => repository.addPurchaseOrderItem(
            'po1',
            itemId: 'p1',
            quantity: _d('0.01'),
            unitCost: Decimal.zero,
          ),
        ).called(1);
      },
    );

    test('Issue y Cancel exigen el id', () async {
      await expectLater(
        IssuePurchaseOrderUseCase(repository: repository).execute(' '),
        _invalid('id'),
      );
      await expectLater(
        CancelPurchaseOrderUseCase(repository: repository).execute(''),
        _invalid('id'),
      );
      verifyZeroInteractions(repository);

      when(() => repository.issuePurchaseOrder(any()))
          .thenAnswer((_) async => order);
      when(
        () =>
            repository.cancelPurchaseOrder(any(), reason: any(named: 'reason')),
      ).thenAnswer((_) async => order);

      await IssuePurchaseOrderUseCase(repository: repository).execute('po1');
      await CancelPurchaseOrderUseCase(repository: repository)
          .execute('po1', reason: 'Proveedor sin stock');

      verify(() => repository.issuePurchaseOrder('po1')).called(1);
      verify(
        () => repository.cancelPurchaseOrder(
          'po1',
          reason: 'Proveedor sin stock',
        ),
      ).called(1);
    });

    test('PurchaseOrder.canBeCanceled solo en borrador o emitida', () {
      PurchaseOrder withStatus(PurchaseOrderStatus status) {
        return PurchaseOrder(id: 'po1', status: status, lines: const []);
      }

      expect(withStatus(PurchaseOrderStatus.draft).canBeCanceled, isTrue);
      expect(withStatus(PurchaseOrderStatus.draft).isDraft, isTrue);
      expect(withStatus(PurchaseOrderStatus.issued).canBeCanceled, isTrue);
      expect(withStatus(PurchaseOrderStatus.received).canBeCanceled, isFalse);
      expect(withStatus(PurchaseOrderStatus.canceled).canBeCanceled, isFalse);
      expect(order.canBeCanceled, isFalse);
    });
  });

  group('lotes', () {
    test(
      'ReceiveDirectBatch valida en orden y rechaza una llegada futura',
      () async {
        final useCase = ReceiveDirectBatchUseCase(
          repository: repository,
          now: () => now,
        );
        Future<PartBatch> receive({
          String itemId = 'p1',
          String batchNumber = 'L-1',
          String quantity = '1',
          String unitCost = '3',
          DateTime? arrivalDate,
        }) {
          return useCase.execute(
            itemId,
            batchNumber: batchNumber,
            quantity: _d(quantity),
            unitCost: _d(unitCost),
            arrivalDate: arrivalDate,
          );
        }

        await expectLater(receive(itemId: ' '), _invalid('itemId'));
        await expectLater(receive(batchNumber: ' '), _invalid('batchNumber'));
        await expectLater(receive(quantity: '0'), _invalid('quantity'));
        await expectLater(receive(unitCost: '-1'), _invalid('unitCost'));
        await expectLater(
          receive(arrivalDate: now.add(const Duration(minutes: 1))),
          _invalid('arrivalDate'),
        );
        verifyZeroInteractions(repository);

        when(
          () => repository.receiveDirectBatch(
            any(),
            batchNumber: any(named: 'batchNumber'),
            quantity: any(named: 'quantity'),
            unitCost: any(named: 'unitCost'),
            arrivalDate: any(named: 'arrivalDate'),
            supplierId: any(named: 'supplierId'),
          ),
        ).thenAnswer(
          (_) async => PartBatch(
            id: 'l1',
            itemId: 'p1',
            batchNumber: 'L-1',
            remainingQty: Decimal.one,
          ),
        );
        await receive(arrivalDate: now);
        verify(
          () => repository.receiveDirectBatch(
            'p1',
            batchNumber: 'L-1',
            quantity: Decimal.one,
            unitCost: _d('3'),
            arrivalDate: now,
          ),
        ).called(1);
      },
    );

    test('DispatchFifoBatch exige repuesto y cantidad mínima', () async {
      final useCase = DispatchFifoBatchUseCase(repository: repository);

      await expectLater(
        useCase.execute(' ', quantity: Decimal.one),
        _invalid('itemId'),
      );
      await expectLater(
        useCase.execute('p1', quantity: _d('0.001')),
        _invalid('quantity'),
      );
      verifyZeroInteractions(repository);

      when(
        () => repository.dispatchFifoBatch(
          any(),
          quantity: any(named: 'quantity'),
          workOrderId: any(named: 'workOrderId'),
          taskId: any(named: 'taskId'),
        ),
      ).thenAnswer(
        (_) async => StockAllocation(
          allocationId: 'a1',
          allocatedQuantity: Decimal.one,
          deductions: const [],
        ),
      );
      await useCase.execute('p1', quantity: Decimal.one, taskId: 't1');
      verify(
        () => repository.dispatchFifoBatch(
          'p1',
          quantity: Decimal.one,
          taskId: 't1',
        ),
      ).called(1);
    });

    test('RestoreBatch exige repuesto y cantidad mínima', () async {
      final useCase = RestoreBatchUseCase(repository: repository);

      await expectLater(
        useCase.execute('', quantity: Decimal.one),
        _invalid('itemId'),
      );
      await expectLater(
        useCase.execute('p1', quantity: Decimal.zero),
        _invalid('quantity'),
      );
      verifyZeroInteractions(repository);

      when(
        () => repository.restoreBatch(
          any(),
          quantity: any(named: 'quantity'),
          batchId: any(named: 'batchId'),
          reason: any(named: 'reason'),
          workOrderId: any(named: 'workOrderId'),
        ),
      ).thenAnswer(
        (_) async => BatchRestoreResult(restoredQuantity: Decimal.one),
      );
      await useCase.execute('p1', quantity: Decimal.one, reason: 'Sobró');
      verify(
        () => repository.restoreBatch(
          'p1',
          quantity: Decimal.one,
          reason: 'Sobró',
        ),
      ).called(1);
    });
  });
}
