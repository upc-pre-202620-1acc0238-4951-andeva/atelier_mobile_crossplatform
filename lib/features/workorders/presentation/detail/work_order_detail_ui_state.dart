import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/cascade.dart';

const _genericServiceName = 'Standard Service';
const _genericProductPrefix = 'Product ';

const _keep = Object();

/// US40: hoja para asignar o cambiar la bahía de la orden.
class AssignBayForm {
  final bool isLoading;
  final List<WorkBay> bays;

  const AssignBayForm({this.isLoading = true, this.bays = const []});
}

/// Acción en línea en curso dentro del detalle/proforma de la orden.
enum WorkOrderDetailAction {
  approveSuspension,
  rejectSuspension,
  resumeSuspended,
  assignBay,
  addTask,
  editLabor,
  deleteTask,
  chargePart,
  editPart,
  removePart,
  downloadPdf,
  sendEmail,
  approveQuotation,
  rejectQuotation,
  assignMechanic,
  startOrder,
  completeOrder,
  cancelOrder,
}

/// Dato que se pide al abrir una hoja (movimientos de repuestos): nunca al abrir la ficha.
class OnDemand<T> {
  final bool isLoading;
  final T? data;
  final UiText? error;

  const OnDemand({this.isLoading = true, this.data, this.error});
}

/// Cancelar la orden: siempre se confirma en una hoja y exige el motivo.
class CancelOrderForm {
  final String reason;

  const CancelOrderForm({this.reason = ''});
}

/// US22 E1: formulario para agregar una nueva tarea con su servicio y mano de obra sin IGV.
class AddTaskForm {
  final String? serviceId;
  final String description;
  final String price;
  final String? mechanicId;

  const AddTaskForm({this.serviceId, this.description = '', this.price = '', this.mechanicId});

  AddTaskForm copyWith({
    Object? serviceId = _keep,
    String? description,
    String? price,
    Object? mechanicId = _keep,
  }) {
    return AddTaskForm(
      serviceId: identical(serviceId, _keep) ? this.serviceId : serviceId as String?,
      description: description ?? this.description,
      price: price ?? this.price,
      mechanicId: identical(mechanicId, _keep) ? this.mechanicId : mechanicId as String?,
    );
  }
}

/// US22 E2: formulario para actualizar el precio de mano de obra sin IGV de una tarea.
class EditLaborForm {
  final TaskId taskId;
  final String taskTitle;
  final String price;

  const EditLaborForm({required this.taskId, required this.taskTitle, required this.price});

  EditLaborForm copyWith({String? price}) =>
      EditLaborForm(taskId: taskId, taskTitle: taskTitle, price: price ?? this.price);
}

/// US25 E2: modal «Cancelar la orden» con el motivo obligatorio del desistimiento del cliente.
class RejectQuotationForm {
  final String reason;

  const RejectQuotationForm({this.reason = ''});
}

/// US23 / US32: buscar el repuesto e imputarlo a una tarea.
class ChargeForm {
  final String query;
  final List<PartOption> results;
  final bool isSearching;
  final PartOption? selected;
  final String quantity;

  const ChargeForm({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.selected,
    this.quantity = '1',
  });

  ChargeForm copyWith({
    String? query,
    List<PartOption>? results,
    bool? isSearching,
    Object? selected = _keep,
    String? quantity,
  }) {
    return ChargeForm(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      selected: identical(selected, _keep) ? this.selected : selected as PartOption?,
      quantity: quantity ?? this.quantity,
    );
  }
}

enum PartEditMode { editQuantity, returnPart }

/// US33: cambiar la cantidad de un repuesto imputado o devolverlo a su lote de origen.
class PartEditForm {
  final TaskProduct product;
  final PartEditMode mode;
  final String quantity;

  const PartEditForm({required this.product, required this.mode, required this.quantity});

  PartEditForm copyWith({String? quantity}) =>
      PartEditForm(product: product, mode: mode, quantity: quantity ?? this.quantity);
}

class WorkOrderDetailUiState {
  final WorkOrder? cachedOrder;
  final WorkOrderDetail? detail;
  final List<ServiceOption> services;
  final Map<String, String> partNamesById;
  final bool isLoading;
  final bool isOnline;
  final WorkOrderDetailAction? busyAction;
  final AddTaskForm? addTaskForm;
  final EditLaborForm? editLaborForm;
  final TaskDetail? deletingTask;
  final TaskId? chargeTaskId;
  final ChargeForm? chargeForm;
  final TaskId? editingPartTaskId;
  final PartEditForm? partEdit;
  final RejectQuotationForm? rejectForm;
  final File? generatedPdf;
  final String? proformaSentLabel;
  final UiText? notice;
  final UiText? error;
  final String? invalidField;
  final bool canUpdateWorkOrder;
  final bool canChargeParts;
  final bool canReadParts;
  final bool canReadQuotation;
  final bool canSendQuotation;
  final bool canApproveQuotation;
  final bool canReassignMechanic;
  final List<MechanicOption> availableMechanics;
  final TaskDetail? assigningMechanicTask;
  final CancelOrderForm? cancelForm;
  final bool showQuotationDecision;
  final OnDemand<List<PartMovement>>? movements;
  final bool canCancelWorkOrder;
  final bool canResolveProposals;
  final bool canReadPartMovements;
  final bool canOpenObd;
  final bool hasCheckoutPermission;

  /// US29: quien valida suspensiones y la tarea cuya solicitud está revisando.
  final bool canValidateSuspension;
  final TaskDetail? reviewingSuspensionTask;

  final bool canReassignBays;
  final AssignBayForm? assignBayForm;

  const WorkOrderDetailUiState({
    this.canReassignBays = false,
    this.assignBayForm,
    this.canValidateSuspension = false,
    this.reviewingSuspensionTask,
    this.cachedOrder,
    this.detail,
    this.services = const [],
    this.partNamesById = const {},
    this.isLoading = true,
    this.isOnline = true,
    this.busyAction,
    this.addTaskForm,
    this.editLaborForm,
    this.deletingTask,
    this.chargeTaskId,
    this.chargeForm,
    this.editingPartTaskId,
    this.partEdit,
    this.rejectForm,
    this.generatedPdf,
    this.proformaSentLabel,
    this.notice,
    this.error,
    this.invalidField,
    this.canUpdateWorkOrder = false,
    this.canChargeParts = false,
    this.canReadParts = false,
    this.canReadQuotation = false,
    this.canSendQuotation = false,
    this.canApproveQuotation = false,
    this.canReassignMechanic = false,
    this.availableMechanics = const [],
    this.assigningMechanicTask,
    this.cancelForm,
    this.showQuotationDecision = false,
    this.movements,
    this.canCancelWorkOrder = false,
    this.canResolveProposals = false,
    this.canReadPartMovements = false,
    this.canOpenObd = false,
    this.hasCheckoutPermission = false,
  });

  bool get isBusy => busyAction != null;

  WorkOrderStatus? get status => detail?.workOrder.status ?? cachedOrder?.status;
  bool get isDraft => status == WorkOrderStatus.draft;
  bool get isEditableOrder => status == WorkOrderStatus.draft || status == WorkOrderStatus.inProgress;

  bool get canModifyTasks => canUpdateWorkOrder && isEditableOrder && isOnline && !isBusy;
  bool get canChangeMechanic => canReassignMechanic && isEditableOrder && isOnline && !isBusy;
  bool get canAddPartToTask => canChargeParts && isEditableOrder && isOnline && !isBusy;
  bool get canEditTaskParts => canUpdateWorkOrder && isEditableOrder && isOnline && !isBusy;
  bool get canGeneratePdf => canReadQuotation && detail != null && isOnline && !isBusy;
  bool get canEmailQuotation => canSendQuotation && detail != null && isOnline && !isBusy;
  bool get canResolveQuotation => canApproveQuotation && isDraft && isOnline && !isBusy;

  bool get canStartOrder => canUpdateWorkOrder && isDraft && isOnline && !isBusy;
  bool get canCompleteOrder =>
      canUpdateWorkOrder && status == WorkOrderStatus.inProgress && isOnline && !isBusy;
  bool get canCancelOrder => canCancelWorkOrder && isEditableOrder && isOnline && !isBusy;
  bool get canCheckout =>
      hasCheckoutPermission &&
      (status == WorkOrderStatus.completed || status == WorkOrderStatus.paid);

  /// Alguna hoja abierta: el error se muestra dentro de ella y no en el cuerpo.
  bool get hasOpenSheet =>
      addTaskForm != null ||
      editLaborForm != null ||
      deletingTask != null ||
      chargeForm != null ||
      partEdit != null ||
      rejectForm != null ||
      assigningMechanicTask != null ||
      cancelForm != null ||
      showQuotationDecision ||
      reviewingSuspensionTask != null ||
      assignBayForm != null ||
      generatedPdf != null;

  bool get showBayAction => canReassignBays && isEditableOrder;
  bool get canAssignBay => showBayAction && isOnline && !isBusy;

  bool get canReviewSuspension => canValidateSuspension && isOnline && !isBusy;

  CascadeBreakdown? get breakdown => detail?.cascadeBreakdown();

  /// Resuelve el nombre comercial del servicio desde el catálogo si el backend devolvió el genérico (H11).
  String taskTitle(TaskDetail task) {
    final serviceId = task.serviceId;
    String? fromCatalog;
    if (serviceId != null) {
      for (final service in services) {
        if (service.id == serviceId) {
          fromCatalog = service.name;
          break;
        }
      }
    }
    final rawName = task.serviceName;
    final usable = rawName != null && rawName.trim().isNotEmpty && rawName != _genericServiceName
        ? rawName
        : null;
    return fromCatalog ?? usable ?? task.description;
  }

  /// Resuelve el nombre del mecánico asignado a la tarea cruzando con los colaboradores de la sede (H11).
  String? mechanicNameFor(TaskDetail task) {
    final mechanicId = task.mechanicId;
    if (mechanicId != null) {
      for (final mechanic in availableMechanics) {
        if (mechanic.membershipId == mechanicId) return mechanic.displayName;
      }
    }
    final name = task.mechanicName;
    return name != null && name.trim().isNotEmpty ? name : null;
  }

  /// Resuelve el nombre comercial del repuesto si el backend devolvió `Product <uuid>` (H11, H36).
  String? productTitle(TaskProduct product) {
    final fromCatalog = partNamesById[product.productId];
    final raw = product.productName;
    final usable = raw != null && raw.trim().isNotEmpty && !raw.startsWith(_genericProductPrefix)
        ? raw
        : null;
    return fromCatalog ?? usable;
  }

  WorkOrderDetailUiState copyWith({
    Object? cachedOrder = _keep,
    Object? detail = _keep,
    List<ServiceOption>? services,
    Map<String, String>? partNamesById,
    bool? isLoading,
    bool? isOnline,
    Object? busyAction = _keep,
    Object? addTaskForm = _keep,
    Object? editLaborForm = _keep,
    Object? deletingTask = _keep,
    Object? chargeTaskId = _keep,
    Object? chargeForm = _keep,
    Object? editingPartTaskId = _keep,
    Object? partEdit = _keep,
    Object? rejectForm = _keep,
    Object? generatedPdf = _keep,
    Object? proformaSentLabel = _keep,
    Object? notice = _keep,
    Object? error = _keep,
    Object? invalidField = _keep,
    bool? canUpdateWorkOrder,
    bool? canChargeParts,
    bool? canReadParts,
    bool? canReadQuotation,
    bool? canSendQuotation,
    bool? canApproveQuotation,
    bool? canReassignMechanic,
    List<MechanicOption>? availableMechanics,
    Object? assigningMechanicTask = _keep,
    Object? cancelForm = _keep,
    bool? showQuotationDecision,
    Object? movements = _keep,
    bool? canCancelWorkOrder,
    bool? canResolveProposals,
    bool? canReadPartMovements,
    bool? canOpenObd,
    bool? hasCheckoutPermission,
    bool? canValidateSuspension,
    Object? reviewingSuspensionTask = _keep,
    bool? canReassignBays,
    Object? assignBayForm = _keep,
  }) {
    return WorkOrderDetailUiState(
      canReassignBays: canReassignBays ?? this.canReassignBays,
      assignBayForm: identical(assignBayForm, _keep) ? this.assignBayForm : assignBayForm as AssignBayForm?,
      canValidateSuspension: canValidateSuspension ?? this.canValidateSuspension,
      reviewingSuspensionTask: identical(reviewingSuspensionTask, _keep)
          ? this.reviewingSuspensionTask
          : reviewingSuspensionTask as TaskDetail?,
      cachedOrder: identical(cachedOrder, _keep) ? this.cachedOrder : cachedOrder as WorkOrder?,
      detail: identical(detail, _keep) ? this.detail : detail as WorkOrderDetail?,
      services: services ?? this.services,
      partNamesById: partNamesById ?? this.partNamesById,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      busyAction: identical(busyAction, _keep)
          ? this.busyAction
          : busyAction as WorkOrderDetailAction?,
      addTaskForm: identical(addTaskForm, _keep) ? this.addTaskForm : addTaskForm as AddTaskForm?,
      editLaborForm: identical(editLaborForm, _keep)
          ? this.editLaborForm
          : editLaborForm as EditLaborForm?,
      deletingTask: identical(deletingTask, _keep)
          ? this.deletingTask
          : deletingTask as TaskDetail?,
      chargeTaskId: identical(chargeTaskId, _keep) ? this.chargeTaskId : chargeTaskId as TaskId?,
      chargeForm: identical(chargeForm, _keep) ? this.chargeForm : chargeForm as ChargeForm?,
      editingPartTaskId: identical(editingPartTaskId, _keep)
          ? this.editingPartTaskId
          : editingPartTaskId as TaskId?,
      partEdit: identical(partEdit, _keep) ? this.partEdit : partEdit as PartEditForm?,
      rejectForm: identical(rejectForm, _keep) ? this.rejectForm : rejectForm as RejectQuotationForm?,
      generatedPdf: identical(generatedPdf, _keep) ? this.generatedPdf : generatedPdf as File?,
      proformaSentLabel: identical(proformaSentLabel, _keep)
          ? this.proformaSentLabel
          : proformaSentLabel as String?,
      notice: identical(notice, _keep) ? this.notice : notice as UiText?,
      error: identical(error, _keep) ? this.error : error as UiText?,
      invalidField: identical(invalidField, _keep) ? this.invalidField : invalidField as String?,
      canUpdateWorkOrder: canUpdateWorkOrder ?? this.canUpdateWorkOrder,
      canChargeParts: canChargeParts ?? this.canChargeParts,
      canReadParts: canReadParts ?? this.canReadParts,
      canReadQuotation: canReadQuotation ?? this.canReadQuotation,
      canSendQuotation: canSendQuotation ?? this.canSendQuotation,
      canApproveQuotation: canApproveQuotation ?? this.canApproveQuotation,
      canReassignMechanic: canReassignMechanic ?? this.canReassignMechanic,
      availableMechanics: availableMechanics ?? this.availableMechanics,
      assigningMechanicTask: identical(assigningMechanicTask, _keep)
          ? this.assigningMechanicTask
          : assigningMechanicTask as TaskDetail?,
      cancelForm: identical(cancelForm, _keep) ? this.cancelForm : cancelForm as CancelOrderForm?,
      showQuotationDecision: showQuotationDecision ?? this.showQuotationDecision,
      movements: identical(movements, _keep)
          ? this.movements
          : movements as OnDemand<List<PartMovement>>?,
      canCancelWorkOrder: canCancelWorkOrder ?? this.canCancelWorkOrder,
      canResolveProposals: canResolveProposals ?? this.canResolveProposals,
      canReadPartMovements: canReadPartMovements ?? this.canReadPartMovements,
      canOpenObd: canOpenObd ?? this.canOpenObd,
      hasCheckoutPermission: hasCheckoutPermission ?? this.hasCheckoutPermission,
    );
  }
}
