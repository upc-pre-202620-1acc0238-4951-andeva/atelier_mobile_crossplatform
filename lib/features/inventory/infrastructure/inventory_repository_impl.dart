import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/batch_allocation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/inventory_cache_policy.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/inventory_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_request_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Offline-first para leer (06 §4): catálogo y lotes se guardan en `parts` y `batches` y la UI observa
/// Drift. Recibir una compra es en línea (06 §2): el comprobante se sube directo, sin la cola.
class InventoryRepositoryImpl implements InventoryRepository {
  static const _searchSize = 50;

  final InventoryApi api;
  final PartDao partDao;
  final BatchDao batchDao;
  final CacheMetadataDao cacheMetadataDao;
  final SupabaseUploader uploader;
  final SessionManager session;
  final Future<Directory> Function() cacheDirectory;
  final DateTime Function() now;

  const InventoryRepositoryImpl({
    required this.api,
    required this.partDao,
    required this.batchDao,
    required this.cacheMetadataDao,
    required this.uploader,
    required this.session,
    required this.cacheDirectory,
    this.now = DateTime.now,
  });

  /// El backend pagina en memoria y no da el total: se piden páginas hasta recibir menos de una
  /// completa. Solo se reemplaza la caché cuando llegaron todas; si una falla, se conserva la anterior.
  @override
  Future<void> refreshCatalog({bool force = false}) async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    if (!current.has(Permission.partsRead)) return;
    if (!force && !await _isStale(InventoryCachePolicy.catalogScope)) return;

    final byId = <String, PartItemDto>{};
    for (var page = 0; page < InventoryCachePolicy.maxPages; page++) {
      final dtos = await api.getItems(
        page: page,
        size: InventoryCachePolicy.pageSize,
      );
      for (final dto in dtos) {
        byId.putIfAbsent(dto.id, () => dto);
      }
      if (dtos.length < InventoryCachePolicy.pageSize) break;
    }
    final timestamp = _timestamp();
    final rows = byId.values.map((dto) => dto.toEntity(timestamp)).toList();
    await partDao.replaceAll(rows);
    await _markSynced(
      InventoryCachePolicy.catalogScope,
      timestamp,
      rows.length,
    );
  }

  @override
  Stream<List<Part>> observeCatalog({ItemCategory? category}) {
    return partDao
        .watchAll(category: category?.value)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<List<Part>> searchParts(String query, {ItemCategory? category}) async {
    final List<PartItemDto> dtos;
    try {
      dtos = await api.getItems(
        search: query,
        category: category?.value,
        size: _searchSize,
      );
    } on NetworkException {
      final rows = await partDao.search(query, category: category?.value);
      return rows.map((row) => row.toDomain()).toList();
    }
    return _saveParts(dtos);
  }

  @override
  Future<Part?> findBySku(String sku) async {
    final normalized = InventoryValidation.normalizeSku(sku);
    final PartItemDto dto;
    try {
      dto = await api.getBySku(normalized);
    } on ApiException catch (e) {
      if (e.httpStatus == 404) return null;
      rethrow;
    } on NetworkException {
      return (await partDao.findBySku(normalized))?.toDomain();
    }
    return (await _saveParts([dto])).single;
  }

  @override
  Stream<Part?> observePart(String id) {
    return partDao.watchById(id).map((row) => row?.toDomain());
  }

  /// Los lotes en línea traen más campos que la caché; sin `batches:read` el detalle va sin lotes.
  @override
  Future<PartDetail> getPartDetail(String id) async {
    final current = await session.getSession();
    final canReadBatches = current?.has(Permission.batchesRead) ?? false;

    final PartDetailDto dto;
    try {
      dto = await api.getItem(id);
    } on NetworkException {
      final row = await partDao.findById(id);
      if (row == null) rethrow;
      final batches = canReadBatches
          ? await batchDao.findForItem(id)
          : const <BatchEntity>[];
      return PartDetail(
        part: row.toDomain(),
        batches: batches.map((batch) => batch.toDomain()).toList(),
      );
    }

    final part = (await _saveParts([dto.part])).single;
    if (!canReadBatches) return PartDetail(part: part, batches: const []);
    final batches = dto.batches ?? const <BatchDto>[];
    await _saveBatches(id, batches);
    return PartDetail(
      part: part,
      batches: batches.map((batch) => batch.toDomain(id)).toList()..sort(_fifo),
    );
  }

  @override
  Future<void> refreshBatches(String itemId, {bool force = false}) async {
    final current = await session.getSession();
    if (current?.has(Permission.batchesRead) != true) return;
    final scope = InventoryCachePolicy.batchesScope(itemId);
    if (!force && !await _isStale(scope)) return;
    await _saveBatches(itemId, await api.getBatches(itemId));
  }

  @override
  Future<Part> createPart({
    required String name,
    required String sku,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    String? unitOfMeasure = 'UNIT',
  }) async {
    final dto = await api.createItem(
      CreatePartRequestDto(
        name: name.trim(),
        sku: InventoryValidation.normalizeSku(sku),
        category: category.value,
        basePrice: basePrice,
        minimumStock: minimumStock,
        unitOfMeasure: _blankToNull(unitOfMeasure) ?? 'UNIT',
      ),
    );
    return (await _saveParts([dto])).single;
  }

  @override
  Future<Part> updatePart(
    String id, {
    required String name,
    required ItemCategory category,
    required Decimal basePrice,
    required Decimal minimumStock,
    PartStatus? status,
    String? unitOfMeasure,
  }) async {
    final dto = await api.updateItem(
      id,
      UpdatePartRequestDto(
        name: name.trim(),
        category: category.value,
        basePrice: basePrice,
        minimumStock: minimumStock,
        status: status?.value,
        unitOfMeasure: _blankToNull(unitOfMeasure),
      ),
    );
    return (await _saveParts([dto])).single;
  }

  @override
  Stream<List<PartBatch>> observeBatches(String itemId) {
    return batchDao
        .watchForItem(itemId)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<PartBatch> receiveDirectBatch(
    String itemId, {
    required String batchNumber,
    required Decimal quantity,
    required Decimal unitCost,
    DateTime? arrivalDate,
    String? supplierId,
  }) async {
    final dto = await api.receiveBatch(
      ReceiveBatchRequestDto(
        itemId: itemId,
        batchNumber: batchNumber.trim(),
        quantity: quantity,
        unitCost: unitCost,
        arrivalDate: arrivalDate,
        supplierId: _blankToNull(supplierId),
      ),
    );
    await _bestEffort(() => _syncPartAndBatches(itemId));
    return dto.toDomain(itemId);
  }

  @override
  Future<StockAllocation> dispatchFifoBatch(
    String itemId, {
    required Decimal quantity,
    String? workOrderId,
    String? taskId,
  }) async {
    final dto = await api.dispatchBatchFifo(
      DispatchBatchFifoRequestDto(
        itemId: itemId,
        quantity: quantity,
        taskId: _blankToNull(taskId),
        workOrderId: _blankToNull(workOrderId),
      ),
    );
    await _bestEffort(() => _syncPartAndBatches(itemId));
    return dto.toDomain();
  }

  @override
  Future<BatchRestoreResult> restoreBatch(
    String itemId, {
    required Decimal quantity,
    String? batchId,
    String? reason,
    String? workOrderId,
  }) async {
    final dto = await api.restoreBatch(
      RestoreBatchRequestDto(
        itemId: itemId,
        quantity: quantity,
        batchId: _blankToNull(batchId),
        reason: _blankToNull(reason),
        workOrderId: _blankToNull(workOrderId),
      ),
    );
    await _bestEffort(() => _syncPartAndBatches(itemId));
    return dto.toDomain();
  }

  @override
  Future<List<StockAlert>> getStockAlerts() async {
    try {
      final dtos = await api.getAlerts();
      return dtos.map((dto) => dto.toDomain()).toList();
    } on NetworkException {
      final rows = await partDao.findLowStock();
      return rows.map((row) => row.toDomain().toStockAlert()).toList();
    }
  }

  @override
  Stream<List<Part>> observeLowStock() {
    return partDao.watchLowStock().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<InventoryValuation> getValuation() async {
    final valuation = await api.getValuation();
    return InventoryValuation(
      total: Money(amount: valuation ?? Decimal.zero, currency: Money.pen),
    );
  }

  @override
  Future<List<Supplier>> getSuppliers({String? search, String? status}) async {
    final dtos = await api.getSuppliers(
      search: _blankToNull(search),
      status: _blankToNull(status),
    );
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Supplier> createSupplier({
    required String businessName,
    required String taxId,
    String? contactName,
    String? phone,
    String? email,
    String? address,
  }) async {
    final dto = await api.createSupplier(
      RegisterSupplierRequestDto(
        businessName: businessName.trim(),
        taxId: InventoryValidation.normalizeTaxId(taxId),
        contactName: _blankToNull(contactName),
        phone: _blankToNull(phone),
        email: _blankToNull(email),
        address: _blankToNull(address),
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<Supplier> updateSupplier(
    String id, {
    String? businessName,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    bool? active,
  }) async {
    final dto = await api.updateSupplier(
      id,
      UpdateSupplierRequestDto(
        businessName: _blankToNull(businessName),
        contactName: _blankToNull(contactName),
        phone: _blankToNull(phone),
        email: _blankToNull(email),
        address: _blankToNull(address),
        active: active,
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<List<PurchaseOrder>> getPurchaseOrders({
    PurchaseOrderStatus? status,
  }) async {
    final dtos = await api.getPurchaseOrders(status: status?.value);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<PurchaseOrder> getPurchaseOrder(String id) async {
    return (await api.getPurchaseOrder(id)).toDomain();
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(
    String supplierId, {
    List<PurchaseOrderLineInput> items = const [],
    String? orderNumber,
    String? expectedDeliveryDate,
    String? notes,
  }) async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    final branchId = current.branchId;
    if (branchId == null) throw const MissingBranchException();
    final dto = await api.createPurchaseOrder(
      CreatePurchaseOrderRequestDto(
        branchId: branchId,
        supplierId: supplierId,
        items: items
            .map(
              (line) => CreatePurchaseOrderItemRequestDto(
                itemId: line.itemId,
                quantity: line.quantity,
                unitCost: line.unitCost,
              ),
            )
            .toList(),
        orderNumber: _blankToNull(orderNumber),
        expectedDeliveryDate: _blankToNull(expectedDeliveryDate),
        notes: _blankToNull(notes),
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<PurchaseOrder> addPurchaseOrderItem(
    String purchaseOrderId, {
    required String itemId,
    required Decimal quantity,
    required Decimal unitCost,
  }) async {
    final dto = await api.addPurchaseOrderItem(
      purchaseOrderId,
      CreatePurchaseOrderItemRequestDto(
        itemId: itemId,
        quantity: quantity,
        unitCost: unitCost,
      ),
    );
    return dto.toDomain();
  }

  @override
  Future<PurchaseOrder> issuePurchaseOrder(String id) async {
    return (await api.issuePurchaseOrder(id)).toDomain();
  }

  @override
  Future<PurchaseOrder> cancelPurchaseOrder(String id, {String? reason}) async {
    final dto = await api.cancelPurchaseOrder(
      id,
      CancelPurchaseOrderRequestDto(reason: _blankToNull(reason)),
    );
    return dto.toDomain();
  }

  /// H15: el backend responde 400 a todo y no es idempotente. Se lee la orden antes de subir la foto
  /// (ya `RECEIVED` = éxito sin subir nada) y, si el `PUT` falla con 400 o se corta la red, se vuelve
  /// a leer.
  @override
  Future<PurchaseOrder> receivePurchaseOrder(
    String id,
    String receiptNumber,
    File photo, {
    DateTime? receivedAt,
  }) async {
    final order = await getPurchaseOrder(id);
    if (order.status == PurchaseOrderStatus.received) return order;
    if (!order.canBeReceived) {
      throw PurchaseOrderNotReceivableException(order.status);
    }
    final tenantId = (await session.getSession())?.tenantId;
    if (tenantId == null) throw StateError('Sin sesión');

    final imageUrl = await _uploadReceipt(tenantId, id, photo);
    final received = await _confirmReceipt(
      id,
      ReceivePurchaseOrderRequestDto(
        receiptImageUrl: imageUrl,
        receiptNumber: receiptNumber,
        receivedAt: receivedAt,
      ),
    );
    await _reloadAfterReceipt(received);
    return received;
  }

  Future<String> _uploadReceipt(
    String tenantId,
    String orderId,
    File photo,
  ) async {
    final photoId = StoragePaths.newId();
    final directory = await cacheDirectory();
    final local = File('${directory.path}/receipts/$photoId.jpg');
    final storagePath = StoragePaths.purchaseReceipt(
      tenantId,
      orderId,
      photoId,
    );
    try {
      await uploader.upload(
        await uploader.compress(photo.path, local),
        storagePath,
      );
    } finally {
      if (await local.exists()) await local.delete();
    }
    return uploader.publicUrlFor(storagePath);
  }

  Future<PurchaseOrder> _confirmReceipt(
    String id,
    ReceivePurchaseOrderRequestDto body,
  ) async {
    try {
      return (await api.receivePurchaseOrder(id, body)).toDomain();
    } on NetworkException catch (error, stack) {
      return _receivedOrThrow(id, error, stack);
    } on ApiException catch (error, stack) {
      if (error.httpStatus != 400) rethrow;
      return _receivedOrThrow(id, error, stack);
    }
  }

  /// Si la relectura también falla, lo que importa al usuario es el error original.
  Future<PurchaseOrder> _receivedOrThrow(
    String id,
    Object error,
    StackTrace stack,
  ) async {
    PurchaseOrder? order;
    try {
      order = await getPurchaseOrder(id);
    } on Exception {
      order = null;
    }
    if (order?.status == PurchaseOrderStatus.received) return order!;
    Error.throwWithStackTrace(error, stack);
  }

  /// El stock subió: catálogo completo (la alerta sale sola, US34 E2) y lotes de lo recibido. La
  /// recepción ya creó los lotes: que falle una recarga no la vuelve un error, se corrige al refrescar.
  Future<void> _reloadAfterReceipt(PurchaseOrder order) async {
    await _bestEffort(() => refreshCatalog(force: true));
    final itemIds = order.lines.map((line) => line.itemId).toSet();
    for (final itemId in itemIds) {
      await _bestEffort(() => refreshBatches(itemId, force: true));
    }
  }

  /// Tras mover stock a mano: la ficha del repuesto y sus lotes, desde el servidor.
  Future<void> _syncPartAndBatches(String itemId) async {
    await getPartDetail(itemId);
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _bestEffort(Future<void> Function() reload) async {
    try {
      await reload();
    } catch (_) {
      // Incluye `StateError` y un JSON mal formado, no solo los fallos de red.
    }
  }

  Future<List<Part>> _saveParts(List<PartItemDto> dtos) async {
    final timestamp = _timestamp();
    final rows = dtos.map((dto) => dto.toEntity(timestamp)).toList();
    await partDao.upsertAll(rows);
    return rows.map((row) => row.toDomain()).toList();
  }

  Future<void> _saveBatches(String itemId, List<BatchDto> dtos) async {
    final timestamp = _timestamp();
    final rows = dtos.map((dto) => dto.toEntity(itemId, timestamp)).toList();
    await batchDao.replaceForItem(itemId, rows);
    await _markSynced(
      InventoryCachePolicy.batchesScope(itemId),
      timestamp,
      rows.length,
    );
  }

  Future<void> _markSynced(String scope, int timestamp, int count) {
    return cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(scope),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(count),
      ),
    );
  }

  Future<bool> _isStale(String scope) async {
    final metadata = await cacheMetadataDao.get(scope);
    if (metadata == null) return true;
    return _timestamp() - metadata.lastSyncedAt >=
        InventoryCachePolicy.ttl.inMilliseconds;
  }

  int _timestamp() => now().millisecondsSinceEpoch;

  /// FIFO: el más antiguo primero; sin fecha, al final.
  static int _fifo(PartBatch a, PartBatch b) {
    final first = a.arrivalDate;
    final second = b.arrivalDate;
    if (first == null) return second == null ? 0 : 1;
    if (second == null) return -1;
    return first.compareTo(second);
  }
}
