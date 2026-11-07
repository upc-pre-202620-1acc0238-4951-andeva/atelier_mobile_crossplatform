import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/reception_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/appointment_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/customer_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/service_catalog_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/work_order_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../tasks/support/tasks_test_env.dart';

export '../../tasks/support/tasks_test_env.dart'
    show apiError, detailJson, jsonResponse, offline;

const receptionPermissions = [
  Permission.vehiclesRead,
  Permission.customersRead,
  Permission.appointmentsRead,
  Permission.workOrdersRead,
  Permission.servicesRead,
  Permission.membersRead,
];

Map<String, Object?> customerJson({
  String id = 'c1',
  String type = 'INDIVIDUAL',
  String? displayName = 'Ana Pérez',
  String? taxId = '12345678',
  String? email = 'ana@correo.pe',
  String? phone,
  String status = 'ACTIVE',
}) {
  return {
    'id': id,
    'type': type,
    'displayName': displayName,
    'taxId': taxId,
    'email': email,
    'phone': phone,
    'status': status,
  };
}

Map<String, Object?> ownedVehicleJson({
  String id = 'v1',
  String plate = 'ABC123',
  String? ownerId = 'c1',
}) {
  return {
    'id': id,
    'plate': plate,
    'vin': null,
    'brand': 'Toyota',
    'model': 'Corolla',
    'year': 2021,
    'engineType': 'GASOLINE',
    'currentOwnerId': ownerId,
    'currentMileage': 45000,
  };
}

Map<String, Object?> appointmentJson({
  String id = 'a1',
  String branchId = 'b1',
  String customerId = 'c1',
  String vehicleId = 'v1',
  String scheduledAt = '2026-11-06T15:00:00Z',
  String status = 'CONFIRMED',
}) {
  return {
    'id': id,
    'branchId': branchId,
    'customerId': customerId,
    'vehicleId': vehicleId,
    'scheduledAt': scheduledAt,
    'estimatedDurationMinutes': 60,
    'reason': 'Mantenimiento',
    'status': status,
  };
}

/// `WorkOrderSummaryResource` si solo se dan los campos de la lista.
Map<String, Object?> workOrderJson({
  String id = 'wo1',
  int? internalNumber = 101,
  String vehicleId = 'v1',
  String customerId = 'c1',
  String branchId = 'b1',
  String? currentBayId,
  String? bayName,
  String status = 'DRAFT',
  int? mileageIn,
  String? diagnosticSummary,
  num? subtotal,
  num? taxAmount,
  num? totalAmount = 118,
  String? currency = 'PEN',
  List<Map<String, Object?>>? tasks,
  List<Map<String, Object?>>? proposals,
  List<Map<String, Object?>>? intakeImages,
}) {
  return {
    'id': id,
    'internalNumber': internalNumber,
    'vehicleId': vehicleId,
    'customerId': customerId,
    'branchId': branchId,
    'currentBayId': currentBayId,
    'bayName': bayName,
    'status': status,
    'mileageIn': mileageIn,
    'diagnosticSummary': diagnosticSummary,
    'subtotal': subtotal,
    'taxAmount': taxAmount,
    'totalAmount': totalAmount,
    'currency': currency,
    'tasks': tasks,
    'proposals': proposals,
    'intakeImages': intakeImages,
  };
}

/// Base en memoria, HTTP simulado y los repositorios reales de `reception` y `workorders`.
class ReceptionTestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session = SessionManager();
  final MockProcessor processor = MockProcessor();
  final MockScheduler scheduler = MockScheduler();
  final Map<String, Responder> responses = {};
  final List<http.Request> requests = [];
  late final Directory tempDir;

  DateTime clock = DateTime.utc(2026, 11, 6, 14);

  ReceptionTestEnv._() {
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
  }

  static Future<ReceptionTestEnv> create() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final env = ReceptionTestEnv._();
    env.tempDir = await Directory.systemTemp.createTemp('reception_test_');
    return env;
  }

  late final ApiClient client = ApiClient(
    client: MockClient((request) async {
      requests.add(request);
      final key = '${request.method} ${request.url.path}';
      final respond =
          responses[key] ?? (_) => apiError(404, 'No configurado: $key');
      return respond(request);
    }),
    baseUrl: 'http://api',
  );

  late final CustomerApi customerApi = CustomerApi(client: client);
  late final VehicleApi vehicleApi = VehicleApi(client: client);
  late final AppointmentApi appointmentApi = AppointmentApi(client: client);
  late final WorkOrderApi workOrderApi = WorkOrderApi(client: client);

  late final ReceptionRepositoryImpl reception = ReceptionRepositoryImpl(
    customerApi: customerApi,
    vehicleApi: vehicleApi,
    appointmentApi: appointmentApi,
    customerDao: db.customerDao,
    vehicleDao: db.vehicleDao,
    appointmentDao: db.appointmentDao,
    cacheMetadataDao: db.cacheMetadataDao,
    session: session,
    now: () => clock,
  );

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

  late final WorkOrderRepositoryImpl workOrders = WorkOrderRepositoryImpl(
    workOrderApi: workOrderApi,
    serviceCatalogApi: ServiceCatalogApi(client: client),
    employeeApi: EmployeeApi(client: client),
    workOrderDao: db.workOrderDao,
    cacheMetadataDao: db.cacheMetadataDao,
    pendingOperationDao: db.pendingOperationDao,
    pendingUploadDao: db.pendingUploadDao,
    photoCapture: photoCapture,
    pdfDownloader: PdfDownloader(cacheDirectory: () async => tempDir),
    session: session,
    supportDirectory: () async => tempDir,
    now: () => clock,
  );

  Future<void> signIn({
    List<Permission> permissions = receptionPermissions,
    String? branchId = 'b1',
    String tenantId = 't1',
  }) async {
    await session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'asesor@taller.pe',
        'fullName': 'Asesor',
        'token': 'jwt_token',
        'tokenType': 'Bearer',
        'permissions': [for (final p in permissions) p.value],
        'refreshToken': 'refresh_token',
        'membershipId': 'm1',
        'activeTenant': {
          'id': tenantId,
          'name': 'Taller',
          'taxId': '20123456789',
        },
        'plan': null,
      }),
    );
    if (branchId != null) await session.updateAssignment(branchId, 's1');
  }

  /// Una foto de verdad en disco, porque `FakeUploader` la copia.
  Future<File> photo([String name = 'photo.jpg']) async {
    final file = File('${tempDir.path}/$name');
    await file.writeAsBytes([1, 2, 3]);
    return file;
  }

  List<http.Request> requested(String method, String path) {
    return requests
        .where((r) => r.method == method && r.url.path == path)
        .toList();
  }

  Future<void> close() async {
    await db.close();
    try {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    } catch (_) {}
  }
}
