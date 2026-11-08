import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

/// Órdenes de trabajo (US12–US15, US22, US24, US25, US36, US33 E2, US35 E2). La UI observa la caché
/// `work_orders`; el detalle se lee en línea. Fotos de recepción y propuestas van siempre a la cola
/// (06 §6); el resto es en línea (06 §2): sin red lanza `NetworkException` y no se encola.
abstract class WorkOrderRepository {
  /// Recarga las órdenes no cerradas de la sede de la sesión. Sin sede lanza `MissingBranchException`.
  Future<void> refreshBranchWorkOrders();

  Stream<List<WorkOrder>> observeBranchWorkOrders();

  Stream<WorkOrder?> observeWorkOrder(WorkOrderId id);

  Future<WorkOrderDetail> getDetail(WorkOrderId id);

  /// La orden en borrador que el backend crea tras la llegada de una cita (H10), o `null` si aún no
  /// existe.
  Future<WorkOrder?> findDraftForVehicle(String branchId, String vehicleId);

  Future<WorkOrder> open(NewWorkOrder workOrder);

  Future<WorkOrder> update(
    WorkOrderId id, {
    int? mileageIn,
    String? diagnosticSummary,
  });

  Future<WorkOrderDetail> addTask(WorkOrderId id, NewWorkOrderTask task);

  Future<WorkOrderDetail> updateTask(
    WorkOrderId id,
    TaskId taskId,
    WorkOrderTaskChanges changes,
  );

  Future<List<ServiceOption>> getServiceCatalog();

  Future<List<MechanicOption>> getBranchMechanics();

  Future<void> attachIntakePhoto(
    WorkOrderId id,
    File photo, {
    String? description,
  });

  Stream<List<PendingIntakePhoto>> observePendingIntakePhotos(WorkOrderId id);

  /// El `mechanicId` que pide el backend es el membershipId de la sesión.
  Future<void> submitProposal(
    WorkOrderId id, {
    required String description,
    required ProposalSeverity severity,
    required File photo,
    String? suggestedServiceId,
  });

  Stream<List<PendingProposal>> observePendingProposals(WorkOrderId id);

  /// Devuelve el correo al que se envió.
  Future<String> notifyProposal(WorkOrderId id, String proposalId);

  Future<WorkOrderDetail> approveProposal(
    WorkOrderId id,
    String proposalId,
    ProposalApproval approval,
  );

  Future<Proposal> rejectProposal(
    WorkOrderId id,
    String proposalId,
    String customerNotes,
  );

  /// El PDF en la caché; abrirlo y compartirlo es de la UI.
  Future<File> downloadQuotationPdf(WorkOrderId id);

  /// Devuelve el correo del cliente al que se envió.
  Future<String> sendQuotation(WorkOrderId id);

  Future<WorkOrder> approveQuotation(WorkOrderId id);

  Future<WorkOrder> rejectQuotation(WorkOrderId id, String reason);

  /// Pasa la orden a `IN_PROGRESS`; un 422 trae el `message` de la transición inválida.
  Future<WorkOrder> start(WorkOrderId id);

  Future<WorkOrder> complete(WorkOrderId id);

  /// Libera bahía y reservas; la orden `CANCELED` sale de la caché de la sede.
  Future<WorkOrder> cancel(WorkOrderId id, String reason);

  /// Pago formal de la orden (US39 E2); el backend rechaza si queda saldo. La orden `PAID` sale de
  /// la caché de la sede.
  Future<WorkOrder> markAsPaid(WorkOrderId id);

  /// Entrega el vehículo y libera la bahía (US39 E2). Sin firma del cliente (H29).
  Future<WorkOrder> deliver(WorkOrderId id);

  /// PDF del pase de salida en la caché (US39 E2/E3); una orden sin pagar da el `message` del 422.
  Future<File> downloadExitPass(WorkOrderId id);

  Future<List<PartMovement>> getPartMovements(WorkOrderId id);

  Future<Profitability> getProfitability(WorkOrderId id);
}
