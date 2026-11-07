import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/inventory_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../tasks/support/tasks_test_env.dart';

export '../../tasks/support/tasks_test_env.dart'
    show Responder, apiError, jsonResponse, offline;

const itemsPath = '/api/v1/inventory/items';
const alertsPath = '/api/v1/inventory/alerts';
const ordersPath = '/api/v1/inventory/purchase-orders';

class RecordingUploader extends FakeUploader {
  final List<String> uploadedPaths = [];
  final List<File> uploadedFiles = [];
  Exception? failure;

  @override
  Future<void> upload(File file, String storagePath) async {
    uploadedFiles.add(file);
    final error = failure;
    if (error != null) throw error;
    uploadedPaths.add(storagePath);
  }
}

class InventoryTestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session;
  final Map<String, Responder> responses = {};
  final List<http.Request> requests = [];
  final RecordingUploader uploader = RecordingUploader();
  late final Directory tempDir;

  DateTime clock = DateTime.utc(2026, 11, 7, 14);

  InventoryTestEnv._(this.session);

  static Future<InventoryTestEnv> create() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final env = InventoryTestEnv._(SessionManager());
    env.tempDir = await Directory.systemTemp.createTemp('inventory_test_');
    return env;
  }

  late final InventoryApi api = InventoryApi(
    client: ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        final key = '${request.method} ${request.url.path}';
        final respond =
            responses[key] ?? (_) => apiError(500, 'No configurado: $key');
        return respond(request);
      }),
      baseUrl: 'http://api',
    ),
  );

  late final InventoryRepository repository = InventoryRepositoryImpl(
    api: api,
    partDao: db.partDao,
    batchDao: db.batchDao,
    cacheMetadataDao: db.cacheMetadataDao,
    uploader: uploader,
    session: session,
    cacheDirectory: () async => tempDir,
    now: () => clock,
  );

  Future<void> signIn({
    List<Permission> permissions = const [
      Permission.partsRead,
      Permission.batchesRead,
      Permission.batchesReceive,
      Permission.purchaseOrdersRead,
      Permission.alertsRead,
    ],
  }) {
    return session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'almacen@taller.pe',
        'fullName': 'Ana Almacén',
        'token': 'jwt_token',
        'tokenType': 'Bearer',
        'permissions': [for (final p in permissions) p.value],
        'refreshToken': 'refresh_token',
        'membershipId': 'm1',
        'activeTenant': {'id': 't1', 'name': 'Taller', 'taxId': '20123456789'},
        'plan': null,
      }),
    );
  }

  List<http.Request> requested(String method, String path) {
    return requests
        .where((r) => r.method == method && r.url.path == path)
        .toList();
  }

  /// Archivos que quedaron en la carpeta temporal de comprobantes.
  List<FileSystemEntity> receiptTemps() {
    final directory = Directory('${tempDir.path}/receipts');
    return directory.existsSync() ? directory.listSync() : const [];
  }

  Future<File> photo() async {
    final file = File('${tempDir.path}/photo.jpg');
    await file.writeAsBytes([1, 2, 3]);
    return file;
  }

  Future<void> close() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  }
}

Map<String, Object?> partJson({
  String id = 'p1',
  String name = 'Filtro de aceite',
  String sku = 'FLT-001',
  String category = 'FILTERS',
  num? basePrice = 25.5,
  num? totalStock = 10,
  num? minimumStock = 2,
  String status = 'ACTIVE',
}) {
  return {
    'id': id,
    'tenantId': 't1',
    'name': name,
    'sku': sku,
    'category': category,
    'basePrice': basePrice,
    'totalStock': totalStock,
    'minimumStock': minimumStock,
    'unitOfMeasure': 'UNIT',
    'status': status,
  };
}

Map<String, Object?> batchJson({
  String id = 'l1',
  String? itemId = 'p1',
  String batchNumber = 'L-001',
  num remainingQty = 5,
  num unitCost = 10.5,
  String? arrivalDate = '2026-10-01T10:00:00Z',
}) {
  return {
    'id': id,
    'itemId': itemId,
    'supplierId': 's1',
    'purchaseOrderId': 'po1',
    'batchNumber': batchNumber,
    'initialQty': 10,
    'remainingQty': remainingQty,
    'unitCost': unitCost,
    'arrivalDate': arrivalDate,
    'receiptImageUrl': 'https://p.supabase.co/r.jpg',
  };
}

Map<String, Object?> orderJson({
  String id = 'po1',
  String status = 'ISSUED',
  List<String> itemIds = const ['p1'],
}) {
  return {
    'id': id,
    'tenantId': 't1',
    'supplierId': 's1',
    'branchId': 'b1',
    'orderNumber': 'OC-001',
    'status': status,
    'totalCost': 100,
    'items': [
      for (final (index, itemId) in itemIds.indexed)
        {
          'id': 'line$index',
          'itemId': itemId,
          'quantity': 2,
          'unitCost': 50,
          'totalCost': 100,
        },
    ],
  };
}

Matcher isApiError(int status) {
  return isA<ApiException>().having((e) => e.httpStatus, 'httpStatus', status);
}
