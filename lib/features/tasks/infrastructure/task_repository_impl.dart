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
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_mappers.dart';
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
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

class TaskRepositoryImpl implements TaskRepository {
  static const scopeMyTasks = 'tasks:my';
  static const baysTtlMillis = 30 * 1000; // 30s
  static const vehiclesTtlMillis = 7 * 24 * 60 * 60 * 1000; // 7 days

  /// Tope de órdenes que se leen una a una al armar la vista de supervisión del taller.
  static const workshopOrdersLimit = 15;
  static const _closedOrderStatuses = {'PAID', 'CANCELED', 'COMPLETED'};

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

  /// Solo para la vista de supervisión del taller (Dueño, Administrador, Asesor). Sin él, solo `tasks/my`.
  final WorkOrderApi? workOrderApi;

  /// Nombres de repuestos del catálogo por taller, mientras viva el proceso.
  (String, Map<String, String>)? _cachedPartNames;

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
    this.workOrderApi,
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

  /// Recarga `tasks:my` (al abrir y al tocar `TASK_ASSIGNED`), o todas las tareas activas de las
  /// órdenes de la sede cuando la sesión es de supervisión del taller (Dueño, Administrador,
  /// Asesor) y no ejecuta cronómetro propio.
  @override
  Future<void> refreshMyTasks() async {
    final currentSession = await session.getSession();
    if (currentSession == null) throw StateError('Sin sesión');
    if (!currentSession.has(Permission.tasksRead)) return;
    final timestamp = now().millisecondsSinceEpoch;
    final branchId = currentSession.branchId;
    final canReadOrders =
        workOrderApi != null &&
        currentSession.has(Permission.workOrdersRead) &&
        branchId != null &&
        branchId.isNotEmpty;
    final isWorkshopSupervisor =
        !currentSession.has(Permission.tasksTrackTime) &&
        (currentSession.has(Permission.workOrdersUpdate) ||
            currentSession.has(Permission.tasksHoldValidate) ||
            currentSession.has(Permission.baysReassign));

    if (isWorkshopSupervisor && canReadOrders) {
      final rows = await _loadWorkshopTasks(branchId, timestamp);
      await _replaceMine(rows, timestamp);
      await _enrich(rows, currentSession, timestamp);
      return;
    }

    final dtos = await taskApi.getMyTasks();
    var rows = dtos.map((dto) => _toTasksCompanion(dto, timestamp)).toList();
    if (rows.isEmpty &&
        canReadOrders &&
        currentSession.has(Permission.tasksHoldValidate)) {
      final fallback = await _loadWorkshopTasksOrNull(branchId, timestamp);
      if (fallback != null && fallback.isNotEmpty) rows = fallback;
    }
    await _replaceMine(rows, timestamp);
    await _enrich(rows, currentSession, timestamp);
  }

  Future<void> _replaceMine(List<TasksCompanion> rows, int timestamp) async {
    await taskDao.replaceMine(rows);
    await cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: const Value(scopeMyTasks),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(rows.length),
      ),
    );
  }

  /// Tareas abiertas de las órdenes activas de la sede (las primeras [workshopOrdersLimit]); el
  /// detalle de cada orden que falle se omite.
  Future<List<TasksCompanion>> _loadWorkshopTasks(
    String branchId,
    int timestamp,
  ) async {
    final api = workOrderApi!;
    final summaries = await api.getWorkOrders(branchId);
    final active = summaries
        .where((order) => !_closedOrderStatuses.contains(order.status))
        .take(workshopOrdersLimit)
        .toList();
    final details = await Future.wait(
      active.map((summary) async {
        try {
          return await api.getWorkOrder(summary.id);
        } on ApiException {
          return null;
        } on NetworkException {
          return null;
        }
      }),
    );
    return [
      for (final order in details.nonNulls)
        for (final task in order.tasks ?? const <WorkOrderTaskDto>[])
          if (task.status != TaskStatus.completed.value &&
              task.status != TaskStatus.cancelled.value)
            TasksCompanion(
              id: Value(task.id),
              workOrderId: Value(order.id),
              workOrderNumber: Value(order.internalNumber),
              workOrderStatus: Value(order.status),
              vehicleId: Value(order.vehicleId),
              branchId: Value(order.branchId),
              bayId: Value(order.currentBayId),
              serviceName: Value(cleanServiceName(task.serviceName)),
              mechanicId: Value(task.mechanicId),
              status: Value(task.status ?? ''),
              description: Value(task.description ?? ''),
              estimatedHours: const Value(null),
              holdReason: Value(task.holdReason),
              missingItemDescription: Value(task.missingItemDescription),
              pendingSuspensionReason: Value(task.pendingSuspensionReason),
              pendingSuspensionRequestedAt: Value(
                _epochMillis(task.pendingSuspensionRequestedAt),
              ),
              startedAt: Value(_epochMillis(task.startedAt)),
              totalPausedSeconds: Value(task.totalPausedSeconds ?? 0),
              syncedAt: Value(timestamp),
            ),
    ];
  }

  Future<List<TasksCompanion>?> _loadWorkshopTasksOrNull(
    String branchId,
    int timestamp,
  ) async {
    try {
      return await _loadWorkshopTasks(branchId, timestamp);
    } on ApiException {
      return null;
    } on NetworkException {
      return null;
    }
  }

  @override
  Future<TaskDetail> getDetail(TaskId id) async {
    return _finish(await taskApi.getTask(id.value));
  }

  @override
  Future<TaskDetail> start(TaskId id) async {
    return _finish(await taskApi.start(id.value));
  }

  @override
  Future<TaskDetail> pause(TaskId id, PauseReason reason) async {
    return _finish(
      await taskApi.pause(id.value, PauseTaskRequestDto(reason: reason.value)),
    );
  }

  @override
  Future<TaskDetail> requestSuspension(
    TaskId id,
    String missingItemDescription, {
    String? inventoryItemId,
  }) async {
    return _finish(
      await taskApi.requestHold(
        id.value,
        HoldTaskRequestDto(
          missingItemDescription: missingItemDescription,
          inventoryItemId: inventoryItemId,
        ),
      ),
    );
  }

  @override
  Future<TaskDetail> approveSuspension(TaskId id) async {
    return _finish(await taskApi.approveHold(id.value));
  }

  @override
  Future<TaskDetail> rejectSuspension(TaskId id) async {
    return _finish(await taskApi.rejectHold(id.value));
  }

  @override
  Future<TaskDetail> resume(TaskId id) async {
    return _finish(await taskApi.resume(id.value));
  }

  @override
  Future<TaskDetail> complete(
    TaskId id,
    Decimal actualLaborHours, {
    String? notes,
  }) async {
    return _finish(
      await taskApi.complete(
        id.value,
        CompleteTaskRequestDto(
          actualLaborHours: actualLaborHours,
          notes: notes,
        ),
      ),
    );
  }

  @override
  Future<TaskDetail> reopen(TaskId id, {String? reason}) async {
    return _finish(await taskApi.reopen(id.value, reason: reason));
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

  /// Deja al día `tasks:my` con lo que devolvió el backend y completa el nombre de los repuestos.
  Future<TaskDetail> _finish(WorkOrderTaskDto dto) async {
    await _saveIfMine(dto);
    return _enrichProducts(dto.toDomain());
  }

  /// El backend no siempre manda el nombre del repuesto: se completa con el catálogo (una lectura por
  /// taller mientras viva el proceso) si la sesión puede leerlo. Nunca hace fallar la acción.
  Future<TaskDetail> _enrichProducts(TaskDetail detail) async {
    final missing = detail.products.any(
      (p) => p.productName == null || p.productName!.trim().isEmpty,
    );
    if (!missing) return detail;
    final current = await session.getSession();
    if (current == null || !current.has(Permission.partsRead)) return detail;

    var names = _cachedPartNames?.$1 == current.tenantId
        ? _cachedPartNames!.$2
        : null;
    if (names == null) {
      try {
        final items = await inventoryApi.getItems();
        names = {
          for (final item in items)
            if (item.name != null && item.name!.trim().isNotEmpty)
              item.id: item.name!,
        };
        if (names.isNotEmpty) _cachedPartNames = (current.tenantId, names);
      } on ApiException {
        return detail;
      } on NetworkException {
        return detail;
      }
    }
    if (names.isEmpty) return detail;

    return TaskDetail(
      id: detail.id,
      workOrderId: detail.workOrderId,
      serviceId: detail.serviceId,
      serviceName: detail.serviceName,
      mechanicId: detail.mechanicId,
      mechanicName: detail.mechanicName,
      status: detail.status,
      description: detail.description,
      price: detail.price,
      currency: detail.currency,
      holdReason: detail.holdReason,
      missingItemDescription: detail.missingItemDescription,
      totalPausedSeconds: detail.totalPausedSeconds,
      startedAt: detail.startedAt,
      completedAt: detail.completedAt,
      pendingSuspensionReason: detail.pendingSuspensionReason,
      pendingSuspensionRequestedAt: detail.pendingSuspensionRequestedAt,
      products: [
        for (final product in detail.products)
          if (product.productName == null || product.productName!.trim().isEmpty)
            TaskProduct(
              id: product.id,
              productId: product.productId,
              productName: names[product.productId],
              quantity: product.quantity,
              unitPrice: product.unitPrice,
              totalAmount: product.totalAmount,
            )
          else
            product,
      ],
      evidenceImages: detail.evidenceImages,
    );
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
      pendingSuspensionRequestedAt: _epochMillis(
        dto.pendingSuspensionRequestedAt,
      ),
      startedAt: _epochMillis(dto.startedAt),
      totalPausedSeconds: dto.totalPausedSeconds ?? 0,
      syncedAt: now().millisecondsSinceEpoch,
    );
  }

  int? _epochMillis(String? iso) {
    return DateTime.tryParse(iso ?? '')?.millisecondsSinceEpoch;
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
          .map((dto) => dto.toCompanion(branchId, timestamp))
          .toList();
      await bayDao.replaceBranch(branchId, companions);
      await cacheMetadataDao.upsert(
        CacheMetadataCompanion(
          scope: Value(bayCacheScope(branchId)),
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
      pendingSuspensionRequestedAt: row.task.pendingSuspensionRequestedAt != null
          ? DateTime.fromMillisecondsSinceEpoch(
              row.task.pendingSuspensionRequestedAt!,
              isUtc: true,
            )
          : null,
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
