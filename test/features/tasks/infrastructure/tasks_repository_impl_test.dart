import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/task_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/tasks_test_env.dart';

void main() {
  late TasksTestEnv env;

  setUp(() async {
    env = await TasksTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  group('refreshMyTasks & observeMyTasks', () {
    test('refresca tareas asignadas, enriquece con bahías y vehículos y emite por Drift', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(
          taskId: 't1',
          branchId: 'b1',
          bayId: 'bay1',
          vehicleId: 'v1',
          status: 'IN_PROGRESS',
        ),
      ]);
      env.responses['GET /api/v1/work-bays'] = (_) => jsonResponse([
        bayJson(id: 'bay1', branchId: 'b1', name: 'Bahía 1 (Elevador)'),
      ]);
      env.responses['GET /api/v1/vehicles/v1'] = (_) => jsonResponse(
        vehicleJson(id: 'v1', plate: 'ABC-123', brand: 'Toyota', model: 'Corolla'),
      );

      await env.repository.refreshMyTasks();

      final tasks = await env.repository.observeMyTasks().first;
      expect(tasks.length, 1);
      final task = tasks.first;
      expect(task.id.value, 't1');
      expect(task.status, TaskStatus.inProgress);
      expect(task.plate, 'ABC-123');
      expect(task.bayName, 'Bahía 1 (Elevador)');

      // Metadatos de sincronización
      final meta = await env.db.cacheMetadataDao.get(TaskRepositoryImpl.scopeMyTasks);
      expect(meta, isNotNull);
      expect(meta!.recordCount, 1);
    });

    test('no refresca bahías ni vehículos si todavía están dentro del TTL', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', branchId: 'b1', bayId: 'bay1', vehicleId: 'v1'),
      ]);
      env.responses['GET /api/v1/work-bays'] = (_) => jsonResponse([
        bayJson(id: 'bay1', branchId: 'b1'),
      ]);
      env.responses['GET /api/v1/vehicles/v1'] = (_) => jsonResponse(
        vehicleJson(id: 'v1'),
      );

      await env.repository.refreshMyTasks();
      expect(env.requested('GET', '/api/v1/work-bays').length, 1);
      expect(env.requested('GET', '/api/v1/vehicles/v1').length, 1);

      // Segunda llamada de inmediato
      await env.repository.refreshMyTasks();
      expect(env.requested('GET', '/api/v1/work-bays').length, 1);
      expect(env.requested('GET', '/api/v1/vehicles/v1').length, 1);
    });

    test('sin permiso tasksRead no consulta el backend', () async {
      await env.signIn(permissions: [Permission.attendanceReadOwn]);
      await env.repository.refreshMyTasks();
      expect(env.requested('GET', '/api/v1/tasks/my'), isEmpty);
    });
  });

  group('getDetail & observeTask', () {
    test('obtiene detalle con productos e imágenes y actualiza la caché local', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', status: 'IN_PROGRESS'),
      ]);
      await env.repository.refreshMyTasks();

      env.responses['GET /api/v1/tasks/t1'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          status: 'IN_PROGRESS',
          products: [productJson(id: 'tp1', name: 'Aceite 5W-30', quantity: 4.0)],
          evidenceImages: [evidenceImageJson(id: 'img1', imageUrl: 'https://img.jpg')],
        ),
      );

      final detail = await env.repository.getDetail(const TaskId('t1'));
      expect(detail.id.value, 't1');
      expect(detail.status, TaskStatus.inProgress);
      expect(detail.products.length, 1);
      expect(detail.products.first.productName, 'Aceite 5W-30');
      expect(detail.evidenceImages.length, 1);
      expect(detail.evidenceImages.first.imageUrl, 'https://img.jpg');

      final cached = await env.db.taskDao.findById('t1');
      expect(cached, isNotNull);
      expect(cached!.status, 'IN_PROGRESS');
    });

    test('observeTask emite cambios locales', () async {
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', status: 'IN_PROGRESS'),
      ]);
      await env.repository.refreshMyTasks();

      final task = await env.repository.observeTask(const TaskId('t1')).first;
      expect(task, isNotNull);
      expect(task!.id.value, 't1');
      expect(task.status, TaskStatus.inProgress);
    });
  });

  group('flujo de ciclo de vida', () {
    test('start inicia la tarea y actualiza la caché', () async {
      env.responses['POST /api/v1/tasks/t1/start'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'IN_PROGRESS'),
      );

      final detail = await env.repository.start(const TaskId('t1'));
      expect(detail.status, TaskStatus.inProgress);
      expect(env.requested('POST', '/api/v1/tasks/t1/start').length, 1);
    });

    test('pause pausa la tarea y actualiza la caché', () async {
      env.responses['POST /api/v1/tasks/t1/pause'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'IN_PROGRESS'),
      );

      final detail = await env.repository.pause(
        const TaskId('t1'),
        PauseReason.breakTime,
      );
      expect(detail.status, TaskStatus.inProgress);
      final body = env.requested('POST', '/api/v1/tasks/t1/pause').single.body;
      expect(body, contains('BREAK'));
    });

    test('requestSuspension solicita suspensión por repuesto faltante', () async {
      env.responses['POST /api/v1/tasks/t1/hold'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          status: 'ON_HOLD',
          holdReason: 'WAITING_FOR_PARTS',
          missingItemDescription: 'Bomba de agua',
        ),
      );

      final detail = await env.repository.requestSuspension(
        const TaskId('t1'),
        'Bomba de agua',
        inventoryItemId: 'part_pump',
      );
      expect(detail.status, TaskStatus.onHold);
      expect(detail.holdReason, HoldReason.waitingForParts);
      expect(detail.missingItemDescription, 'Bomba de agua');
    });

    test('approveSuspension y rejectSuspension', () async {
      env.responses['POST /api/v1/tasks/t1/hold/approve'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'ON_HOLD'),
      );
      env.responses['POST /api/v1/tasks/t1/hold/reject'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'IN_PROGRESS'),
      );

      final approved = await env.repository.approveSuspension(const TaskId('t1'));
      expect(approved.status, TaskStatus.onHold);

      final rejected = await env.repository.rejectSuspension(const TaskId('t1'));
      expect(rejected.status, TaskStatus.inProgress);
    });

    test('resume reanuda la tarea', () async {
      env.responses['POST /api/v1/tasks/t1/resume'] = (_) => jsonResponse(
        detailJson(id: 't1', status: 'IN_PROGRESS'),
      );

      final detail = await env.repository.resume(const TaskId('t1'));
      expect(detail.status, TaskStatus.inProgress);
    });

    test('complete finaliza la tarea y la elimina de la caché local', () async {
      // Primero sembramos la tarea localmente
      env.responses['GET /api/v1/tasks/my'] = (_) => jsonResponse([
        taskJson(taskId: 't1', status: 'IN_PROGRESS'),
      ]);
      await env.repository.refreshMyTasks();
      expect(await env.db.taskDao.findById('t1'), isNotNull);

      env.responses['POST /api/v1/tasks/t1/complete'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          status: 'COMPLETED',
          completedAt: '2026-11-06T12:00:00Z',
        ),
      );

      final detail = await env.repository.complete(
        const TaskId('t1'),
        2.5,
        notes: 'Trabajo terminado con éxito',
      );
      expect(detail.status, TaskStatus.completed);

      // Debe borrarse de la lista activa de mis tareas
      expect(await env.db.taskDao.findById('t1'), isNull);
    });
  });

  group('evidencias fotográficas', () {
    test('attachEvidence encola subida de foto y adjunto, y observePendingEvidence lo observa', () async {
      final file = File('${env.tempDir.path}/test_evidence.jpg')
        ..writeAsBytesSync([1, 2, 3, 4]);

      await env.repository.attachEvidence(
        const TaskId('t1'),
        'wo1',
        file,
        'Pastillas de freno gastadas',
      );

      // Verificamos que se encolaron operaciones en Drift
      final pendingOps = await env.db.pendingOperationDao.watchForUser('u1').first;
      expect(pendingOps.length, 2); // UPLOAD_FILE y ATTACH_TASK_EVIDENCE

      final pendingList = await env.repository.observePendingEvidence(const TaskId('t1')).first;
      expect(pendingList.length, 1);
      final pending = pendingList.first;
      expect(pending.description, 'Pastillas de freno gastadas');
      expect(pending.status, 'PENDING');
      expect(pending.localFilePath, isNotNull);
    });
  });

  group('repuestos e insumos', () {
    test('searchParts busca repuestos en inventario', () async {
      env.responses['GET /api/v1/inventory/items'] = (_) => jsonResponse([
        partItemJson(id: 'p1', name: 'Filtro de Aceite', basePrice: 25.0, totalStock: 8.0),
      ]);

      final parts = await env.repository.searchParts('Filtro');
      expect(parts.length, 1);
      expect(parts.first.id, 'p1');
      expect(parts.first.name, 'Filtro de Aceite');
      expect(parts.first.basePrice, 25.0);
      expect(parts.first.totalStock, 8.0);
    });

    test('addPart agrega un repuesto a la tarea', () async {
      env.responses['POST /api/v1/tasks/t1/products'] = (_) => jsonResponse(
        productJson(id: 'tp1', productId: 'p1', name: 'Filtro de Aceite', quantity: 2.0),
      );

      final product = await env.repository.addPart(
        const TaskId('t1'),
        'p1',
        2.0,
      );
      expect(product.id, 'tp1');
      expect(product.productId, 'p1');
      expect(product.quantity, 2.0);
    });

    test('updatePartQuantity actualiza cantidad y recarga detalle', () async {
      env.responses['PUT /api/v1/tasks/t1/products/tp1'] = (_) => jsonResponse(
        productJson(id: 'tp1', quantity: 3.0),
      );
      env.responses['GET /api/v1/tasks/t1'] = (_) => jsonResponse(
        detailJson(
          id: 't1',
          products: [productJson(id: 'tp1', quantity: 3.0)],
        ),
      );

      final detail = await env.repository.updatePartQuantity(
        const TaskId('t1'),
        'tp1',
        3.0,
      );
      expect(detail.products.first.quantity, 3.0);
    });

    test('removePart elimina un repuesto', () async {
      env.responses['DELETE /api/v1/tasks/t1/products/tp1'] = (_) => jsonResponse({});

      await env.repository.removePart(const TaskId('t1'), 'tp1');
      expect(env.requested('DELETE', '/api/v1/tasks/t1/products/tp1').length, 1);
    });
  });
}
