import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/diagnostics_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/health_report_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
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
    show Responder, apiError, jsonResponse, offline;

class DiagnosticsTestEnv {
  final AppDatabase db = AppDatabase(NativeDatabase.memory());
  final SessionManager session;
  final MockProcessor processor = MockProcessor();
  final MockScheduler scheduler = MockScheduler();
  final Map<String, Responder> responses = {};
  final List<http.Request> requests = [];
  late final Directory tempDir;

  DateTime clock = DateTime.utc(2026, 10, 24, 14);

  DiagnosticsTestEnv._(this.session) {
    when(() => scheduler.requestSync()).thenAnswer((_) async {});
  }

  static Future<DiagnosticsTestEnv> create() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    final env = DiagnosticsTestEnv._(SessionManager());
    env.tempDir = await Directory.systemTemp.createTemp('diagnostics_test_');
    return env;
  }

  late final IotApi api = IotApi(
    client: ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        final key = '${request.method} ${request.url.path}';
        final respond =
            responses[key] ?? (_) => apiError(404, 'No configurado: $key');
        return respond(request);
      }),
      baseUrl: 'http://api',
    ),
  );

  late final PendingOperationQueue queue = PendingOperationQueue(
    dao: db.pendingOperationDao,
    session: session,
    processor: processor,
    scheduler: scheduler,
    now: () => clock,
  );

  late final DiagnosticsRepositoryImpl repository = DiagnosticsRepositoryImpl(
    api: api,
    readingDao: db.telemetryReadingDao,
    faultDao: db.vehicleFaultDao,
    alertDao: db.predictiveAlertDao,
    pendingOperationDao: db.pendingOperationDao,
    queue: queue,
    session: session,
    now: () => clock,
  );

  late final HealthReportRepositoryImpl healthReports =
      HealthReportRepositoryImpl(
        api: api,
        pdfDownloader: PdfDownloader(cacheDirectory: () async => tempDir),
      );

  Future<void> signIn({
    List<Permission> permissions = const [
      Permission.faultsRead,
      Permission.predictiveAlertsRead,
    ],
  }) {
    return session.save(
      AuthenticatedUserDto.fromJson({
        'userId': 'u1',
        'email': 'mecanico@taller.pe',
        'fullName': 'Carlos Mecánico',
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

  Future<List<PendingOperationEntity>> queued() {
    return db.pendingOperationDao.watchForUser('u1').first;
  }

  List<http.Request> requested(String method, String path) {
    return requests
        .where((r) => r.method == method && r.url.path == path)
        .toList();
  }

  Map<String, dynamic> payloadOf(PendingOperationEntity operation) {
    return jsonDecode(operation.payload) as Map<String, dynamic>;
  }

  Future<void> close() async {
    await db.close();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  }
}

VehicleFaultEntity faultEntity(
  String id,
  String code, {
  String vehicleId = 'v1',
  bool resolved = false,
}) {
  return VehicleFaultEntity(
    id: id,
    vehicleId: vehicleId,
    dtcCode: code,
    severity: 'MEDIUM',
    description: 'Falla $code',
    detectedAt: 0,
    isResolved: resolved,
    resolvedAt: resolved ? 5 : null,
  );
}

Map<String, Object?> faultJson(
  String id,
  String code, {
  bool resolved = false,
}) {
  return {
    'id': id,
    'vehicleId': 'v1',
    'dtcCode': code,
    'severity': 'MEDIUM',
    'description': 'Falla $code',
    'detectedAt': '2026-10-24T13:00:00Z',
    'isResolved': resolved,
    'resolvedAt': resolved ? '2026-10-24T14:00:00Z' : null,
  };
}

Map<String, Object?> installationJson() {
  return {
    'id': 'i1',
    'deviceId': 'd1',
    'vehicleId': 'v1',
    'tenantId': 't1',
    'installedAt': '2026-10-24T13:00:00Z',
    'uninstalledAt': null,
    'initialOdometerKm': 45000,
    'finalOdometerKm': null,
    'isActive': true,
  };
}

Map<String, Object?> healthReportJson() {
  return {
    'reportId': 'r1',
    'vehicleId': 'v1',
    'overallHealthScore': 78,
    'executiveSummary': 'Motor estable',
    'totalRisksDetected': 2,
    'generatedAt': '2026-10-24T14:00:00Z',
    'jsonResourceUrl': null,
    'pdfDownloadUrl': null,
  };
}

Map<String, Object?> alertJson(String id, {String status = 'DISPATCHED'}) {
  return {
    'id': id,
    'vehicleId': 'v1',
    'recommendedServiceId': 's1',
    'alertType': 'ENGINE_OVERHEATING_RISK',
    'confidenceScore': 0.87,
    'message': 'Riesgo de sobrecalentamiento',
    'status': status,
    'createdAt': '2026-10-24T12:00:00Z',
  };
}
