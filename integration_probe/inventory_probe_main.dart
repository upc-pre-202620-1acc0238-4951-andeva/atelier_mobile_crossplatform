import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/find_part_by_sku_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_inventory_valuation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_part_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/search_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Prueba del paso 7 con Drift y compresión reales, contra `tool/sync_mock_server.dart`. No se publica.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final session = getIt<SessionManager>();
  await session.clearIfReinstalled();

  if (await session.getSession() == null) {
    final seed = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/control/session'),
    );
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(utf8.decode(seed.bodyBytes))),
    );
    debugPrint('PROBE sesión sembrada');
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('En linea', _guarded(_online)),
              _button('Sin red', _guarded(_offline)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _button(String label, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      height: 96,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    ),
  );
}

VoidCallback _guarded(Future<void> Function() run) {
  return () async {
    try {
      await run();
    } catch (error, stack) {
      debugPrint('PROBE FALLA excepción $error\n$stack');
    }
  };
}

void _check(String name, bool passed, [Object? detail]) {
  debugPrint('PROBE ${passed ? 'OK' : 'FALLA'} $name ${detail ?? ''}');
}

Future<Map<String, dynamic>> _stats() async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/control/inventory'),
  );
  return jsonDecode(response.body) as Map<String, dynamic>;
}

/// Pasa por la compresión real: `FakeUploader` solo existe en las pruebas unitarias.
Future<File> _photo() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 2400, 1800),
    ui.Paint()..color = const ui.Color(0xFF3366AA),
  );
  final image = await recorder.endRecording().toImage(2400, 1800);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/comprobante.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file;
}

Future<int> _receiptTemps() async {
  final directory = Directory('${(await getTemporaryDirectory()).path}/receipts');
  return directory.existsSync() ? directory.listSync().length : 0;
}

Future<void> _online() async {
  await _catalog();
  await _detail();
  await _receive();
  debugPrint('PROBE en linea terminado');
}

Future<void> _catalog() async {
  final refresh = getIt<RefreshPartsCatalogUseCase>();
  await refresh.execute(force: true);
  final observe = getIt<ObservePartsCatalogUseCase>();
  final all = await observe.execute().first;
  final requests = (await _stats())['catalogRequests'];
  _check('catalogo por paginas', all.length == 130, '${all.length} filas');

  await refresh.execute();
  final after = (await _stats())['catalogRequests'];
  _check('vigencia evita otra recarga', after == requests, '$requests → $after');

  final brakes = await observe.execute(category: ItemCategory.brakes).first;
  _check('filtro por categoria', brakes.length == 65, brakes.length);

  final search = getIt<SearchPartsCatalogUseCase>();
  final found = await search.execute(' inv-00 ');
  _check('busqueda en linea', found.length == 10, found.length);

  final bySku = getIt<FindPartBySkuUseCase>();
  final part = await bySku.execute('inv-001');
  _check('SKU normalizado', part?.id == 'ip1', part?.name);
  _check('SKU 404 sin cuerpo', await bySku.execute('NOPE-999') == null);
  try {
    await bySku.execute('a b');
    _check('SKU invalido', false, 'no falló');
  } on InvalidInventoryInputException catch (e) {
    _check('SKU invalido', e.field == 'sku', e.field);
  }

  final alerts = await getIt<GetStockAlertsUseCase>().execute();
  _check('alertas del backend', alerts.single.itemId == 'ip1', alerts.length);
  final fromCache = await getIt<ObserveStockAlertsUseCase>().execute().first;
  _check(
    'alertas de la caché con "9" frente a "10"',
    fromCache.length == 1 &&
        fromCache.single.itemId == 'ip1' &&
        fromCache.single.deficit == Decimal.one,
    fromCache.length,
  );

  final valuation = await getIt<GetInventoryValuationUseCase>().execute();
  _check(
    'valorizacion',
    valuation.total.amount == Decimal.parse('12345.67'),
    '${valuation.total.amount} ${valuation.total.currency}',
  );
}

Future<void> _detail() async {
  final detail = await getIt<GetPartDetailUseCase>().execute('ip1');
  final order = detail.batches.map((b) => b.batchNumber).toList();
  _check(
    'detalle FIFO',
    order.join(',') == 'L-1,L-2,L-3',
    order,
  );
  _check(
    'agotados marcados',
    !detail.batches.first.isActive && detail.batches.last.isActive,
  );

  await getIt<RefreshPartBatchesUseCase>().execute('ip1', force: true);
  final cached = await getIt<ObservePartBatchesUseCase>().execute('ip1').first;
  _check(
    'lotes de la caché FIFO y sin campos de red',
    cached.first.batchNumber == 'L-1' && cached.first.initialQty == null,
    cached.map((b) => b.batchNumber).toList(),
  );
}

Future<void> _receive() async {
  final issued = await getIt<GetPurchaseOrdersUseCase>().execute();
  _check('ordenes emitidas', issued.length == 3, issued.map((o) => o.id).toList());
  final all = await getIt<GetPurchaseOrdersUseCase>().execute(status: null);
  _check('todas las ordenes', all.length == 4, all.length);

  final receive = getIt<ReceivePurchaseOrderUseCase>();
  final photo = await _photo();
  final uploads = (await _stats())['uploads'] as int;

  final first = await receive.execute(
    'po1',
    receiptNumber: ' F001-23 ',
    photo: photo,
    receivedAt: DateTime.now().toUtc(),
  );
  var stats = await _stats();
  _check(
    'recibir sube la foto comprimida',
    first.status == PurchaseOrderStatus.received && stats['uploads'] == uploads + 1,
    'uploads=${stats['uploads']}',
  );
  _check('temporal borrado', await _receiptTemps() == 0);

  final alerts = await getIt<ObserveStockAlertsUseCase>().execute().first;
  _check('la alerta sale de la caché (US34 E2)', alerts.isEmpty, alerts.length);
  final batches = await getIt<ObservePartBatchesUseCase>().execute('ip1').first;
  _check(
    'lote nuevo en la caché',
    batches.any((b) => b.batchNumber == 'L-po1'),
    batches.map((b) => b.batchNumber).toList(),
  );

  final again = await receive.execute('po1', receiptNumber: 'F001-23', photo: photo);
  stats = await _stats();
  _check(
    'H15 ya recibida no sube otra foto',
    again.status == PurchaseOrderStatus.received && stats['uploads'] == uploads + 1,
    'uploads=${stats['uploads']}',
  );

  final applied = await receive.execute('po2', receiptNumber: 'F002', photo: photo);
  _check(
    'H15 400 con relectura RECEIVED es éxito',
    applied.status == PurchaseOrderStatus.received,
  );

  try {
    await receive.execute('po3', receiptNumber: 'F003', photo: photo);
    _check('borrador no se recibe', false, 'no falló');
  } on PurchaseOrderNotReceivableException catch (e) {
    _check('borrador no se recibe', e.status == PurchaseOrderStatus.draft);
  }

  try {
    await receive.execute('po4', receiptNumber: 'F004', photo: photo);
    _check('H15 400 real', false, 'no falló');
  } on ApiException catch (e) {
    _check('H15 400 real con su message', e.httpStatus == 400, e.message);
  }
}

Future<void> _offline() async {
  final catalog = await getIt<ObservePartsCatalogUseCase>().execute().first;
  _check('catalogo visible sin red', catalog.length == 130, catalog.length);

  try {
    await getIt<RefreshPartsCatalogUseCase>().execute(force: true);
    _check('refresh sin red', false, 'no falló');
  } on NetworkException {
    final kept = await getIt<ObservePartsCatalogUseCase>().execute().first;
    _check('refresh sin red conserva la caché', kept.length == 130, kept.length);
  }

  final found = await getIt<SearchPartsCatalogUseCase>().execute('repuesto 00');
  _check('busqueda en la caché', found.length == 10, found.length);
  final part = await getIt<FindPartBySkuUseCase>().execute('inv-001');
  _check('SKU en la caché', part?.id == 'ip1', part?.name);

  final detail = await getIt<GetPartDetailUseCase>().execute('ip1');
  _check(
    'detalle desde la caché FIFO',
    detail.batches.first.batchNumber == 'L-1',
    detail.batches.map((b) => b.batchNumber).toList(),
  );

  final alerts = await getIt<GetStockAlertsUseCase>().execute();
  _check('alertas derivadas de la caché', alerts.isEmpty, alerts.length);

  try {
    await getIt<GetInventoryValuationUseCase>().execute();
    _check('valorizacion sin red', false, 'no falló');
  } on NetworkException catch (e) {
    _check('valorizacion sin red', true, e.message);
  }

  try {
    await getIt<ReceivePurchaseOrderUseCase>().execute(
      'po4',
      receiptNumber: 'F005',
      photo: await _photo(),
    );
    _check('recibir sin red', false, 'no falló');
  } on NetworkException catch (e) {
    _check('recibir sin red no se encola', await _receiptTemps() == 0, e.message);
  }
  debugPrint('PROBE sin red terminado');
}
