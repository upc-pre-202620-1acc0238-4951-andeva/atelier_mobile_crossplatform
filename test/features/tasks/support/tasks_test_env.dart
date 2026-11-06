import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/preferences_paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/repository/task_evidence_capture.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/task_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class MockProcessor extends Mock implements SyncProcessor {}

class MockScheduler extends Mock implements SyncScheduler {}

class FakeUploader extends SupabaseUploader {
  FakeUploader()
    : super(
        client: MockClient((_) async => http.Response('{}', 200)),
        baseUrl: 'https://p.supabase.co',
        anonKey: 'anon',
        bucket: 'atelier',
        notConfiguredMessage: '',
        uploadFailedMessage: '',
      );

  @override
  Future<File> compress(String sourcePath, File target) async {
    await target.parent.create(recursive: true);
    return File(sourcePath).copy(target.path);
  }
}

typedef Responder = http.Response Function(http.Request request);

http.Response jsonResponse(Object body, [int status = 200]) {
  return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
}

http.Response apiError(int status, [String message = 'Error del backend']) {
  return jsonResponse({'code': 'CODE', 'message': message}, status);
}

http.Response offline(http.Request request) {
  throw http.ClientException('Sin red');
}

Map<String, Object?> taskJson({
  String taskId = 't1',
  String workOrderId = 'wo1',
  int workOrderNumber = 101,
  String workOrderStatus = 'IN_PROGRESS',
  String vehicleId = 'v1',
  String? branchId = 'b1',
  String? bayId = 'bay1',
  String status = 'IN_PROGRESS',
  String description = 'Cambio de aceite y filtro',
  double estimatedHours = 2.0,
  String startedAt = '2026-11-06T10:00:00.000Z',
  int totalPausedSeconds = 0,
}) {
  return {
    'taskId': taskId,
    'workOrderId': workOrderId,
    'workOrderNumber': workOrderNumber,
    'workOrderStatus': workOrderStatus,
    'vehicleId': vehicleId,
    'branchId': branchId,
    'bayId': bayId,
    'status': status,
    'description': description,
    'estimatedHours': estimatedHours,
    'startedAt': startedAt,
    'totalPausedSeconds': totalPausedSeconds,
  };
}

Map<String, Object?> detailJson({
  String id = 't1',
  String workOrderId = 'wo1',
  String? serviceId = 'srv1',
  String serviceName = 'Mantenimiento Preventivo',
  String? mechanicId = 'm1',
  String mechanicName = 'Carlos Mecánico',
  String status = 'IN_PROGRESS',
  String description = 'Cambio de aceite y filtro',
  double price = 120.0,
  String? currency = 'PEN',
  String? holdReason,
  String? missingItemDescription,
  int totalPausedSeconds = 0,
  String? startedAt = '2026-11-06T10:00:00.000Z',
  String? completedAt,
  String? pendingSuspensionReason,
  String? pendingSuspensionRequestedAt,
  List<Map<String, Object?>> products = const [],
  List<Map<String, Object?>> evidenceImages = const [],
}) {
  return {
    'id': id,
    'workOrderId': workOrderId,
    'serviceId': serviceId,
    'serviceName': serviceName,
    'mechanicId': mechanicId,
    'mechanicName': mechanicName,
    'status': status,
    'description': description,
    'price': price,
    'currency': currency,
    'holdReason': holdReason,
    'missingItemDescription': missingItemDescription,
    'totalPausedSeconds': totalPausedSeconds,
    'startedAt': startedAt,
    'completedAt': completedAt,
    'pendingSuspensionReason': pendingSuspensionReason,
    'pendingSuspensionRequestedAt': pendingSuspensionRequestedAt,
    'products': products,
    'evidenceImages': evidenceImages,
  };
}

Map<String, Object?> productJson({
  String id = 'tp1',
  String productId = 'p1',
  String name = 'Aceite Sintético 5W-30',
  double quantity = 4.0,
  double unitPrice = 35.0,
  double totalAmount = 140.0,
  String? currency = 'PEN',
}) {
  return {
    'id': id,
    'taskId': 't1',
    'productId': productId,
    'productName': name,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalAmount': totalAmount,
    'currency': currency,
  };
}

Map<String, Object?> evidenceImageJson({
  String id = 'img1',
  String imageUrl = 'https://supabase.co/storage/img1.jpg',
  String? description = 'Filtro usado con desgaste',
  String uploadedAt = '2026-11-06T10:15:00.000Z',
}) {
  return {
    'id': id,
    'imageUrl': imageUrl,
    'description': description,
    'uploadedAt': uploadedAt,
  };
}

Map<String, Object?> partItemJson({
  String id = 'part1',
  String name = 'Filtro de Aceite',
  String sku = 'FLT-001',
  String category = 'Filtros',
  double basePrice = 25.0,
  double totalStock = 10.0,
  double minimumStock = 2.0,
  String unitOfMeasure = 'UND',
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
    'unitOfMeasure': unitOfMeasure,
    'status': status,
  };
}

Map<String, Object?> vehicleJson({
  String id = 'v1',
  String plate = 'ABC-123',
  String vin = 'VIN1234567890',
  String brand = 'Toyota',
  String model = 'Corolla',
  int year = 2021,
  String engineType = 'GASOLINE',
  int currentMileage = 45000,
}) {
  return {
    'id': id,
    'plate': plate,
    'vin': vin,
    'brand': brand,
    'model': model,
    'year': year,
    'engineType': engineType,
    'currentMileage': currentMileage,
  };
}

Map<String, Object?> bayJson({
  String id = 'bay1',
  String branchId = 'b1',
  String name = 'Bahía 1 (Elevador)',
  String bayType = 'LIFT',
  String status = 'OCCUPIED',
  String? currentWorkOrderId = 'wo1',
}) {
  return {
    'id': id,
    'tenantId': 't1',
    'branchId': branchId,
    'name': name,
    'bayType': bayType,
    'status': status,
    'currentWorkOrderId': currentWorkOrderId,
  };
}

class TasksTestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session;
  final MockProcessor processor = MockProcessor();
  final MockScheduler scheduler = MockScheduler();
  final Map<String, Responder> responses = {};
  final List<http.Request> requests = [];
  late final Directory tempDir;
  late final PreferencesPausedElapsedStore pausedElapsedStore;

  DateTime clock = DateTime.utc(2026, 11, 6, 14, 0, 0);

  TasksTestEnv._(this.session) {
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
  }

  static Future<TasksTestEnv> create() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final env = TasksTestEnv._(SessionManager());
    env.tempDir = await Directory.systemTemp.createTemp('tasks_test_');
    env.pausedElapsedStore = PreferencesPausedElapsedStore(
      preferences: SharedPreferencesAsync(),
    );
    return env;
  }

  late final ApiClient client = ApiClient(
    client: MockClient((request) async {
      requests.add(request);
      final key = '${request.method} ${request.url.path}';
      final respond = responses[key] ?? (_) => apiError(404, 'No configurado: $key');
      return respond(request);
    }),
    baseUrl: 'http://api',
  );

  late final TaskApi taskApi = TaskApi(client: client);
  late final InventoryApi inventoryApi = InventoryApi(client: client);
  late final VehicleApi vehicleApi = VehicleApi(client: client);
  late final WorkBayApi bayApi = WorkBayApi(client: client);

  late final PendingOperationQueue queue = PendingOperationQueue(
    dao: db.pendingOperationDao,
    session: session,
    processor: processor,
    scheduler: scheduler,
    now: () => clock,
  );

  late final PhotoCapture photoCapture = PhotoCapture(
    uploader: FakeUploader(),
    uploadDao: db.pendingUploadDao,
    queue: queue,
    session: session,
    supportDirectory: () async => tempDir,
    now: () => clock,
  );

  late final TaskEvidenceCapture evidenceCapture = TaskEvidenceCapture(
    photoCapture: photoCapture,
  );

  late final TaskRepository repository = TaskRepositoryImpl(
    taskApi: taskApi,
    inventoryApi: inventoryApi,
    vehicleApi: vehicleApi,
    bayApi: bayApi,
    taskDao: db.taskDao,
    vehicleDao: db.vehicleDao,
    bayDao: db.bayDao,
    cacheMetadataDao: db.cacheMetadataDao,
    pendingOperationDao: db.pendingOperationDao,
    pendingUploadDao: db.pendingUploadDao,
    evidenceCapture: evidenceCapture,
    session: session,
    supportDirectory: () async => tempDir,
    now: () => clock,
  );

  Future<void> signIn({
    List<Permission> permissions = const [
      Permission.tasksRead,
      Permission.tasksTrackTime,
      Permission.tasksUploadPhotos,
      Permission.tasksHoldRequest,
      Permission.tasksHoldValidate,
      Permission.tasksComplete,
      Permission.tasksChargeParts,
      Permission.baysRead,
      Permission.partsRead,
      Permission.vehiclesRead,
    ],
    String membershipId = 'm1',
    String branchId = 'b1',
  }) async {
    await session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'mecanico@taller.pe',
        'fullName': 'Carlos Mecánico',
        'token': 'jwt_token',
        'tokenType': 'Bearer',
        'permissions': [for (final p in permissions) p.value],
        'refreshToken': 'refresh_token',
        'membershipId': membershipId,
        'activeTenant': {'id': 't1', 'name': 'Taller Central', 'taxId': '20123456789'},
        'plan': null,
      }),
    );
    await session.updateAssignment(branchId, 's1');
  }

  List<http.Request> requested(String method, String path) {
    return requests
        .where((r) => r.method == method && r.url.path == path)
        .toList();
  }

  Future<void> close() async {
    await db.close();
    try {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}
