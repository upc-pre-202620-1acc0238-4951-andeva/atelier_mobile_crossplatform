import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

enum BayFilter {
  all(null),
  available(BayStatus.available),
  occupied(BayStatus.occupied),
  maintenance(BayStatus.maintenance);

  final BayStatus? status;
  const BayFilter(this.status);
}

enum BayAction { move, assign, release, maintenance, restore, create, reassignMechanic }

/// Hoja de una bahía; lo que ofrece depende del estado actual de la bahía en el tablero.
class BaySheet {
  final String bayId;

  /// Motivo del mantenimiento; `null` mientras no se haya pedido ponerla en mantenimiento.
  final String? maintenanceReason;

  const BaySheet({required this.bayId, this.maintenanceReason});
}

class CreateBayForm {
  final String name;
  final BayType type;

  const CreateBayForm({this.name = '', this.type = BayType.lift});

  CreateBayForm copyWith({String? name, BayType? type}) =>
      CreateBayForm(name: name ?? this.name, type: type ?? this.type);
}

/// Tablero de ocupación de bahías de la sede (US40).
class BaysUiState {
  final List<BayBoardItem> items;
  final BayFilter filter;

  /// Mecánicos de la sede (H11): nombres visibles y destino de la reasignación por tarea.
  final List<MechanicOption> availableMechanics;

  /// Tarea cuya lista de mecánicos está abierta en la hoja de la bahía ocupada.
  final String? reassigningTaskId;

  /// Órdenes de la sede en caché; de ellas salen las que pueden entrar a una bahía libre.
  final List<WorkOrder> orders;
  final BaySheet? sheet;
  final CreateBayForm? createForm;
  final bool canRead;
  final bool canReadWorkOrders;
  final bool canAssignBay;
  final bool canReleaseBay;
  final bool canManage;
  final bool isLoading;
  final bool isRefreshing;
  final bool isOnline;
  final BayAction? busyAction;
  final UiText? error;
  final UiText? notice;

  /// `name` o `reason`.
  final String? invalidField;

  const BaysUiState({
    this.items = const [],
    this.filter = BayFilter.all,
    this.availableMechanics = const [],
    this.reassigningTaskId,
    this.orders = const [],
    this.sheet,
    this.createForm,
    this.canRead = true,
    this.canReadWorkOrders = false,
    this.canAssignBay = false,
    this.canReleaseBay = false,
    this.canManage = false,
    this.isLoading = true,
    this.isRefreshing = false,
    this.isOnline = true,
    this.busyAction,
    this.error,
    this.notice,
    this.invalidField,
  });

  bool get isBusy => busyAction != null;
  bool get hasOpenSheet => sheet != null || createForm != null;

  /// Escribir exige red (US40 es lectura en caché y escritura en línea).
  bool get canAct => isOnline && !isBusy;

  int countFor(BayFilter value) =>
      value.status == null ? items.length : items.where((i) => i.bay.status == value.status).length;

  List<BayBoardItem> get visibleItems =>
      filter.status == null ? items : items.where((i) => i.bay.status == filter.status).toList();

  BayBoardItem? get selectedItem {
    final id = sheet?.bayId;
    for (final item in items) {
      if (item.bay.id == id) return item;
    }
    return null;
  }

  List<WorkBay> get availableBays => [
    for (final item in items)
      if (item.bay.status == BayStatus.available) item.bay,
  ];

  int get availableCount => countFor(BayFilter.available);
  int get occupiedCount => countFor(BayFilter.occupied);
  int get maintenanceCount => countFor(BayFilter.maintenance);

  /// Nombre del mecánico de una tarea: el de la lista de la sede o, si falta, el que trae la tarea.
  String? mechanicNameFor(String? mechanicId, [String? fallbackName]) {
    final fallback = fallbackName != null && fallbackName.trim().isNotEmpty ? fallbackName : null;
    if (mechanicId == null) return fallback;
    for (final mechanic in availableMechanics) {
      if (mechanic.membershipId == mechanicId) return mechanic.displayName;
    }
    return fallback;
  }

  /// Mecánicos de la orden que ocupa la bahía, sin repetir.
  List<String> mechanicLabelsFor(BayOccupant occupant) {
    final fromIds = [
      for (final id in occupant.mechanicIds)
        for (final mechanic in availableMechanics)
          if (mechanic.membershipId == id) mechanic.displayName,
    ];
    if (fromIds.isNotEmpty) return {...fromIds}.toList();
    return {
      for (final task in occupant.tasks)
        if (task.mechanicName != null && task.mechanicName!.trim().isNotEmpty) task.mechanicName!,
    }.toList();
  }

  /// Órdenes activas que todavía no ocupan ninguna bahía del tablero.
  List<WorkOrder> get assignableOrders {
    final occupying = {for (final item in items) ?item.bay.currentWorkOrderId};
    return [
      for (final order in orders)
        if ((order.status == WorkOrderStatus.draft || order.status == WorkOrderStatus.inProgress) &&
            !occupying.contains(order.id.value))
          order,
    ];
  }

  BaysUiState copyWith({
    List<BayBoardItem>? items,
    BayFilter? filter,
    List<MechanicOption>? availableMechanics,
    String? reassigningTaskId,
    bool clearReassigningTask = false,
    List<WorkOrder>? orders,
    BaySheet? sheet,
    bool clearSheet = false,
    CreateBayForm? createForm,
    bool clearCreateForm = false,
    bool? canRead,
    bool? canReadWorkOrders,
    bool? canAssignBay,
    bool? canReleaseBay,
    bool? canManage,
    bool? isLoading,
    bool? isRefreshing,
    bool? isOnline,
    BayAction? busyAction,
    bool clearBusyAction = false,
    UiText? error,
    bool clearError = false,
    UiText? notice,
    bool clearNotice = false,
    String? invalidField,
    bool clearInvalidField = false,
  }) {
    return BaysUiState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      availableMechanics: availableMechanics ?? this.availableMechanics,
      reassigningTaskId: clearReassigningTask ? null : reassigningTaskId ?? this.reassigningTaskId,
      orders: orders ?? this.orders,
      sheet: clearSheet ? null : sheet ?? this.sheet,
      createForm: clearCreateForm ? null : createForm ?? this.createForm,
      canRead: canRead ?? this.canRead,
      canReadWorkOrders: canReadWorkOrders ?? this.canReadWorkOrders,
      canAssignBay: canAssignBay ?? this.canAssignBay,
      canReleaseBay: canReleaseBay ?? this.canReleaseBay,
      canManage: canManage ?? this.canManage,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOnline: isOnline ?? this.isOnline,
      busyAction: clearBusyAction ? null : busyAction ?? this.busyAction,
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
    );
  }
}
