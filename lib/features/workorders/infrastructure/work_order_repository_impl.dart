import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/combine_latest.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/core/media/storage_paths.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/service_catalog_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_dto.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_payloads.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_request_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/attach_intake_image_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/submit_proposal_handler.dart';
import 'package:drift/drift.dart';

/// Offline-first para la cabecera (06 §4): la UI observa `work_orders` y cada respuesta del backend
/// la actualiza. El detalle es en línea. Fotos de recepción y propuestas van siempre a la cola con
/// `PhotoCapture` (06 §6); el resto es en línea (06 §2).
class WorkOrderRepositoryImpl implements WorkOrderRepository {
  static const intakeTarget = 'INTAKE';
  static const proposalTarget = 'PROPOSAL';
  static const _active = 'ACTIVE';

  static String branchScope(String branchId) => 'work_orders:$branchId';

  /// El prefijo agrupa las fotos en cola de una orden; el sufijo es el id de la foto.
  static String intakePrefix(String id) => 'INTAKE_IMAGE:$id:';

  static String proposalPrefix(String id) => 'PROPOSAL:$id:';

  final WorkOrderApi workOrderApi;
  final ServiceCatalogApi serviceCatalogApi;
  final EmployeeApi employeeApi;
  final WorkOrderDao workOrderDao;
  final CacheMetadataDao cacheMetadataDao;
  final PendingOperationDao pendingOperationDao;
  final PendingUploadDao pendingUploadDao;
  final PhotoCapture photoCapture;
  final PdfDownloader pdfDownloader;
  final SessionManager session;
  final Future<Directory> Function() supportDirectory;
  final DateTime Function() now;

  /// El catálogo cambia poco: se lee una vez por taller mientras viva el proceso.
  (String, List<ServiceOption>)? _services;

  WorkOrderRepositoryImpl({
    required this.workOrderApi,
    required this.serviceCatalogApi,
    required this.employeeApi,
    required this.workOrderDao,
    required this.cacheMetadataDao,
    required this.pendingOperationDao,
    required this.pendingUploadDao,
    required this.photoCapture,
    required this.pdfDownloader,
    required this.session,
    required this.supportDirectory,
    this.now = DateTime.now,
  });

  @override
  Future<void> refreshBranchWorkOrders() async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    final branchId = current.branchId;
    if (branchId == null) throw const MissingBranchException();
    if (!current.has(Permission.workOrdersRead)) return;
    await _refreshBranch(branchId);
  }

  @override
  Stream<List<WorkOrder>> observeBranchWorkOrders() {
    return session.switchOn<String?, List<WorkOrder>>(
      (current) => current?.branchId,
      (branchId) {
        if (branchId == null) return Stream.value(const []);
        return workOrderDao
            .watchBranch(branchId)
            .map((rows) => rows.map((row) => row.toDomain()).toList());
      },
    );
  }

  @override
  Stream<WorkOrder?> observeWorkOrder(WorkOrderId id) {
    return workOrderDao.watchById(id.value).map((row) => row?.toDomain());
  }

  @override
  Future<WorkOrderDetail> getDetail(WorkOrderId id) async {
    final dto = await workOrderApi.getWorkOrder(id.value);
    return dto.toDetail(await _saveHeader(dto));
  }

  @override
  Future<WorkOrder?> findDraftForVehicle(
    String branchId,
    String vehicleId,
  ) async {
    final open = await _refreshBranch(branchId);
    for (final dto in open) {
      if (dto.vehicleId == vehicleId &&
          dto.status == WorkOrderStatus.draft.value) {
        return (await workOrderDao.findById(dto.id))?.toDomain();
      }
    }
    return null;
  }

  @override
  Future<WorkOrder> open(NewWorkOrder workOrder) async {
    final branchId = (await session.getSession())?.branchId;
    if (branchId == null) throw const MissingBranchException();
    return _saveHeader(
      await workOrderApi.create(
        CreateWorkOrderRequestDto(
          vehicleId: workOrder.vehicleId,
          customerId: workOrder.customerId,
          branchId: branchId,
          mileageIn: workOrder.mileageIn,
          diagnosticSummary: _blankToNull(workOrder.diagnosticSummary),
          appointmentId: workOrder.appointmentId,
        ),
      ),
    );
  }

  @override
  Future<WorkOrder> update(
    WorkOrderId id, {
    int? mileageIn,
    String? diagnosticSummary,
  }) async {
    return _saveHeader(
      await workOrderApi.update(
        id.value,
        UpdateWorkOrderRequestDto(
          mileageIn: mileageIn,
          diagnosticSummary: _blankToNull(diagnosticSummary),
        ),
      ),
    );
  }

  /// La tarea nueva cambia los totales y la respuesta no trae la orden: se recarga el detalle.
  @override
  Future<WorkOrderDetail> addTask(WorkOrderId id, NewWorkOrderTask task) async {
    await workOrderApi.addTask(
      id.value,
      CreateWorkOrderTaskRequestDto(
        serviceId: task.serviceId,
        description: task.description.trim(),
        mechanicId: task.mechanicId,
        price: task.price,
      ),
    );
    return getDetail(id);
  }

  @override
  Future<WorkOrderDetail> updateTask(
    WorkOrderId id,
    TaskId taskId,
    WorkOrderTaskChanges changes,
  ) async {
    await workOrderApi.updateTask(
      taskId.value,
      UpdateWorkOrderTaskRequestDto(
        description: _blankToNull(changes.description),
        mechanicId: changes.mechanicId,
        price: changes.price,
      ),
    );
    return getDetail(id);
  }

  @override
  Future<List<ServiceOption>> getServiceCatalog() async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    if (!current.has(Permission.servicesRead)) return [];
    final cached = _services;
    if (cached != null && cached.$1 == current.tenantId) return cached.$2;
    final dtos = await serviceCatalogApi.getServices();
    final services = dtos.map((dto) => dto.toDomain()).toList();
    _services = (current.tenantId, services);
    return services;
  }

  /// Sin `iam:members:read` no se puede listar (H11): lista vacía y la tarea se crea sin mecánico.
  @override
  Future<List<MechanicOption>> getBranchMechanics() async {
    final current = await session.getSession();
    if (current == null) throw StateError('Sin sesión');
    final branchId = current.branchId;
    if (branchId == null) throw const MissingBranchException();
    if (!current.has(Permission.membersRead)) return [];
    final dtos = await employeeApi.getByBranch(branchId);
    return dtos
        .where(
          (dto) =>
              dto.employmentStatus == null || dto.employmentStatus == _active,
        )
        .map((dto) => dto.toMechanicOption())
        .nonNulls
        .toList();
  }

  @override
  Future<void> attachIntakePhoto(
    WorkOrderId id,
    File photo, {
    String? description,
  }) async {
    await photoCapture.capture(
      photoPath: photo.path,
      target: intakeTarget,
      storagePath: (tenantId, photoId) {
        return StoragePaths.intake(tenantId, id.value, photoId);
      },
      attachType: AttachIntakeImageHandler.type,
      attachDedupeKey: (photoId) => '${intakePrefix(id.value)}$photoId',
      attachPayload: (imageUrl) => AttachIntakeImagePayload(
        workOrderId: id.value,
        imageUrl: imageUrl,
        description: _blankToNull(description),
      ),
    );
  }

  @override
  Stream<List<PendingIntakePhoto>> observePendingIntakePhotos(WorkOrderId id) {
    return _pending(
      AttachIntakeImageHandler.type,
      intakePrefix(id.value),
      intakeTarget,
      (operation, localFile) {
        final payload = AttachIntakeImagePayload.fromJson(
          jsonDecode(operation.payload) as Map<String, dynamic>,
        );
        return PendingIntakePhoto(
          operationId: operation.id,
          localFilePath: localFile,
          imageUrl: payload.imageUrl,
          description: payload.description,
          status: operation.status,
          lastErrorMessage: operation.lastErrorMessage,
          capturedAt: _capturedAt(operation),
        );
      },
    );
  }

  @override
  Future<void> submitProposal(
    WorkOrderId id, {
    required String description,
    required ProposalSeverity severity,
    required File photo,
    String? suggestedServiceId,
  }) async {
    final mechanicId = (await session.getSession())?.membershipId;
    if (mechanicId == null) throw StateError('Sin membresía en la sesión');
    await photoCapture.capture(
      photoPath: photo.path,
      target: proposalTarget,
      storagePath: (tenantId, photoId) {
        return StoragePaths.proposal(tenantId, id.value, photoId);
      },
      attachType: SubmitProposalHandler.type,
      attachDedupeKey: (photoId) => '${proposalPrefix(id.value)}$photoId',
      attachPayload: (imageUrl) => SubmitProposalPayload(
        workOrderId: id.value,
        mechanicId: mechanicId,
        description: description.trim(),
        severity: severity.value,
        imageUrl: imageUrl,
        suggestedServiceId: suggestedServiceId,
      ),
    );
  }

  @override
  Stream<List<PendingProposal>> observePendingProposals(WorkOrderId id) {
    return _pending(
      SubmitProposalHandler.type,
      proposalPrefix(id.value),
      proposalTarget,
      (operation, localFile) {
        final payload = SubmitProposalPayload.fromJson(
          jsonDecode(operation.payload) as Map<String, dynamic>,
        );
        return PendingProposal(
          operationId: operation.id,
          localFilePath: localFile,
          imageUrl: payload.imageUrl,
          description: payload.description,
          severity: ProposalSeverity.fromString(payload.severity),
          status: operation.status,
          lastErrorMessage: operation.lastErrorMessage,
          capturedAt: _capturedAt(operation),
        );
      },
    );
  }

  @override
  Future<String> notifyProposal(WorkOrderId id, String proposalId) async {
    final dto = await workOrderApi.notifyProposal(id.value, proposalId);
    return dto.recipient ?? '';
  }

  /// Crea la tarea y cambia los totales (US15 E1): se recarga el detalle.
  @override
  Future<WorkOrderDetail> approveProposal(
    WorkOrderId id,
    String proposalId,
    ProposalApproval approval,
  ) async {
    await workOrderApi.approveProposal(
      id.value,
      proposalId,
      ApproveProposalRequestDto(
        serviceId: approval.serviceId,
        finalPrice: approval.finalPrice,
        laborHours: approval.laborHours,
        mechanicId: approval.mechanicId,
        notes: _blankToNull(approval.notes),
      ),
    );
    return getDetail(id);
  }

  @override
  Future<Proposal> rejectProposal(
    WorkOrderId id,
    String proposalId,
    String customerNotes,
  ) async {
    final dto = await workOrderApi.rejectProposal(
      id.value,
      proposalId,
      RejectProposalRequestDto(customerNotes: customerNotes.trim()),
    );
    return dto.toDomain();
  }

  @override
  Future<File> downloadQuotationPdf(WorkOrderId id) {
    return pdfDownloader.download(
      'proforma-${id.value}',
      () => workOrderApi.getQuotationPdf(id.value),
    );
  }

  @override
  Future<String> sendQuotation(WorkOrderId id) async {
    final dto = await workOrderApi.sendQuotation(id.value);
    return dto.recipient ?? '';
  }

  @override
  Future<WorkOrder> approveQuotation(WorkOrderId id) async {
    return _saveHeader(await workOrderApi.approveQuotation(id.value));
  }

  @override
  Future<WorkOrder> rejectQuotation(WorkOrderId id, String reason) async {
    return _saveHeader(
      await workOrderApi.rejectQuotation(
        id.value,
        ReasonRequestDto(reason: reason.trim()),
      ),
    );
  }

  @override
  Future<WorkOrder> start(WorkOrderId id) async {
    return _saveHeader(await workOrderApi.start(id.value));
  }

  @override
  Future<WorkOrder> complete(WorkOrderId id) async {
    return _saveHeader(await workOrderApi.complete(id.value));
  }

  @override
  Future<WorkOrder> cancel(WorkOrderId id, String reason) async {
    return _saveHeader(
      await workOrderApi.cancel(
        id.value,
        ReasonRequestDto(reason: reason.trim()),
      ),
    );
  }

  @override
  Future<WorkOrder> markAsPaid(WorkOrderId id) async {
    return _savePaidHeader(await workOrderApi.markAsPaid(id.value));
  }

  @override
  Future<WorkOrder> deliver(WorkOrderId id) async {
    return _savePaidHeader(await workOrderApi.deliver(id.value));
  }

  /// El backend ya cobró o entregó: un fallo de la caché no puede parecer un fallo de la acción.
  Future<WorkOrder> _savePaidHeader(WorkOrderDto dto) async {
    try {
      return await _saveHeader(dto);
    } catch (_) {
      return dto.toEntity(now().millisecondsSinceEpoch).toDomain();
    }
  }

  @override
  Future<File> downloadExitPass(WorkOrderId id) {
    return pdfDownloader.download(
      'pase-salida-${id.value}',
      () => workOrderApi.getExitPassPdf(id.value),
    );
  }

  @override
  Future<List<PartMovement>> getPartMovements(WorkOrderId id) async {
    final dtos = await workOrderApi.getPartMovements(id.value);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<Profitability> getProfitability(WorkOrderId id) async {
    return (await workOrderApi.getProfitability(id.value)).toDomain();
  }

  /// Recarga `work_orders:{branchId}` sin las cerradas y devuelve lo que quedó.
  Future<List<WorkOrderDto>> _refreshBranch(String branchId) async {
    final timestamp = now().millisecondsSinceEpoch;
    final dtos = await workOrderApi.getWorkOrders(branchId);
    final open = dtos.where((dto) => !_isClosed(dto)).toList();
    final rows = open.map((dto) => dto.toEntity(timestamp)).toList();
    await workOrderDao.replaceBranch(branchId, rows);
    await cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(branchScope(branchId)),
        lastSyncedAt: Value(timestamp),
        recordCount: Value(rows.length),
      ),
    );
    return open;
  }

  /// Deja al día la cabecera. Una orden cerrada sale de la caché de la sede (06 §4).
  Future<WorkOrder> _saveHeader(WorkOrderDto dto) async {
    final row = dto.toEntity(now().millisecondsSinceEpoch);
    if (_isClosed(dto)) {
      await workOrderDao.deleteById(dto.id);
      return row.toDomain();
    }
    await workOrderDao.saveHeader(row);
    return (await workOrderDao.findById(dto.id))?.toDomain() ?? row.toDomain();
  }

  bool _isClosed(WorkOrderDto dto) {
    return WorkOrderStatus.fromString(dto.status)?.isClosed ?? false;
  }

  /// Operaciones en cola de un tipo para la orden, con el archivo local mientras no se suba.
  Stream<List<T>> _pending<T>(
    String type,
    String prefix,
    String target,
    T Function(PendingOperationEntity, String?) map,
  ) {
    return combineLatest2(
      pendingOperationDao.watchByTypeAndDedupePrefix(type, prefix),
      pendingUploadDao.watchByTarget(target),
      (operations, uploads) => (operations, uploads),
    ).asyncMap((rows) async {
      final (operations, uploads) = rows;
      // `pending_uploads` guarda la ruta relativa: en iOS la carpeta cambia al actualizar la app.
      final directory = await supportDirectory();
      final localFiles = {
        for (final upload in uploads)
          upload.id: '${directory.path}/${upload.localFilePath}',
      };
      return operations.map((operation) {
        final photoId = operation.dedupeKey.startsWith(prefix)
            ? operation.dedupeKey.substring(prefix.length)
            : '';
        return map(operation, localFiles[photoId]);
      }).toList();
    });
  }

  DateTime _capturedAt(PendingOperationEntity operation) {
    return DateTime.fromMillisecondsSinceEpoch(
      operation.createdAt,
      isUtc: true,
    );
  }

  String? _blankToNull(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}
