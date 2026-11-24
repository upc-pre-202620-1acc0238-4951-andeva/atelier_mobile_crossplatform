import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/inventory_test_env.dart';

const _suppliersPath = '/api/v1/inventory/suppliers';
const _receivePath = '/api/v1/inventory/batches/receive';
const _dispatchPath = '/api/v1/inventory/batches/dispatch';
const _restorePath = '/api/v1/inventory/batches/restore';

Map<String, dynamic> _body(InventoryTestEnv env, String method, String path) {
  return jsonDecode(env.requested(method, path).single.body)
      as Map<String, dynamic>;
}

void main() {
  late InventoryTestEnv env;

  setUp(() async => env = await InventoryTestEnv.create());
  tearDown(() => env.close());

  group('repuestos', () {
    test('createPart normaliza el SKU, manda UNIT por defecto y guarda en la caché', () async {
      await env.signIn();
      env.responses['POST $itemsPath'] = (_) =>
          jsonResponse(partJson(id: 'p9', sku: 'FLT-009'), 201);

      final part = await env.repository.createPart(
        name: '  Filtro de aire ',
        sku: ' flt-009 ',
        category: ItemCategory.filters,
        basePrice: Decimal.parse('25.5'),
        minimumStock: Decimal.fromInt(3),
      );

      expect(_body(env, 'POST', itemsPath), {
        'name': 'Filtro de aire',
        'sku': 'FLT-009',
        'category': 'FILTERS',
        'basePrice': 25.5,
        'minimumStock': 3.0,
        'unitOfMeasure': 'UNIT',
      });
      expect(part.id, 'p9');
      expect(await env.repository.observePart('p9').first, isNotNull);
    });

    test('updatePart omite el estado y la unidad si no se envían', () async {
      await env.signIn();
      env.responses['PUT $itemsPath/p1'] = (_) =>
          jsonResponse(partJson(name: 'Nuevo', status: 'INACTIVE'));

      final part = await env.repository.updatePart(
        'p1',
        name: ' Nuevo ',
        category: ItemCategory.brakes,
        basePrice: Decimal.fromInt(10),
        minimumStock: Decimal.one,
        status: PartStatus.inactive,
      );

      expect(_body(env, 'PUT', '$itemsPath/p1'), {
        'name': 'Nuevo',
        'category': 'BRAKES',
        'basePrice': 10.0,
        'minimumStock': 1.0,
        'status': 'INACTIVE',
      });
      expect(part.status, PartStatus.inactive);
    });

    test('sin red createPart lanza NetworkException', () async {
      await env.signIn();
      env.responses['POST $itemsPath'] = offline;

      await expectLater(
        env.repository.createPart(
          name: 'Filtro',
          sku: 'FLT-001',
          category: ItemCategory.filters,
          basePrice: Decimal.one,
          minimumStock: Decimal.zero,
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('lotes', () {
    setUp(() async {
      await env.signIn(
        permissions: const [
          Permission.partsRead,
          Permission.batchesRead,
          Permission.batchesReceive,
        ],
      );
      env.responses['GET $itemsPath/p1'] = (_) => jsonResponse({
        ...partJson(totalStock: 15),
        'batches': [batchJson(id: 'l9', remainingQty: 5)],
      });
    });

    test(
      'receiveDirectBatch envía el ingreso y recarga la ficha y los lotes',
      () async {
        env.responses['POST $_receivePath'] = (_) =>
            jsonResponse(batchJson(id: 'l9', batchNumber: 'L-009'), 201);

        final batch = await env.repository.receiveDirectBatch(
          'p1',
          batchNumber: ' L-009 ',
          quantity: Decimal.fromInt(5),
          unitCost: Decimal.parse('10.5'),
          arrivalDate: DateTime.utc(2026, 11, 1, 8),
          supplierId: ' ',
        );

        expect(_body(env, 'POST', _receivePath), {
          'itemId': 'p1',
          'batchNumber': 'L-009',
          'quantity': 5.0,
          'unitCost': 10.5,
          'arrivalDate': '2026-11-01T08:00:00.000Z',
        });
        expect(batch.id, 'l9');
        expect(env.requested('GET', '$itemsPath/p1'), hasLength(1));
        expect(await env.repository.observeBatches('p1').first, hasLength(1));
        expect(
          (await env.repository.observePart('p1').first)?.totalStock,
          Decimal.fromInt(15),
        );
      },
    );

    test(
      'un fallo al recargar no vuelve un error el ingreso ya hecho',
      () async {
        env.responses['POST $_receivePath'] = (_) =>
            jsonResponse(batchJson(id: 'l9'), 201);
        env.responses['GET $itemsPath/p1'] = (_) => apiError(500);

        final batch = await env.repository.receiveDirectBatch(
          'p1',
          batchNumber: 'L-009',
          quantity: Decimal.one,
          unitCost: Decimal.one,
        );

        expect(batch.id, 'l9');
      },
    );

    test(
      'dispatchFifoBatch devuelve la asignación con sus deducciones',
      () async {
        env.responses['POST $_dispatchPath'] = (_) => jsonResponse({
          'allocationId': 'a1',
          'allocatedQuantity': 3,
          'totalCogs': 31.5,
          'deductions': [
            {
              'batchId': 'l1',
              'quantityDeducted': 3,
              'unitCost': 10.5,
              'subtotal': 31.5,
            },
          ],
        });

        final allocation = await env.repository.dispatchFifoBatch(
          'p1',
          quantity: Decimal.fromInt(3),
          workOrderId: 'w1',
          taskId: ' ',
        );

        expect(_body(env, 'POST', _dispatchPath), {
          'itemId': 'p1',
          'quantity': 3.0,
          'workOrderId': 'w1',
        });
        expect(allocation.allocationId, 'a1');
        expect(allocation.totalCogs?.amount, Decimal.parse('31.5'));
        expect(allocation.deductions.single.batchId, 'l1');
      },
    );

    test('restoreBatch manda solo lo informado', () async {
      env.responses['POST $_restorePath'] = (_) => jsonResponse({
        'status': 'OK',
        'message': 'Restaurado',
        'batchId': 'l1',
        'restoredQuantity': 2,
      });

      final result = await env.repository.restoreBatch(
        'p1',
        quantity: Decimal.fromInt(2),
        reason: ' Sobró ',
      );

      expect(_body(env, 'POST', _restorePath), {
        'itemId': 'p1',
        'quantity': 2.0,
        'reason': 'Sobró',
      });
      expect(result.restoredQuantity, Decimal.fromInt(2));
      expect(result.batchId, 'l1');
    });
  });

  group('proveedores', () {
    Map<String, Object?> supplier({String? contact = '  '}) => {
      'id': 's1',
      'businessName': 'Repuestos SAC',
      'taxId': '20123456789',
      'contactName': contact,
      'active': null,
    };

    test(
      'getSuppliers manda la búsqueda recortada y mapea los vacíos a null',
      () async {
        await env.signIn();
        env.responses['GET $_suppliersPath'] = (_) =>
            jsonResponse([supplier()]);

        final suppliers = await env.repository.getSuppliers(
          search: ' rep ',
          status: '',
        );

        final request = env.requested('GET', _suppliersPath).single;
        expect(request.url.queryParameters, {'search': 'rep'});
        expect(suppliers.single.contactName, isNull);
        expect(suppliers.single.active, isTrue);
      },
    );

    test('createSupplier recorta y omite los opcionales vacíos', () async {
      await env.signIn();
      env.responses['POST $_suppliersPath'] = (_) =>
          jsonResponse(supplier(contact: 'Luis'), 201);

      await env.repository.createSupplier(
        businessName: ' Repuestos SAC ',
        taxId: ' 20123456789 ',
        contactName: 'Luis',
        phone: ' ',
      );

      expect(_body(env, 'POST', _suppliersPath), {
        'businessName': 'Repuestos SAC',
        'taxId': '20123456789',
        'contactName': 'Luis',
      });
    });

    test('updateSupplier manda active=false', () async {
      await env.signIn();
      env.responses['PUT $_suppliersPath/s1'] = (_) => jsonResponse(supplier());

      await env.repository.updateSupplier('s1', active: false);

      expect(_body(env, 'PUT', '$_suppliersPath/s1'), {'active': false});
    });
  });

  group('órdenes de compra', () {
    test(
      'createPurchaseOrder sin sede lanza MissingBranchException sin llamar',
      () async {
        await env.signIn();

        await expectLater(
          env.repository.createPurchaseOrder('s1'),
          throwsA(isA<MissingBranchException>()),
        );
        expect(env.requests, isEmpty);
      },
    );

    test(
      'createPurchaseOrder manda la sede de la sesión y las líneas',
      () async {
        await env.signIn();
        await env.session.updateAssignment('b1', null);
        env.responses['POST $ordersPath'] = (_) =>
            jsonResponse(orderJson(status: 'DRAFT'), 201);

        final order = await env.repository.createPurchaseOrder(
          's1',
          items: [
            PurchaseOrderLineInput(
              itemId: 'p1',
              quantity: Decimal.fromInt(2),
              unitCost: Decimal.fromInt(50),
            ),
          ],
          orderNumber: ' OC-9 ',
          expectedDeliveryDate: '2026-12-01',
          notes: ' ',
        );

        expect(_body(env, 'POST', ordersPath), {
          'branchId': 'b1',
          'supplierId': 's1',
          'items': [
            {'itemId': 'p1', 'quantity': 2.0, 'unitCost': 50.0},
          ],
          'orderNumber': 'OC-9',
          'expectedDeliveryDate': '2026-12-01',
        });
        expect(order.isDraft, isTrue);
      },
    );

    test('addPurchaseOrderItem, issue y cancel usan sus rutas', () async {
      await env.signIn();
      env.responses['POST $ordersPath/po1/items'] = (_) =>
          jsonResponse(orderJson(status: 'DRAFT'));
      env.responses['PUT $ordersPath/po1/issue'] = (_) =>
          jsonResponse(orderJson());
      env.responses['PUT $ordersPath/po1/cancel'] = (_) =>
          jsonResponse(orderJson(status: 'CANCELED'));

      await env.repository.addPurchaseOrderItem(
        'po1',
        itemId: 'p1',
        quantity: Decimal.one,
        unitCost: Decimal.fromInt(5),
      );
      final issued = await env.repository.issuePurchaseOrder('po1');
      final canceled = await env.repository.cancelPurchaseOrder(
        'po1',
        reason: ' Duplicada ',
      );

      expect(_body(env, 'POST', '$ordersPath/po1/items'), {
        'itemId': 'p1',
        'quantity': 1.0,
        'unitCost': 5.0,
      });
      expect(issued.canBeReceived, isTrue);
      expect(_body(env, 'PUT', '$ordersPath/po1/cancel'), {
        'reason': 'Duplicada',
      });
      expect(canceled.status, PurchaseOrderStatus.canceled);
      expect(
        env.requested('PUT', '$ordersPath/po1/issue').single.body,
        isEmpty,
      );
    });

    test('cancelPurchaseOrder sin motivo manda un cuerpo vacío', () async {
      await env.signIn();
      env.responses['PUT $ordersPath/po1/cancel'] = (_) =>
          jsonResponse(orderJson(status: 'CANCELED'));

      await env.repository.cancelPurchaseOrder('po1');

      expect(_body(env, 'PUT', '$ordersPath/po1/cancel'), isEmpty);
    });
  });
}
