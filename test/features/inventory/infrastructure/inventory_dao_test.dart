import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

PartEntity _part(
  String id, {
  String name = 'Filtro',
  String sku = 'FLT-001',
  String category = 'FILTERS',
  String stock = '5',
  String minimum = '2',
}) {
  return PartEntity(
    id: id,
    name: name,
    sku: sku,
    category: category,
    basePrice: '10',
    totalStock: stock,
    minimumStock: minimum,
    unitOfMeasure: 'UNIT',
    status: 'ACTIVE',
    syncedAt: 1,
  );
}

BatchEntity _batch(String id, String itemId, int arrivalDate) {
  return BatchEntity(
    id: id,
    itemId: itemId,
    batchNumber: id,
    remainingQty: '1',
    unitCost: '1',
    arrivalDate: arrivalDate,
    syncedAt: 1,
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('PartDao', () {
    test('las alertas comparan números, no texto ("10" frente a "9")', () async {
      await db.partDao.upsertAll([
        _part('alto', stock: '10', minimum: '9'),
        _part('bajo', stock: '9', minimum: '10'),
        _part('igual', stock: '2.50', minimum: '2.5'),
      ]);

      final low = await db.partDao.findLowStock();

      expect(low.map((p) => p.id), unorderedEquals(['bajo', 'igual']));
    });

    test('watchLowStock se vacía cuando el stock sube', () async {
      await db.partDao.upsertAll([_part('p1', stock: '1', minimum: '2')]);
      final stream = db.partDao.watchLowStock();
      expect((await stream.first).single.id, 'p1');

      await db.partDao.upsertAll([_part('p1', stock: '20', minimum: '2')]);

      expect(await stream.first, isEmpty);
    });

    test('replaceAll borra lo que ya no llega', () async {
      await db.partDao.upsertAll([_part('viejo'), _part('p1')]);

      await db.partDao.replaceAll([_part('p1'), _part('p2')]);

      final rows = await db.partDao.watchAll().first;
      expect(rows.map((p) => p.id), unorderedEquals(['p1', 'p2']));
    });

    test('watchAll filtra por categoría y ordena por nombre', () async {
      await db.partDao.upsertAll([
        _part('b', name: 'Bujía', category: 'ENGINE'),
        _part('z', name: 'Zapata', category: 'BRAKES'),
        _part('a', name: 'Abrazadera', category: 'BRAKES'),
      ]);

      final brakes = await db.partDao.watchAll(category: 'BRAKES').first;
      expect(brakes.map((p) => p.id), ['a', 'z']);
      final all = await db.partDao.watchAll().first;
      expect(all.map((p) => p.id), ['a', 'b', 'z']);
    });

    test('search busca en nombre o SKU sin distinguir mayúsculas', () async {
      await db.partDao.upsertAll([
        _part('p1', name: 'Pastilla de freno', sku: 'BRK-001', category: 'BRAKES'),
        _part('p2', name: 'Aceite', sku: 'OIL-FRE', category: 'LUBRICANTS'),
        _part('p3', name: 'Filtro', sku: 'FLT-001'),
      ]);

      final all = await db.partDao.search('FRE');
      expect(all.map((p) => p.id), unorderedEquals(['p1', 'p2']));
      final brakes = await db.partDao.search('fre', category: 'BRAKES');
      expect(brakes.single.id, 'p1');
    });

    test('search corta en 100 filas', () async {
      await db.partDao.upsertAll([
        for (var i = 0; i < 120; i++) _part('p$i', sku: 'SKU-$i'),
      ]);

      expect(await db.partDao.search('filtro'), hasLength(100));
    });

    test('findBySku con SKU repetido no lanza', () async {
      await db.partDao.upsertAll([_part('p1'), _part('p2')]);

      expect(await db.partDao.findBySku('FLT-001'), isNotNull);
      expect(await db.partDao.findBySku('NOPE'), isNull);
    });
  });

  group('BatchDao', () {
    test('ordena FIFO: el más antiguo primero', () async {
      await db.batchDao.replaceForItem('p1', [
        _batch('nuevo', 'p1', 300),
        _batch('viejo', 'p1', 100),
        _batch('medio', 'p1', 200),
      ]);

      final rows = await db.batchDao.findForItem('p1');
      expect(rows.map((b) => b.id), ['viejo', 'medio', 'nuevo']);
    });

    test('replaceForItem no toca los lotes de otro repuesto', () async {
      await db.batchDao.replaceForItem('p1', [_batch('l1', 'p1', 1)]);
      await db.batchDao.replaceForItem('p2', [_batch('l2', 'p2', 1)]);

      await db.batchDao.replaceForItem('p1', [_batch('l3', 'p1', 2)]);

      expect((await db.batchDao.findForItem('p1')).single.id, 'l3');
      expect((await db.batchDao.findForItem('p2')).single.id, 'l2');
    });
  });

  test('cerrar sesión borra parts y batches', () async {
    await db.partDao.upsertAll([_part('p1')]);
    await db.batchDao.replaceForItem('p1', [_batch('l1', 'p1', 1)]);

    await db.cacheMaintenanceDao.clearCaches();

    expect(await db.partDao.findById('p1'), isNull);
    expect(await db.batchDao.findForItem('p1'), isEmpty);
  });
}
