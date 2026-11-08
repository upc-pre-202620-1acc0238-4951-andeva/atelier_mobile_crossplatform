import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/bay_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/cashier_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_api.dart';
import 'package:atelier_mobile_crossplatform/features/reports/infrastructure/remote/reports_api.dart';
import 'package:atelier_mobile_crossplatform/features/reports/infrastructure/reports_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/team/infrastructure/remote/team_api.dart';
import 'package:atelier_mobile_crossplatform/features/team/infrastructure/team_repository_impl.dart';
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

import '../tasks/support/tasks_test_env.dart'
    show FakeUploader, MockProcessor, MockScheduler;

/// Respuesta simulada; puede tardar o no llegar nunca.
typedef AsyncResponder = FutureOr<http.Response> Function(http.Request request);

http.Response json(Object? body, [int status = 200]) {
  return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
}

http.Response apiError(int status, [String message = 'Error del backend']) {
  return json({'code': 'CODE', 'message': message}, status);
}

http.Response timeout(http.Request request) {
  throw TimeoutException('sin respuesta');
}

http.Response offline(http.Request request) {
  throw http.ClientException('Sin red');
}

Map<String, Object?> bayJson({
  String id = 'bay1',
  String name = 'Bahía 1',
  String bayType = 'LIFT',
  String status = 'OCCUPIED',
  String? currentWorkOrderId = 'wo1',
}) {
  return {
    'id': id,
    'tenantId': 't1',
    'branchId': 'b1',
    'name': name,
    'bayType': bayType,
    'status': status,
    'currentWorkOrderId': currentWorkOrderId,
  };
}

Map<String, Object?> workOrderJson({
  String id = 'wo1',
  int internalNumber = 101,
  String status = 'IN_PROGRESS',
  String customerId = 'c1',
  List<Map<String, Object?>>? tasks,
}) {
  return {
    'id': id,
    'internalNumber': internalNumber,
    'vehicleId': 'v1',
    'customerId': customerId,
    'branchId': 'b1',
    'status': status,
    'totalAmount': 236,
    'currency': 'PEN',
    'tasks': tasks,
  };
}

Map<String, Object?> taskJson({
  String id = 't1',
  String status = 'IN_PROGRESS',
  String? serviceId = 'srv1',
  String? mechanicId = 'm1',
  num? price = 100,
  String currency = 'PEN',
  String? startedAt = '2026-11-06T13:00:00Z',
  int totalPausedSeconds = 600,
  List<Map<String, Object?>> products = const [],
}) {
  return {
    'id': id,
    'workOrderId': 'wo1',
    'serviceId': serviceId,
    'serviceName': 'Standard Service',
    'mechanicId': mechanicId,
    'status': status,
    'description': 'Cambio de aceite',
    'price': price,
    'currency': currency,
    'totalPausedSeconds': totalPausedSeconds,
    'startedAt': startedAt,
    'products': products,
  };
}

Map<String, Object?> voucherJson({
  String id = 'v1',
  String type = '03',
  String status = 'ISSUED',
  String workOrderId = 'wo1',
  num total = 118,
  num paid = 0,
  num? pending = 118,
  String paymentStatus = 'PENDING',
  String currency = 'PEN',
}) {
  return {
    'id': id,
    'branchId': 'b1',
    'customerId': 'c1',
    'workOrderId': workOrderId,
    'voucherType': type,
    'serie': type == '01' ? 'F001' : 'B001',
    'number': 1,
    'subtotal': 100,
    'igvAmount': 18,
    'totalAmount': total,
    'paidAmount': paid,
    'pendingBalance': pending,
    'currency': currency,
    'status': status,
    'paymentStatus': paymentStatus,
    'lines': [],
    'payments': [],
  };
}

Map<String, Object?> attendanceJson({
  String id = 'a1',
  String membershipId = 'm1',
  String? clockIn = '2026-11-06T13:10:00Z',
  String status = 'LATE',
  String? justificationStatus = 'PENDING',
}) {
  return {
    'id': id,
    'branchId': 'b1',
    'membershipId': membershipId,
    'shiftId': 's1',
    'clockIn': clockIn,
    'status': status,
    'justificationReason': 'Tráfico',
    'justificationStatus': justificationStatus,
  };
}

/// Base en memoria, HTTP simulado y los repositorios reales del paso 9 (y `workorders`).
class Step9TestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session = SessionManager();
  final Map<String, AsyncResponder> responses = {};
  final List<http.Request> requests = [];
  late final Directory tempDir;

  /// 09:00 de Lima del 6 de noviembre.
  DateTime clock = DateTime.utc(2026, 11, 6, 14);

  Step9TestEnv._();

  static Future<Step9TestEnv> create() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final env = Step9TestEnv._();
    env.tempDir = await Directory.systemTemp.createTemp('step9_test_');
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

  late final MockScheduler _scheduler = () {
    final scheduler = MockScheduler();
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
    return scheduler;
  }();

  late final WorkOrderRepositoryImpl workOrders = WorkOrderRepositoryImpl(
    workOrderApi: WorkOrderApi(client: client),
    serviceCatalogApi: ServiceCatalogApi(client: client),
    employeeApi: EmployeeApi(client: client),
    workOrderDao: db.workOrderDao,
    cacheMetadataDao: db.cacheMetadataDao,
    pendingOperationDao: db.pendingOperationDao,
    pendingUploadDao: db.pendingUploadDao,
    photoCapture: PhotoCapture(
      uploader: FakeUploader(),
      uploadDao: db.pendingUploadDao,
      queue: PendingOperationQueue(
        dao: db.pendingOperationDao,
        session: session,
        processor: MockProcessor(),
        scheduler: _scheduler,
        now: () => clock,
      ),
      session: session,
      supportDirectory: () async => tempDir,
      now: () => clock,
    ),
    pdfDownloader: pdfDownloader,
    session: session,
    supportDirectory: () async => tempDir,
    now: () => clock,
  );

  late final PdfDownloader pdfDownloader = PdfDownloader(
    cacheDirectory: () async => tempDir,
  );

  late final BayRepositoryImpl bays = BayRepositoryImpl(
    api: WorkBayApi(client: client),
    bayDao: db.bayDao,
    workOrderDao: db.workOrderDao,
    cacheMetadataDao: db.cacheMetadataDao,
    workOrders: workOrders,
    session: session,
    now: () => clock,
  );

  late final CashierRepositoryImpl cashier = CashierRepositoryImpl(
    api: CashierApi(client: client),
    voucherDao: db.voucherDao,
    session: session,
    now: () => clock,
  );

  late final ReportsRepositoryImpl reports = ReportsRepositoryImpl(
    api: ReportsApi(client: client),
    pdfDownloader: pdfDownloader,
  );

  late final TeamRepositoryImpl team = TeamRepositoryImpl(
    api: TeamApi(client: client),
    attendanceApi: AttendanceApi(client: client),
    employeeApi: EmployeeApi(client: client),
    session: session,
    time: BusinessTime(now: () => clock),
  );

  Future<void> signIn({
    required List<Permission> permissions,
    String? branchId = 'b1',
  }) async {
    await session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'jefe@taller.pe',
        'fullName': 'Jefe',
        'token': 'jwt_token',
        'tokenType': 'Bearer',
        'permissions': [for (final p in permissions) p.value],
        'refreshToken': 'refresh_token',
        'membershipId': 'm9',
        'activeTenant': {'id': 't1', 'name': 'Taller', 'taxId': '20123456789'},
        'plan': null,
      }),
    );
    if (branchId != null) await session.updateAssignment(branchId, 's1');
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
