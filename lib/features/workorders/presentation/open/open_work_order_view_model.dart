import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_draft_work_order_for_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/open_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:flutter/foundation.dart';

/// US12: abrir la orden con kilometraje, combustible y motivo, y elegir las faenas iniciales. Todo en línea (no
/// se encola). Si el vehículo ya tiene una orden en borrador (llegó por una cita, H10) se completa esa en vez
/// de crear otra.
class OpenWorkOrderViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final OpenWorkOrderUseCase openWorkOrder;
  final UpdateWorkOrderUseCase updateWorkOrder;
  final AddWorkOrderTaskUseCase addTask;
  final FindDraftWorkOrderForVehicleUseCase findDraft;
  final GetServiceCatalogUseCase getServices;
  final GetBranchMechanicsUseCase getMechanics;
  final ConnectivityObserver? connectivity;
  final String vehicleId;
  final String customerId;

  OpenWorkOrderViewModel({
    required this.observeSession,
    required this.openWorkOrder,
    required this.updateWorkOrder,
    required this.addTask,
    required this.findDraft,
    required this.getServices,
    required this.getMechanics,
    required this.vehicleId,
    required this.customerId,
    String? workOrderId,
    this.connectivity,
  }) {
    _state = OpenWorkOrderUiState(
      workOrderId: workOrderId,
      isOnline: connectivity?.isOnline ?? true,
    );
    _subscription = observeSession.execute().listen(_onSession);
    connectivity?.addListener(_onConnectivity);
    loadCatalog();
  }

  late OpenWorkOrderUiState _state;
  OpenWorkOrderUiState get state => _state;

  StreamSubscription<Session?>? _subscription;
  bool _draftChecked = false;
  bool _disposed = false;

  void _onSession(Session? session) {
    _update(
      _state.copyWith(
        canCreate: session?.has(Permission.workOrdersCreate) == true,
        canUpdate: session?.has(Permission.workOrdersUpdate) == true,
      ),
    );
    final branchId = session?.branchId;
    if (!_draftChecked && branchId != null) {
      _draftChecked = true;
      _lookForDraft(branchId);
    }
  }

  void _onConnectivity() {
    final online = connectivity?.isOnline ?? true;
    _update(_state.copyWith(isOnline: online));
  }

  /// Si la orden no vino en la ruta, busca un borrador del vehículo para no crear otra (evita el 409).
  Future<void> _lookForDraft(String branchId) async {
    if (_state.workOrderId != null) return;
    try {
      final draft = await findDraft.execute(branchId, vehicleId);
      if (draft != null && _state.workOrderId == null && !_state.orderSaved) {
        _update(_state.copyWith(workOrderId: draft.id.value));
      }
    } on Object {
      // Sin borrador conocido se abre una orden nueva.
    }
  }

  /// Servicios y mecánicos para elegir. Sin permiso de lectura el backend responde vacío y la orden va sin
  /// faenas.
  Future<void> loadCatalog() async {
    _update(_state.copyWith(isLoadingCatalog: true, clearError: true));
    Object? failure;
    var services = const <ServiceOption>[];
    var mechanics = const <MechanicOption>[];
    try {
      services = await getServices.execute();
    } on Object catch (error) {
      failure = error;
    }
    try {
      mechanics = await getMechanics.execute();
    } on Object catch (error) {
      failure ??= error;
    }
    _update(
      _state.copyWith(
        isLoadingCatalog: false,
        services: services,
        mechanics: mechanics,
        error: failure == null ? null : toWorkOrderUiText(failure),
        clearError: failure == null,
      ),
    );
  }

  void _edit(OpenWorkOrderUiState Function(OpenWorkOrderUiState) change) {
    if (_state.formLocked) return;
    _update(change(_state).copyWith(clearError: true, clearInvalidField: true));
  }

  void onMileageChange(String value) =>
      _edit((s) => s.copyWith(mileage: value.replaceAll(RegExp(r'[^0-9]'), '')));

  void onFuelChange(FuelLevel value) => _edit((s) => s.copyWith(fuel: value));

  void onReasonChange(String value) => _edit((s) => s.copyWith(reason: value));

  void onToggleService(String serviceId) {
    // Las faenas ya agregadas a la orden no se quitan desde aquí.
    if (_state.isSaving || _state.addedServiceIds.contains(serviceId)) return;
    final selected = {..._state.selectedServiceIds};
    if (!selected.remove(serviceId)) selected.add(serviceId);
    _update(_state.copyWith(selectedServiceIds: selected, clearError: true));
  }

  void onMechanicChange(String? membershipId) {
    if (_state.isSaving) return;
    _update(
      _state.copyWith(
        selectedMechanicId: membershipId,
        clearSelectedMechanic: membershipId == null,
        clearError: true,
      ),
    );
  }

  Future<void> onSubmit() async {
    final state = _state;
    if (!state.canSubmit) return;
    final mileage = int.tryParse(state.mileage.trim());
    if (mileage == null) {
      _fail(const InvalidWorkOrderInputException('mileageIn'));
      return;
    }
    _update(state.copyWith(isSaving: true, clearError: true, clearInvalidField: true));
    var orderId = state.workOrderId;
    try {
      if (!state.orderSaved) {
        final summary = 'Combustible: ${state.fuel?.summaryLabel}. ${state.reason.trim()}';
        final WorkOrder saved;
        if (orderId != null) {
          saved = await updateWorkOrder.execute(
            WorkOrderId(orderId),
            mileageIn: mileage,
            diagnosticSummary: summary,
          );
        } else {
          saved = await openWorkOrder.execute(
            NewWorkOrder(
              vehicleId: vehicleId,
              customerId: customerId,
              mileageIn: mileage,
              diagnosticSummary: summary,
            ),
          );
        }
        orderId = saved.id.value;
        _update(_state.copyWith(workOrderId: orderId, orderSaved: true));
      }
      for (final service in state.pendingServices) {
        final task = NewWorkOrderTask(
          serviceId: service.id,
          description: service.name,
          mechanicId: state.selectedMechanicId,
          price: service.basePrice?.amount,
        );
        await addTask.execute(WorkOrderId(orderId!), task);
        _update(_state.copyWith(addedServiceIds: {..._state.addedServiceIds, service.id}));
      }
      _update(_state.copyWith(isSaving: false, doneWorkOrderId: orderId));
    } on Object catch (error) {
      _fail(error);
    }
  }

  void _fail(Object error) {
    _update(
      _state.copyWith(
        isSaving: false,
        error: toWorkOrderUiText(error),
        invalidField: invalidWorkOrderField(error),
        clearInvalidField: invalidWorkOrderField(error) == null,
      ),
    );
  }

  void _update(OpenWorkOrderUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    connectivity?.removeListener(_onConnectivity);
    super.dispose();
  }
}
