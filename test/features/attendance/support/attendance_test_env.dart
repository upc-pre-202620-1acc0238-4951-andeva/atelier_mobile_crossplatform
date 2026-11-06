import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class MockProcessor extends Mock implements SyncProcessor {}

class MockScheduler extends Mock implements SyncScheduler {}

class FakeConnectivity extends ConnectivityObserver {
  bool online = true;

  FakeConnectivity()
    : super(changes: const Stream.empty(), current: () async => const []);

  @override
  bool get isOnline => online;
}

typedef Responder = http.Response Function(http.Request request);

const historyPath = '/api/v1/hr/attendances/employee/m1/history';
const statusPath = '/api/v1/hr/attendances/employee/m1/status-today';
const clockInPath = '/api/v1/hr/attendances/clock-in';
const clockOutPath = '/api/v1/hr/attendances/clock-out';

http.Response json(Object body, [int status = 200]) {
  return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
}

http.Response apiError(int status, [String message = 'Mensaje del backend']) {
  return json({'code': 'CODE', 'message': message}, status);
}

http.Response offline(http.Request request) {
  throw http.ClientException('Sin red');
}

Map<String, Object?> attendanceJson({
  String id = 'a1',
  String? clockIn = '2026-10-24T13:00:00Z',
  String? clockOut,
  String status = 'ON_TIME',
  String? justificationStatus,
}) {
  return {
    'id': id,
    'branchId': 'b1',
    'membershipId': 'm1',
    'shiftId': 's1',
    'clockIn': clockIn,
    'clockOut': clockOut,
    'status': status,
    'latitude': -12,
    'longitude': -77.0428,
    'distanceToBranchMeters': 12.5,
    'workedMinutes': clockOut == null ? null : 480,
    'regularMinutes': clockOut == null ? null : 480,
    'overtimeMinutes': clockOut == null ? null : 0,
    'justificationStatus': justificationStatus,
  };
}

/// Drift en memoria, sesión real sobre almacenes en memoria y API con `MockClient`.
class AttendanceTestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session;
  final FakeConnectivity connectivity = FakeConnectivity();
  final MockProcessor processor = MockProcessor();
  final MockScheduler scheduler = MockScheduler();
  final Map<String, Responder> responses = {};
  final List<http.Request> requests = [];

  /// 09:00 en Lima.
  DateTime clock = DateTime.utc(2026, 10, 24, 14);

  AttendanceTestEnv._(this.session) {
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
  }

  static AttendanceTestEnv create() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    return AttendanceTestEnv._(SessionManager());
  }

  late final ApiClient client = ApiClient(
    client: MockClient((request) async {
      requests.add(request);
      final respond =
          responses['${request.method} ${request.url.path}'] ??
          (_) => apiError(404, 'No configurado');
      return respond(request);
    }),
    baseUrl: 'http://api',
  );

  late final AttendanceApi api = AttendanceApi(client: client);

  late final AttendanceCache cache = AttendanceCache(
    api: api,
    dao: db.attendanceDao,
    now: () => clock,
  );

  late final PendingOperationQueue queue = PendingOperationQueue(
    dao: db.pendingOperationDao,
    session: session,
    processor: processor,
    scheduler: scheduler,
    now: () => clock,
  );

  late final AttendanceRepositoryImpl repository = AttendanceRepositoryImpl(
    api: api,
    branchApi: BranchApi(client: client),
    employeeApi: EmployeeApi(client: client),
    attendanceDao: db.attendanceDao,
    shiftDao: db.shiftDao,
    branchDao: db.branchDao,
    cacheMetadataDao: db.cacheMetadataDao,
    pendingOperationDao: db.pendingOperationDao,
    queue: queue,
    cache: cache,
    session: session,
    connectivity: connectivity,
    now: () => clock,
  );

  Future<void> signIn({
    List<Permission> permissions = const [
      Permission.attendanceReadOwn,
      Permission.attendanceClockIn,
      Permission.attendanceClockOut,
      Permission.branchesRead,
      Permission.shiftsRead,
      Permission.justificationsCreate,
    ],
    String? membershipId = 'm1',
    String? branchId = 'b1',
    String? shiftId = 's1',
  }) async {
    await session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'm@taller.pe',
        'fullName': 'Andrés',
        'token': 'token',
        'tokenType': 'Bearer',
        'permissions': [for (final p in permissions) p.value],
        'refreshToken': 'refresh',
        'membershipId': membershipId,
        'activeTenant': {'id': 't1', 'name': 'Taller', 'taxId': '1'},
        'plan': null,
      }),
    );
    await session.updateAssignment(branchId, shiftId);
  }

  List<http.Request> requested(String method, String path) {
    return requests
        .where((r) => r.method == method && r.url.path == path)
        .toList();
  }

  Future<List<PendingOperationEntity>> pending() {
    return db.pendingOperationDao.watchForUser('u1').first;
  }

  /// Fila de la cola tal como la deja `PendingOperationQueue`, con el estado que haga falta.
  Future<void> seedOperation({
    required String id,
    required String type,
    required String dedupeKey,
    String status = 'PENDING',
    String payload = '{}',
    int createdAt = 0,
    String? lastErrorMessage,
  }) async {
    await db.pendingOperationDao.enqueue(
      PendingOperationsCompanion.insert(
        id: id,
        type: type,
        payload: payload,
        dedupeKey: dedupeKey,
        userId: 'u1',
        tenantId: 't1',
        nextAttemptAt: 0,
        createdAt: createdAt,
      ),
    );
    if (status == 'FAILED') {
      await db.pendingOperationDao.markFailed(
        id,
        attempts: 1,
        httpStatus: 422,
        code: 'CODE',
        message: lastErrorMessage,
      );
    }
  }

  Future<void> close() => db.close();
}
