import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../support/inventory_test_env.dart';

void main() {
  late InventoryTestEnv env;

  setUp(() async => env = await InventoryTestEnv.create());
  tearDown(() => env.close());

  List<Map<String, Object?>> parts(int count, {int from = 0}) {
    return [
      for (var i = from; i < from + count; i++)
        partJson(id: 'p$i', sku: 'SKU-$i'),
    ];
  }

  group('refreshCatalog', () {
    test('pide páginas de 100 hasta recibir menos y guarda todo', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (request) {
        final page = int.parse(request.url.queryParameters['page']!);
        expect(request.url.queryParameters['size'], '100');
        return jsonResponse(parts(page == 0 ? 100 : 3, from: page * 100));
      };

      await env.repository.refreshCatalog();

      expect(env.requested('GET', itemsPath), hasLength(2));
      final catalog = await env.repository.observeCatalog().first;
      expect(catalog, hasLength(103));
    });

    test('tolera un repuesto repetido entre páginas', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (request) {
        final page = int.parse(request.url.queryParameters['page']!);
        return jsonResponse(page == 0 ? parts(100) : parts(1, from: 99));
      };

      await env.repository.refreshCatalog();

      expect(await env.repository.observeCatalog().first, hasLength(100));
    });

    test('si falla una página conserva la caché y sube el error', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (_) => jsonResponse(parts(2));
      await env.repository.refreshCatalog();

      env.responses['GET $itemsPath'] = (request) {
        return request.url.queryParameters['page'] == '0'
            ? jsonResponse(parts(100, from: 50))
            : apiError(500);
      };

      await expectLater(
        env.repository.refreshCatalog(force: true),
        throwsA(isApiError(500)),
      );
      final catalog = await env.repository.observeCatalog().first;
      expect(catalog.map((p) => p.id), unorderedEquals(['p0', 'p1']));
    });

    test('respeta la vigencia de 1 h salvo force', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (_) => jsonResponse(parts(1));

      await env.repository.refreshCatalog();
      await env.repository.refreshCatalog();
      expect(env.requested('GET', itemsPath), hasLength(1));

      await env.repository.refreshCatalog(force: true);
      expect(env.requested('GET', itemsPath), hasLength(2));

      env.clock = env.clock.add(const Duration(minutes: 59));
      await env.repository.refreshCatalog();
      expect(env.requested('GET', itemsPath), hasLength(2));

      env.clock = env.clock.add(const Duration(minutes: 1));
      await env.repository.refreshCatalog();
      expect(env.requested('GET', itemsPath), hasLength(3));
    });

    test('sin permiso no llama', () async {
      await env.signIn(permissions: const []);

      await env.repository.refreshCatalog();

      expect(env.requests, isEmpty);
    });

    test('sin sesión lanza StateError', () async {
      await expectLater(
        env.repository.refreshCatalog(),
        throwsA(isA<StateError>()),
      );
    });

    test('mapea los campos del repuesto', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (_) => jsonResponse([
        partJson(status: 'DISCONTINUED', category: 'OTRA', basePrice: null),
      ]);

      await env.repository.refreshCatalog();

      final part = (await env.repository.observeCatalog().first).single;
      expect(part.status, PartStatus.discontinued);
      expect(part.category, isNull);
      expect(part.basePrice, isNull);
      expect(part.totalStock, Decimal.fromInt(10));
      expect(part.unitOfMeasure, 'UNIT');
    });
  });

  group('searchParts', () {
    test('en línea pide 50, filtra por categoría y guarda', () async {
      env.responses['GET $itemsPath'] = (_) => jsonResponse(parts(1));

      final found = await env.repository.searchParts(
        'filtro',
        category: ItemCategory.filters,
      );

      final query = env.requests.single.url.queryParameters;
      expect(query['search'], 'filtro');
      expect(query['category'], 'FILTERS');
      expect(query['size'], '50');
      expect(found.single.id, 'p0');
      expect(await env.db.partDao.findById('p0'), isNotNull);
    });

    test('sin red busca en la caché', () async {
      env.responses['GET $itemsPath'] = (_) => jsonResponse(parts(1));
      await env.repository.searchParts('');
      env.responses['GET $itemsPath'] = offline;

      expect(await env.repository.searchParts('SKU-0'), hasLength(1));
      expect(await env.repository.searchParts('nada'), isEmpty);
    });

    test('otro error sube', () async {
      env.responses['GET $itemsPath'] = (_) => apiError(403);

      await expectLater(
        env.repository.searchParts('filtro'),
        throwsA(isApiError(403)),
      );
    });
  });

  group('findBySku', () {
    const path = '$itemsPath/by-sku/FLT-001';

    test('normaliza, devuelve el repuesto y lo guarda', () async {
      env.responses['GET $path'] = (_) => jsonResponse(partJson());

      final part = await env.repository.findBySku(' flt-001 ');

      expect(part?.id, 'p1');
      expect(await env.db.partDao.findById('p1'), isNotNull);
    });

    test('404 sin cuerpo es null', () async {
      env.responses['GET $path'] = (_) => http.Response('', 404);

      expect(await env.repository.findBySku('FLT-001'), isNull);
    });

    test('sin red busca en la caché', () async {
      env.responses['GET $path'] = (_) => jsonResponse(partJson());
      await env.repository.findBySku('FLT-001');
      env.responses['GET $path'] = offline;

      expect((await env.repository.findBySku('FLT-001'))?.id, 'p1');
    });

    test('sin red y sin caché es null', () async {
      env.responses['GET $path'] = offline;

      expect(await env.repository.findBySku('FLT-001'), isNull);
    });

    test('otro error sube', () async {
      env.responses['GET $path'] = (_) => apiError(400);

      await expectLater(
        env.repository.findBySku('FLT-001'),
        throwsA(isApiError(400)),
      );
    });
  });

  group('getPartDetail', () {
    const path = '$itemsPath/p1';

    Map<String, Object?> detail() {
      return {
        ...partJson(),
        'batches': [
          batchJson(id: 'sinFecha', arrivalDate: null),
          batchJson(id: 'nuevo', arrivalDate: '2026-11-01T10:00:00Z'),
          batchJson(id: 'viejo', arrivalDate: '2026-01-01T10:00:00Z'),
        ],
      };
    }

    test('ordena FIFO, guarda repuesto y lotes, y evita otra recarga', () async {
      await env.signIn();
      env.responses['GET $path'] = (_) => jsonResponse(detail());

      final result = await env.repository.getPartDetail('p1');

      expect(result.part.id, 'p1');
      expect(result.batches.map((b) => b.id), ['viejo', 'nuevo', 'sinFecha']);
      expect(result.batches.first.initialQty, Decimal.fromInt(10));
      expect(await env.db.partDao.findById('p1'), isNotNull);
      expect(await env.db.batchDao.findForItem('p1'), hasLength(3));

      await env.repository.refreshBatches('p1');
      expect(env.requested('GET', '$path/batches'), isEmpty);
    });

    test('sin permiso de lotes va sin lotes y no toca la caché', () async {
      await env.signIn(permissions: const [Permission.partsRead]);
      env.responses['GET $path'] = (_) => jsonResponse(detail());

      final result = await env.repository.getPartDetail('p1');

      expect(result.batches, isEmpty);
      expect(await env.db.batchDao.findForItem('p1'), isEmpty);
      expect(await env.db.partDao.findById('p1'), isNotNull);
    });

    test('sin red sale de la caché en orden FIFO', () async {
      await env.signIn();
      env.responses['GET $path'] = (_) => jsonResponse(detail());
      await env.repository.getPartDetail('p1');
      env.responses['GET $path'] = offline;

      final result = await env.repository.getPartDetail('p1');

      expect(result.part.id, 'p1');
      expect(result.batches.last.id, 'nuevo');
      expect(result.batches.first.initialQty, isNull);
    });

    test('sin red y sin caché lanza NetworkException', () async {
      await env.signIn();
      env.responses['GET $path'] = offline;

      await expectLater(
        env.repository.getPartDetail('p1'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('sin red y sin permiso no muestra lotes en caché', () async {
      await env.signIn();
      env.responses['GET $path'] = (_) => jsonResponse(detail());
      await env.repository.getPartDetail('p1');
      await env.signIn(permissions: const [Permission.partsRead]);
      env.responses['GET $path'] = offline;

      expect((await env.repository.getPartDetail('p1')).batches, isEmpty);
    });
  });

  group('refreshBatches', () {
    const path = '$itemsPath/p1/batches';

    test('sin permiso no llama', () async {
      await env.signIn(permissions: const [Permission.partsRead]);

      await env.repository.refreshBatches('p1');

      expect(env.requests, isEmpty);
    });

    test('respeta la vigencia y usa el repuesto consultado si falta itemId', () async {
      await env.signIn();
      env.responses['GET $path'] = (_) => jsonResponse([batchJson(itemId: null)]);

      await env.repository.refreshBatches('p1');
      await env.repository.refreshBatches('p1');
      expect(env.requested('GET', path), hasLength(1));

      final batches = await env.repository.observeBatches('p1').first;
      expect(batches.single.isActive, isTrue);
      expect(batches.single.unitCost?.amount, Decimal.parse('10.5'));
      expect(batches.single.arrivalDate, DateTime.utc(2026, 10, 1, 10));

      await env.repository.refreshBatches('p1', force: true);
      expect(env.requested('GET', path), hasLength(2));
    });
  });

  group('alertas y valorización', () {
    test('getStockAlerts mapea la respuesta del backend', () async {
      env.responses['GET $alertsPath'] = (_) => jsonResponse([
        {
          'itemId': 'p1',
          'name': 'Filtro',
          'sku': 'FLT-001',
          'category': 'FILTERS',
          'currentStock': 1,
          'minimumStock': 3,
          'deficit': 2,
          'evaluatedAt': '2026-11-07T10:00:00Z',
        },
      ]);

      final alert = (await env.repository.getStockAlerts()).single;

      expect(alert.itemId, 'p1');
      expect(alert.category, ItemCategory.filters);
      expect(alert.deficit, Decimal.fromInt(2));
    });

    test('getStockAlerts sin red se deriva de la caché (H13)', () async {
      env.responses['GET $itemsPath'] = (_) => jsonResponse([
        partJson(id: 'bajo', totalStock: 9, minimumStock: 10),
        partJson(id: 'bien', totalStock: 10, minimumStock: 9),
      ]);
      await env.repository.searchParts('');
      env.responses['GET $alertsPath'] = offline;

      final alerts = await env.repository.getStockAlerts();

      expect(alerts.single.itemId, 'bajo');
      expect(alerts.single.deficit, Decimal.one);
    });

    test('getStockAlerts con otro error no cae a la caché', () async {
      env.responses['GET $alertsPath'] = (_) => apiError(403);

      await expectLater(
        env.repository.getStockAlerts(),
        throwsA(isApiError(403)),
      );
    });

    test('getValuation en PEN; sin valor es cero', () async {
      const path = '$itemsPath/valuation';
      env.responses['GET $path'] = (_) => jsonResponse({'valuation': 1234.56});
      final valuation = await env.repository.getValuation();
      expect(valuation.total.amount, Decimal.parse('1234.56'));
      expect(valuation.total.currency, Money.pen);

      env.responses['GET $path'] = (_) => jsonResponse({'valuation': null});
      expect((await env.repository.getValuation()).total.amount, Decimal.zero);
    });
  });

  group('órdenes de compra', () {
    test('filtra por estado y mapea las líneas', () async {
      env.responses['GET $ordersPath'] = (_) => jsonResponse([orderJson()]);

      final orders = await env.repository.getPurchaseOrders(
        status: PurchaseOrderStatus.issued,
      );

      expect(env.requests.single.url.queryParameters['status'], 'ISSUED');
      expect(orders.single.canBeReceived, isTrue);
      expect(orders.single.lines.single.itemId, 'p1');
      expect(orders.single.lines.single.quantity, Decimal.fromInt(2));
    });

    test('sin estado no envía el filtro', () async {
      env.responses['GET $ordersPath'] = (_) => jsonResponse([]);

      await env.repository.getPurchaseOrders();

      expect(env.requests.single.url.queryParameters, isEmpty);
    });
  });

  group('receivePurchaseOrder (H15)', () {
    const orderPath = '$ordersPath/po1';
    const receivePath = '$orderPath/receive';

    void stubReload() {
      env.responses['GET $itemsPath'] = (_) => jsonResponse([
        partJson(totalStock: 12),
      ]);
      env.responses['GET $itemsPath/p1/batches'] = (_) => jsonResponse([
        batchJson(),
      ]);
    }

    test('sube, recibe con cuerpo y recarga catálogo y lotes', () async {
      await env.signIn();
      stubReload();
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.responses['PUT $receivePath'] = (_) => jsonResponse(
        orderJson(status: 'RECEIVED', itemIds: ['p1', 'p1']),
      );

      final received = await env.repository.receivePurchaseOrder(
        'po1',
        'F001-23',
        await env.photo(),
        receivedAt: DateTime.utc(2026, 11, 7, 9),
      );

      expect(received.status, PurchaseOrderStatus.received);
      final path = env.uploader.uploadedPaths.single;
      expect(path, startsWith('t1/purchase-orders/po1/receipt/'));
      expect(path, endsWith('.jpg'));

      final body = jsonDecode(env.requested('PUT', receivePath).single.body);
      expect(body['receiptNumber'], 'F001-23');
      expect(body['receiptImageUrl'], env.uploader.publicUrlFor(path));
      expect(body['receivedAt'], '2026-11-07T09:00:00.000Z');

      expect(await env.db.partDao.findById('p1'), isNotNull);
      expect(env.requested('GET', '$itemsPath/p1/batches'), hasLength(1));
      expect(env.receiptTemps(), isEmpty);
      expect(env.uploader.uploadedFiles.single.existsSync(), isFalse);
    });

    test('sin receivedAt no lo envía', () async {
      await env.signIn();
      stubReload();
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.responses['PUT $receivePath'] = (_) => jsonResponse(
        orderJson(status: 'RECEIVED'),
      );

      await env.repository.receivePurchaseOrder(
        'po1',
        'F001',
        await env.photo(),
      );

      final body = jsonDecode(env.requested('PUT', receivePath).single.body);
      expect((body as Map).containsKey('receivedAt'), isFalse);
    });

    test('ya recibida es éxito sin subir nada', () async {
      await env.signIn();
      env.responses['GET $orderPath'] = (_) => jsonResponse(
        orderJson(status: 'RECEIVED'),
      );

      final order = await env.repository.receivePurchaseOrder(
        'po1',
        'F001',
        await env.photo(),
      );

      expect(order.status, PurchaseOrderStatus.received);
      expect(env.uploader.uploadedFiles, isEmpty);
      expect(env.requested('PUT', receivePath), isEmpty);
    });

    test('una orden que no está emitida no se recibe', () async {
      await env.signIn();
      env.responses['GET $orderPath'] = (_) => jsonResponse(
        orderJson(status: 'DRAFT'),
      );

      await expectLater(
        env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
        throwsA(
          isA<PurchaseOrderNotReceivableException>().having(
            (e) => e.status,
            'status',
            PurchaseOrderStatus.draft,
          ),
        ),
      );
      expect(env.uploader.uploadedFiles, isEmpty);
    });

    test('sin sesión lanza StateError antes de comprimir', () async {
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());

      await expectLater(
        env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
        throwsA(isA<StateError>()),
      );
      expect(env.uploader.uploadedFiles, isEmpty);
    });

    for (final (name, Responder failure) in <(String, Responder)>[
      ('400', (_) => apiError(400, 'Ya recibida')),
      ('corte de red', offline),
    ]) {
      test('$name con relectura RECEIVED es éxito y recarga', () async {
        await env.signIn();
        stubReload();
        var reads = 0;
        env.responses['GET $orderPath'] = (_) => jsonResponse(
          orderJson(status: reads++ == 0 ? 'ISSUED' : 'RECEIVED'),
        );
        env.responses['PUT $receivePath'] = failure;

        final order = await env.repository.receivePurchaseOrder(
          'po1',
          'F001',
          await env.photo(),
        );

        expect(order.status, PurchaseOrderStatus.received);
        expect(env.requested('GET', '$itemsPath/p1/batches'), hasLength(1));
      });

      test('$name con relectura sin recibir lanza el error original', () async {
        await env.signIn();
        env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
        env.responses['PUT $receivePath'] = failure;

        await expectLater(
          env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
          throwsA(
            name == '400' ? isApiError(400) : isA<NetworkException>(),
          ),
        );
        expect(env.requested('GET', orderPath), hasLength(2));
        expect(env.receiptTemps(), isEmpty);
      });

      test('$name con relectura fallida conserva el error original', () async {
        await env.signIn();
        var reads = 0;
        env.responses['GET $orderPath'] = (request) {
          if (reads++ == 0) return jsonResponse(orderJson());
          return apiError(500, 'Otro error');
        };
        env.responses['PUT $receivePath'] = failure;

        await expectLater(
          env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
          throwsA(
            name == '400' ? isApiError(400) : isA<NetworkException>(),
          ),
        );
      });
    }

    test('otro código del PUT no relee', () async {
      await env.signIn();
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.responses['PUT $receivePath'] = (_) => apiError(403);

      await expectLater(
        env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
        throwsA(isApiError(403)),
      );
      expect(env.requested('GET', orderPath), hasLength(1));
    });

    test('un fallo de Supabase sube tal cual, sin PUT ni relectura', () async {
      await env.signIn();
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.uploader.failure = const NetworkException();

      await expectLater(
        env.repository.receivePurchaseOrder('po1', 'F001', await env.photo()),
        throwsA(isA<NetworkException>()),
      );
      expect(env.requested('PUT', receivePath), isEmpty);
      expect(env.requested('GET', orderPath), hasLength(1));
      expect(env.receiptTemps(), isEmpty);
    });

    test('un fallo al recargar sigue siendo éxito y no corta las demás', () async {
      await env.signIn();
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.responses['PUT $receivePath'] = (_) => jsonResponse(
        orderJson(status: 'RECEIVED', itemIds: ['p1', 'p2']),
      );
      env.responses['GET $itemsPath'] = (_) => apiError(500);
      env.responses['GET $itemsPath/p1/batches'] = offline;
      env.responses['GET $itemsPath/p2/batches'] = (_) => jsonResponse([
        batchJson(id: 'l2', itemId: 'p2'),
      ]);

      final order = await env.repository.receivePurchaseOrder(
        'po1',
        'F001',
        await env.photo(),
      );

      expect(order.status, PurchaseOrderStatus.received);
      expect(await env.db.batchDao.findForItem('p2'), hasLength(1));
    });

    test('al recibir, la alerta sale de la caché (US34 E2)', () async {
      await env.signIn();
      env.responses['GET $itemsPath'] = (_) => jsonResponse([
        partJson(totalStock: 1, minimumStock: 5),
      ]);
      await env.repository.refreshCatalog();
      expect(await env.repository.observeLowStock().first, hasLength(1));

      env.responses['GET $itemsPath'] = (_) => jsonResponse([
        partJson(totalStock: 20, minimumStock: 5),
      ]);
      env.responses['GET $itemsPath/p1/batches'] = (_) => jsonResponse([]);
      env.responses['GET $orderPath'] = (_) => jsonResponse(orderJson());
      env.responses['PUT $receivePath'] = (_) => jsonResponse(
        orderJson(status: 'RECEIVED'),
      );

      await env.repository.receivePurchaseOrder(
        'po1',
        'F001',
        await env.photo(),
      );

      expect(await env.repository.observeLowStock().first, isEmpty);
    });
  });
}
