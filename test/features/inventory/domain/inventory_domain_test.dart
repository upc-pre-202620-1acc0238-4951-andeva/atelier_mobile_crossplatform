import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

Part _part({String stock = '5', String minimum = '2', PartStatus? status}) {
  return Part(
    id: 'p1',
    name: 'Filtro',
    sku: 'FLT-001',
    totalStock: Decimal.parse(stock),
    minimumStock: Decimal.parse(minimum),
    status: status,
  );
}

void main() {
  group('Part', () {
    test('isLowStock incluye el mínimo exacto', () {
      expect(_part(stock: '2', minimum: '2').isLowStock, isTrue);
      expect(_part(stock: '1.99', minimum: '2').isLowStock, isTrue);
      expect(_part(stock: '2.01', minimum: '2').isLowStock, isFalse);
    });

    test('isSelectable exige saldo y que no esté inactivo ni descontinuado', () {
      expect(_part(status: PartStatus.active).isSelectable, isTrue);
      expect(_part().isSelectable, isTrue);
      expect(_part(status: PartStatus.inactive).isSelectable, isFalse);
      expect(_part(status: PartStatus.discontinued).isSelectable, isFalse);
      expect(_part(stock: '0', status: PartStatus.active).isSelectable, isFalse);
    });

    test('isOutOfStock con saldo cero o negativo', () {
      expect(_part(stock: '0').isOutOfStock, isTrue);
      expect(_part(stock: '-1').isOutOfStock, isTrue);
      expect(_part(stock: '0.5').isOutOfStock, isFalse);
    });

    test('toStockAlert calcula lo que falta y nunca da negativo', () {
      expect(
        _part(stock: '1', minimum: '2.5').toStockAlert().deficit,
        Decimal.parse('1.5'),
      );
      expect(_part(stock: '9', minimum: '2').toStockAlert().deficit, Decimal.zero);
    });
  });

  test('PartBatch.isActive solo con saldo', () {
    PartBatch batch(String remaining) => PartBatch(
      id: 'l1',
      itemId: 'p1',
      batchNumber: 'L',
      remainingQty: Decimal.parse(remaining),
    );
    expect(batch('1').isActive, isTrue);
    expect(batch('0').isActive, isFalse);
  });

  test('PurchaseOrder solo se recibe en ISSUED', () {
    PurchaseOrder order(PurchaseOrderStatus? status) =>
        PurchaseOrder(id: 'po1', status: status, lines: const []);
    expect(order(PurchaseOrderStatus.issued).canBeReceived, isTrue);
    expect(order(PurchaseOrderStatus.draft).canBeReceived, isFalse);
    expect(order(PurchaseOrderStatus.received).canBeReceived, isFalse);
    expect(order(null).canBeReceived, isFalse);
  });

  test('los enums dan null con un valor desconocido', () {
    expect(ItemCategory.fromString('BRAKES'), ItemCategory.brakes);
    expect(ItemCategory.fromString('Filtros'), isNull);
    expect(PartStatus.fromString(''), isNull);
    expect(PurchaseOrderStatus.fromString('NUEVO'), isNull);
  });

  group('InventoryValidation', () {
    test('isSku normaliza y aplica el formato del backend', () {
      expect(InventoryValidation.isSku(' flt-001 '), isTrue);
      expect(InventoryValidation.isSku('AB'), isFalse);
      expect(InventoryValidation.isSku('FLT 001'), isFalse);
      expect(InventoryValidation.isSku('A' * 50), isTrue);
      expect(InventoryValidation.isSku('A' * 51), isFalse);
    });

    test('isReceivedAt admite ahora y rechaza el futuro', () {
      final now = DateTime.utc(2026, 11, 7);
      expect(InventoryValidation.isReceivedAt(null, now), isTrue);
      expect(InventoryValidation.isReceivedAt(now, now), isTrue);
      expect(
        InventoryValidation.isReceivedAt(
          now.add(const Duration(seconds: 1)),
          now,
        ),
        isFalse,
      );
    });
  });
}
