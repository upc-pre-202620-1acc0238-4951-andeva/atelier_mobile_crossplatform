import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/inventory/application/find_part_by_sku_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/search_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
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

void main() {
  late _MockRepository repository;
  final now = DateTime.utc(2026, 11, 7, 14);
  final photo = File('foto.jpg');

  setUpAll(() => registerFallbackValue(File('')));

  setUp(() => repository = _MockRepository());

  group('ReceivePurchaseOrderUseCase', () {
    late ReceivePurchaseOrderUseCase useCase;

    setUp(() {
      useCase = ReceivePurchaseOrderUseCase(
        repository: repository,
        now: () => now,
      );
    });

    test('valida foto, número y fecha, en ese orden, sin llamar', () async {
      await expectLater(
        useCase.execute(
          'po1',
          receiptNumber: ' ',
          photo: null,
          receivedAt: now.add(const Duration(days: 1)),
        ),
        _invalid('photo'),
      );
      await expectLater(
        useCase.execute(
          'po1',
          receiptNumber: ' ',
          photo: photo,
          receivedAt: now.add(const Duration(days: 1)),
        ),
        _invalid('receiptNumber'),
      );
      await expectLater(
        useCase.execute(
          'po1',
          receiptNumber: 'F001',
          photo: photo,
          receivedAt: now.add(const Duration(days: 1)),
        ),
        _invalid('receivedAt'),
      );
      verifyZeroInteractions(repository);
    });

    test('recorta el número del comprobante', () async {
      const order = PurchaseOrder(id: 'po1', lines: []);
      when(
        () => repository.receivePurchaseOrder(
          any(),
          any(),
          any(),
          receivedAt: any(named: 'receivedAt'),
        ),
      ).thenAnswer((_) async => order);

      await useCase.execute('po1', receiptNumber: ' F001-23 ', photo: photo);

      verify(
        () => repository.receivePurchaseOrder('po1', 'F001-23', photo),
      ).called(1);
    });
  });

  test('FindPartBySku con formato inválido no llama', () async {
    await expectLater(
      FindPartBySkuUseCase(repository: repository).execute('a b'),
      _invalid('sku'),
    );
    verifyZeroInteractions(repository);
  });

  test('SearchPartsCatalog recorta el texto', () async {
    when(
      () => repository.searchParts(any(), category: any(named: 'category')),
    ).thenAnswer((_) async => const []);

    await SearchPartsCatalogUseCase(repository: repository).execute('  freno ');

    verify(() => repository.searchParts('freno')).called(1);
  });

  group('GetPurchaseOrdersUseCase', () {
    setUp(() {
      when(
        () => repository.getPurchaseOrders(status: any(named: 'status')),
      ).thenAnswer((_) async => const []);
    });

    test('por defecto pide las emitidas', () async {
      await GetPurchaseOrdersUseCase(repository: repository).execute();
      verify(
        () => repository.getPurchaseOrders(status: PurchaseOrderStatus.issued),
      ).called(1);
    });

    test('null lista todas', () async {
      await GetPurchaseOrdersUseCase(repository: repository).execute(status: null);
      verify(() => repository.getPurchaseOrders()).called(1);
    });
  });

  test('ObserveStockAlerts convierte los repuestos en alertas', () async {
    when(() => repository.observeLowStock()).thenAnswer(
      (_) => Stream.value([
        Part(
          id: 'p1',
          name: 'Filtro',
          sku: 'FLT-001',
          totalStock: Decimal.one,
          minimumStock: Decimal.fromInt(3),
        ),
      ]),
    );

    final alerts = await ObserveStockAlertsUseCase(
      repository: repository,
    ).execute().first;

    expect(alerts.single.itemId, 'p1');
    expect(alerts.single.deficit, Decimal.fromInt(2));
  });
}
