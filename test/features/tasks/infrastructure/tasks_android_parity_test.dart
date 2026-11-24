import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/task_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/tasks_test_env.dart';

const _uuidProduct = 'Product 123e4567-e89b-12d3-a456-426614174000';

void main() {
  late TasksTestEnv env;

  setUp(() async {
    env = await TasksTestEnv.create();
    await env.signIn(
      permissions: [
        Permission.tasksRead,
        Permission.tasksTrackTime,
        Permission.tasksChargeParts,
        Permission.partsRead,
      ],
    );
  });

  tearDown(() => env.close());

  group('reopen', () {
    test('envía el motivo como query, actualiza la caché y devuelve el detalle', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', status: 'IN_PROGRESS'),
      ]);
      await env.repository.refreshMyTasks();
      env.responses['POST /api/v1/tasks/t1/reopen'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'IN_PROGRESS', completedAt: null),
      );

      final detail = await env.repository.reopen(
        const TaskId('t1'),
        reason: 'Retrabajo de calidad',
      );

      expect(detail.status, TaskStatus.inProgress);
      final call = env.requested('POST', '/api/v1/tasks/t1/reopen').single;
      expect(call.url.queryParameters['reason'], 'Retrabajo de calidad');
    });

    test('sin motivo no manda query', () async {
      env.responses['POST /api/v1/tasks/t1/reopen'] = (_) =>
          jsonResponse(detailJson(id: 't1', status: 'PENDING'));

      await env.repository.reopen(const TaskId('t1'));

      final call = env.requested('POST', '/api/v1/tasks/t1/reopen').single;
      expect(call.url.hasQuery, isFalse);
    });
  });

  group('nombres de servicio y repuestos', () {
    test('descarta el servicio genérico "Standard Service"', () async {
      env.responses['GET /api/v1/tasks/t1'] = (_) =>
          jsonResponse(detailJson(id: 't1', serviceName: 'Standard Service'));

      final detail = await env.repository.getDetail(const TaskId('t1'));

      expect(detail.serviceName, isNull);
    });

    test('completa con el catálogo el nombre del repuesto que llega como "Product <uuid>"', () async {
      env.responses['GET /api/v1/tasks/t1'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          products: [
            productJson(id: 'tp1', productId: 'p1', name: _uuidProduct),
            productJson(id: 'tp2', productId: 'p2', name: 'Aceite 5W-30'),
          ],
        ),
      );
      env.responses['GET /api/v1/inventory/items'] = (_) => jsonResponse([
        partItemJson(id: 'p1', name: 'Filtro de Aceite'),
      ]);

      final detail = await env.repository.getDetail(const TaskId('t1'));

      expect(detail.products[0].productName, 'Filtro de Aceite');
      expect(detail.products[1].productName, 'Aceite 5W-30');
    });

    test('sin permiso de repuestos deja el nombre vacío y no consulta el catálogo', () async {
      await env.signIn(permissions: [Permission.tasksRead]);
      env.responses['GET /api/v1/tasks/t1'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          products: [productJson(productId: 'p1', name: _uuidProduct)],
        ),
      );

      final detail = await env.repository.getDetail(const TaskId('t1'));

      expect(detail.products.single.productName, isNull);
      expect(env.requests.where((r) => r.url.path.contains('inventory')), isEmpty);
    });
  });

  group('solicitud de suspensión pendiente', () {
    test('guarda y expone pendingSuspensionRequestedAt al fusionar el detalle', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', status: 'IN_PROGRESS'),
      ]);
      await env.repository.refreshMyTasks();
      env.responses['POST /api/v1/tasks/t1/hold'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          status: 'IN_PROGRESS',
          pendingSuspensionReason: 'Filtro defectuoso',
          pendingSuspensionRequestedAt: '2026-11-06T12:00:00.000Z',
        ),
      );

      await env.repository.requestSuspension(const TaskId('t1'), 'Filtro defectuoso');

      final task = (await env.repository.observeMyTasks().first).single;
      expect(task.hasPendingSuspension, isTrue);
      expect(
        task.pendingSuspensionRequestedAt,
        DateTime.utc(2026, 11, 6, 12),
      );
    });
  });

  group('refreshMyTasks de supervisión del taller', () {
    late TaskRepositoryImpl supervisorRepository;

    setUp(() async {
      await env.signIn(
        permissions: [
          Permission.tasksRead,
          Permission.workOrdersRead,
          Permission.workOrdersUpdate,
        ],
      );
      supervisorRepository = TaskRepositoryImpl(
        taskApi: env.taskApi,
        inventoryApi: env.inventoryApi,
        vehicleApi: env.vehicleApi,
        bayApi: env.bayApi,
        taskDao: env.db.taskDao,
        vehicleDao: env.db.vehicleDao,
        bayDao: env.db.bayDao,
        cacheMetadataDao: env.db.cacheMetadataDao,
        pendingOperationDao: env.db.pendingOperationDao,
        pendingUploadDao: env.db.pendingUploadDao,
        evidenceCapture: env.evidenceCapture,
        session: env.session,
        supportDirectory: () async => env.tempDir,
        now: () => env.clock,
        workOrderApi: WorkOrderApi(client: env.client),
      );
    });

    Map<String, Object?> order(String id, String status, List<Object?> tasks) {
      return {
        'id': id,
        'internalNumber': 7,
        'vehicleId': 'v1',
        'customerId': 'c1',
        'branchId': 'b1',
        'currentBayId': 'bay1',
        'status': status,
        'tasks': tasks,
      };
    }

    test('carga las tareas abiertas de las órdenes activas de la sede', () async {
      env.responses['GET /api/v1/work-orders'] = (_) => jsonResponse([
        order('wo1', 'IN_PROGRESS', const []),
        order('wo2', 'PAID', const []),
      ]);
      env.responses['GET /api/v1/work-orders/wo1'] = (_) => jsonResponse(
        order('wo1', 'IN_PROGRESS', [
          detailJson(id: 't1', workOrderId: 'wo1', status: 'ON_HOLD', holdReason: 'DEFECTIVE_PART',
              serviceName: 'Standard Service', pendingSuspensionRequestedAt: '2026-11-06T12:00:00.000Z'),
          detailJson(id: 't2', workOrderId: 'wo1', status: 'COMPLETED'),
        ]),
      );

      await supervisorRepository.refreshMyTasks();

      expect(env.requested('GET', '/api/v1/tasks/my'), isEmpty);
      expect(env.requested('GET', '/api/v1/work-orders/wo2'), isEmpty);
      final tasks = await supervisorRepository.observeMyTasks().first;
      expect(tasks.map((t) => t.id.value), ['t1']);
      expect(tasks.single.workOrderNumber, 7);
      expect(tasks.single.bayId, 'bay1');
      expect(tasks.single.serviceName, isNull);
      expect(tasks.single.hasPendingSuspension, isTrue);
    });

    test('un mecánico con cronómetro propio sigue usando tasks/my', () async {
      await env.signIn(
        permissions: [
          Permission.tasksRead,
          Permission.tasksTrackTime,
          Permission.workOrdersRead,
          Permission.workOrdersUpdate,
        ],
      );
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't9'),
      ]);

      await supervisorRepository.refreshMyTasks();

      expect(env.requested('GET', '/api/v1/work-orders'), isEmpty);
      expect((await supervisorRepository.observeMyTasks().first).single.id.value, 't9');
    });

    test('con tasks/my vacío y permiso de validar suspensiones usa las órdenes de la sede', () async {
      await env.signIn(
        permissions: [
          Permission.tasksRead,
          Permission.tasksTrackTime,
          Permission.tasksHoldValidate,
          Permission.workOrdersRead,
        ],
      );
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([]);
      env.responses['GET /api/v1/work-orders'] = (_) => jsonResponse([
        order('wo1', 'IN_PROGRESS', const []),
      ]);
      env.responses['GET /api/v1/work-orders/wo1'] = (_) => jsonResponse(
        order('wo1', 'IN_PROGRESS', [detailJson(id: 't1', workOrderId: 'wo1')]),
      );

      await supervisorRepository.refreshMyTasks();

      expect((await supervisorRepository.observeMyTasks().first).single.id.value, 't1');
    });
  });
}
