import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/combine_latest.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_dao.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/reception_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_dao.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/add_task_product_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/assigned_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/attach_task_evidence_payload.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/complete_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/hold_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/pause_task_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/update_task_product_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_dto.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/work_order_task_mapper.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/repository/task_evidence_capture.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/sync/attach_task_evidence_handler.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

class TaskRepositoryImpl implements TaskRepository {
  static const scopeMyTasks = 'tasks:my';
  static const baysTtlMillis = 30 * 1000; // 30s
  static const vehiclesTtlMillis = 7 * 24 * 60 * 60 * 1000; // 7 days

  final TaskApi taskApi;
  final InventoryApi inventoryApi;
  final VehicleApi vehicleApi;
  final WorkBayApi bayApi;
  final TaskDao taskDao;
  final VehicleDao vehicleDao;
  final BayDao bayDao;
  final CacheMetadataDao cacheMetadataDao;
  final PendingOperationDao pendingOperationDao;
  final PendingUploadDao pendingUploadDao;
  final TaskEvidenceCapture evidenceCapture;
  final SessionManager session;
  final Future<Directory> Function() supportDirectory;
  final DateTime Function() now;

  TaskRepositoryImpl({
    required this.taskApi,
    required this.inventoryApi,
    required this.vehicleApi,
    required this.bayApi,
    required this.taskDao,
    required this.vehicleDao,
    required this.bayDao,
    required this.cacheMetadataDao,
    required this.pendingOperationDao,
    required this.pendingUploadDao,
    required this.evidenceCapture,
    required this.session,
    required this.supportDirectory,
    this.now = DateTime.now,
  });

  @override
  Stream<List<Task>> observeMyTasks() {
    return taskDao.observeAll().map((rows) => rows.map(_toDomainTask).toList());
  }

  @override
  Stream<Task?> observeTask(TaskId id) {
    return taskDao.observeById(id.value).map(
          (row) => row == null ? null : _toDomainTask(row),
        );
  }

  @override
  Future<void> refreshMyTasks() async {
    final currentSession = await session.getSession();
    if (currentSession == null) throw StateError('Sin sesión');
    if (!currentSession.has(Permission.tasksRead)) return;
    final timestamp = now().millisecondsSinceEpoch;
    final dtos = await taskApi.getMyTasks();
    final rows = dtos.map((dto) => _toTasksCompanion(dto, timestamp)).toList();
    await taskDao.replaceMine(rows);
    await cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: const Value(scopeMyTasks),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(rows.length),
      ),
    );
    await _enrich(rows, currentSession, timestamp);
  }

  @override
  Future<TaskDetail> getDetail(TaskId id) async {
    final dto = await taskApi.getTask(id.value);
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> start(TaskId id) async {
    final dto = await taskApi.start(id.value);
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> pause(TaskId id, PauseReason reason) async {
    final dto = await taskApi.pause(
      id.value,
      PauseTaskRequestDto(reason: reason.value),
    );
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> requestSuspension(
    TaskId id,
    String missingItemDescription, {
    String? inventoryItemId,
  }) async {
    final dto = await taskApi.requestHold(
      id.value,
      HoldTaskRequestDto(
        missingItemDescription: missingItemDescription,
        inventoryItemId: inventoryItemId,
      ),
    );
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> approveSuspension(TaskId id) async {
    final dto = await taskApi.approveHold(id.value);
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> rejectSuspension(TaskId id) async {
    final dto = await taskApi.rejectHold(id.value);
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> resume(TaskId id) async {
    final dto = await taskApi.resume(id.value);
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> complete(
    TaskId id,
    Decimal actualLaborHours, {
    String? notes,
  }) async {
    final dto = await taskApi.complete(
      id.value,
      CompleteTaskRequestDto(actualLaborHours: actualLaborHours, notes: notes),
    );
    await _saveIfMine(dto);
    return dto.toDomain();
  }

  @override
  Future<void> attachEvidence(
    TaskId id,
    String workOrderId,
    File photo,
    String description,
  ) {
    return evidenceCapture.capture(
      taskId: id.value,
      workOrderId: workOrderId,
      photo: photo,
      description: description,
    );
  }

  @override
  Stream<List<PendingEvidence>> observePendingEvidence(TaskId id) {
    final operationsStream = pendingOperationDao.watchByTypeAndDedupePrefix(
      AttachTaskEvidenceHandler.type,
      TaskEvidenceCapture.evidencePrefix(id.value),
    );
    final uploadsStream = pendingUploadDao.watchByTarget(
      TaskEvidenceCapture.target,
    );

    return combineLatest2(
      operationsStream,
      uploadsStream,
      (operations, uploads) => (operations, uploads),
    ).asyncMap((rows) async {
      final (operations, uploads) = rows;
      // `pending_uploads` guarda la ruta relativa: en iOS la carpeta cambia al actualizar la app.
      final directory = await supportDirectory();
      final localFiles = {
        for (final upload in uploads)
          upload.id: '${directory.path}/${upload.localFilePath}',
      };
      final prefix = TaskEvidenceCapture.evidencePrefix(id.value);

      return operations.map((operation) {
        final payload = AttachTaskEvidencePayload.fromJson(
          jsonDecode(operation.payload) as Map<String, dynamic>,
        );
        final photoId = operation.dedupeKey.startsWith(prefix)
            ? operation.dedupeKey.substring(prefix.length)
            : '';
        return PendingEvidence(
          operationId: operation.id,
          localFilePath: localFiles[photoId],
          imageUrl: payload.imageUrl,
          description: payload.description,
          status: operation.status,
          lastErrorMessage: operation.lastErrorMessage,
          capturedAt: DateTime.fromMillisecondsSinceEpoch(
            operation.createdAt,
            isUtc: true,
          ),
        );
      }).toList();
    });
  }

  @override
  Future<List<PartOption>> searchParts(String query) async {
    final dtos = await inventoryApi.getItems(
      search: query.isEmpty ? null : query,
    );
    return dtos.map(_toDomainPartOption).toList();
  }

  @override
  Future<TaskProduct> addPart(
    TaskId id,
    String productId,
    Decimal quantity,
  ) async {
    final dto = await taskApi.addProduct(
      id.value,
      AddTaskProductRequestDto(productId: productId, quantity: quantity),
    );
    return dto.toDomain();
  }

  @override
  Future<TaskDetail> updatePartQuantity(
    TaskId id,
    String productId,
    Decimal quantity,
  ) async {
    await taskApi.updateProduct(
      id.value,
      productId,
      UpdateTaskProductRequestDto(quantity: quantity),
    );
    return getDetail(id);
  }

  @override
  Future<void> removePart(TaskId id, String productId) {
    return taskApi.removeProduct(id.value, productId);
  }

  Future<void> _saveIfMine(WorkOrderTaskDto dto) async {
    if (dto.status == 'COMPLETED' || dto.status == 'CANCELLED') {
      await taskDao.deleteById(dto.id);
      return;
    }
    await taskDao.mergeDetail(
      id: dto.id,
      status: dto.status ?? '',
      description: dto.description ?? '',
      serviceName: dto.serviceName,
      mechanicId: dto.mechanicId,
      holdReason: dto.holdReason,
      missingItemDescription: dto.missingItemDescription,
      pendingSuspensionReason: dto.pendingSuspensionReason,
      startedAt: DateTime.tryParse(dto.startedAt ?? '')?.millisecondsSinceEpoch,
      totalPausedSeconds: dto.totalPausedSeconds ?? 0,
      syncedAt: now().millisecondsSinceEpoch,
    );
  }

  Future<void> _enrich(
    List<TasksCompanion> rows,
    Session currentSession,
    int timestamp,
  ) async {
    if (currentSession.has(Permission.baysRead)) {
      final branchIds = rows
          .map((r) => r.branchId.value)
          .whereType<String>()
          .toSet();
      for (final branchId in branchIds) {
        if (await _isStale('bays:$branchId', baysTtlMillis, timestamp)) {
          await _refreshBays(branchId, timestamp);
        }
      }
    }
    if (currentSession.has(Permission.vehiclesRead)) {
      final vehicleIds = rows
          .map((r) => r.vehicleId.value)
          .toSet();
      for (final vehicleId in vehicleIds) {
        if (await _isStale(
          'vehicles:$vehicleId',
          vehiclesTtlMillis,
          timestamp,
        )) {
          await _refreshVehicle(vehicleId, timestamp);
        }
      }
    }
  }

  Future<void> _refreshBays(String branchId, int timestamp) async {
    try {
      final dtos = await bayApi.getBays(branchId);
      final companions = dtos
          .map(
            (dto) => BaysCompanion(
              id: Value(dto.id),
              branchId: Value(dto.branchId ?? branchId),
              name: Value(dto.name ?? ''),
              bayType: Value(dto.bayType ?? ''),
              status: Value(dto.status ?? ''),
              currentWorkOrderId: Value(dto.currentWorkOrderId),
              syncedAt: Value(timestamp),
            ),
          )
          .toList();
      await bayDao.replaceBranch(branchId, companions);
      await cacheMetadataDao.upsert(
        CacheMetadataCompanion(
          scope: Value('bays:$branchId'),
          lastSyncedAt: Value(timestamp),
          recordCount: Value(companions.length),
        ),
      );
    } on ApiException {
      // La bahía es un extra: se sigue con la caché. Un bug o un fallo de Drift sí suben.
    } on NetworkException {
      // Igual: sin red se sigue con la caché.
    }
  }

  Future<void> _refreshVehicle(String vehicleId, int timestamp) async {
    try {
      final dto = await vehicleApi.getVehicle(vehicleId);
      await vehicleDao.saveFromServer(
        dto.toEntity(timestamp).toCompanion(false),
      );
      await cacheMetadataDao.upsert(
        CacheMetadataCompanion(
          scope: Value('vehicles:$vehicleId'),
          lastSyncedAt: Value(timestamp),
          recordCount: const Value(1),
        ),
      );
    } on ApiException {
      // La placa es un extra: se sigue con la caché. Un bug o un fallo de Drift sí suben.
    } on NetworkException {
      // Igual: sin red se sigue con la caché.
    }
  }

  Future<bool> _isStale(String scope, int ttlMillis, int timestamp) async {
    final entry = await cacheMetadataDao.get(scope);
    if (entry == null) return true;
    return timestamp - entry.lastSyncedAt >= ttlMillis;
  }

  Task _toDomainTask(TaskWithRefs row) {
    return Task(
      id: TaskId(row.task.id),
      workOrderId: row.task.workOrderId,
      workOrderNumber: row.task.workOrderNumber,
      workOrderStatus: row.task.workOrderStatus,
      vehicleId: row.task.vehicleId,
      plate: row.plate,
      branchId: row.task.branchId,
      bayId: row.task.bayId,
      bayName: row.bayName,
      serviceName: row.task.serviceName,
      mechanicId: row.task.mechanicId,
      status: TaskStatus.fromString(row.task.status),
      description: row.task.description,
      estimatedHours: Decimal.tryParse(row.task.estimatedHours ?? ''),
      holdReason: HoldReason.fromString(row.task.holdReason),
      missingItemDescription: row.task.missingItemDescription,
      pendingSuspensionReason: row.task.pendingSuspensionReason,
      startedAt: row.task.startedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              row.task.startedAt!,
              isUtc: true,
            )
          : null,
      totalPausedSeconds: row.task.totalPausedSeconds,
    );
  }

  PartOption _toDomainPartOption(PartItemDto dto) {
    return PartOption(
      id: dto.id,
      name: dto.name ?? '',
      sku: dto.sku,
      category: dto.category,
      basePrice: dto.basePrice,
      totalStock: dto.totalStock ?? Decimal.zero,
      unitOfMeasure: dto.unitOfMeasure,
    );
  }

  TasksCompanion _toTasksCompanion(AssignedTaskDto dto, int timestamp) {
    return TasksCompanion(
      id: Value(dto.taskId),
      workOrderId: Value(dto.workOrderId),
      workOrderNumber: Value(dto.workOrderNumber),
      workOrderStatus: Value(dto.workOrderStatus),
      vehicleId: Value(dto.vehicleId),
      branchId: Value(dto.branchId),
      bayId: Value(dto.bayId),
      status: Value(dto.status ?? 'ASSIGNED'),
      description: Value(dto.description ?? ''),
      estimatedHours: Value(dto.estimatedHours?.toString()),
      startedAt: Value(
        DateTime.tryParse(dto.startedAt ?? '')?.millisecondsSinceEpoch,
      ),
      totalPausedSeconds: Value(dto.totalPausedSeconds ?? 0),
      syncedAt: Value(timestamp),
    );
  }
}
