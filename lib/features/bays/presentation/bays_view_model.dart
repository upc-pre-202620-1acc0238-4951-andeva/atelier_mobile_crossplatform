import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/create_work_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/release_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/restore_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/set_bay_maintenance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_errors.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/invalid_bay_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:flutter/foundation.dart';

/// US40: tablero de bahías desde Drift, con sondeo cada 30 s solo mientras la pantalla está visible (H24).
/// Reasignar y gestionar bahías es en línea.
class BaysViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveBayBoardUseCase observeBoard;
  final PollBayBoardUseCase pollBoard;
  final ObserveBranchWorkOrdersUseCase observeOrders;
  final RefreshBranchWorkOrdersUseCase refreshOrders;
  final GetBranchMechanicsUseCase getMechanics;
  final ReassignBayUseCase reassignBay;
  final ReassignTaskMechanicUseCase reassignTaskMechanic;
  final ReleaseBayUseCase releaseBay;
  final CreateWorkBayUseCase createBay;
  final SetBayMaintenanceUseCase setBayMaintenance;
  final RestoreBayUseCase restoreBay;
  final ConnectivityObserver connectivity;

  BaysViewModel({
    required this.observeSession,
    required this.observeBoard,
    required this.pollBoard,
    required this.observeOrders,
    required this.refreshOrders,
    required this.getMechanics,
    required this.reassignBay,
    required this.reassignTaskMechanic,
    required this.releaseBay,
    required this.createBay,
    required this.setBayMaintenance,
    required this.restoreBay,
    required this.connectivity,
  }) {
    _state = BaysUiState(isOnline: connectivity.isOnline);
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(observeBoard.execute().listen(_onBoard, onError: _onBoardError));
    _subscriptions.add(observeOrders.execute().listen((orders) => _update(_state.copyWith(orders: orders))));
    connectivity.addListener(_onConnectivity);
    _loadReferences();
  }

  late BaysUiState _state;
  BaysUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<void>? _polling;
  bool _visible = false;
  bool _disposed = false;

  /// La caché responde enseguida con lo guardado: el esqueleto solo dura hasta la primera emisión.
  void _onBoard(List<BayBoardItem> items) {
    _update(_state.copyWith(items: items, isLoading: false));
  }

  void _onBoardError(Object error) {
    _update(_state.copyWith(isLoading: false, error: toUiText(error)));
  }

  void _onSession(Session? session) {
    _update(
      _state.copyWith(
        canRead: session?.has(Permission.baysRead) == true,
        canReadWorkOrders: session?.has(Permission.workOrdersRead) == true,
        canAssignBay: session?.has(Permission.baysReassign) == true,
        canReleaseBay: session?.has(Permission.baysReassign) == true,
        canManage: session?.has(Permission.baysManage) == true,
      ),
    );
  }

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final reconnected = online && !_state.isOnline;
    _update(_state.copyWith(isOnline: online));
    if (reconnected && _visible) {
      _startPolling();
      _loadReferences();
    }
  }

  /// La pantalla llama aquí al mostrarse, ocultarse o pasar a segundo plano.
  void setVisible(bool visible) {
    if (_disposed || visible == _visible) return;
    _visible = visible;
    if (visible) {
      _startPolling();
    } else {
      _polling?.cancel();
      _polling = null;
    }
  }

  /// Suscribirse refresca ya y repite cada 30 s.
  void _startPolling() {
    _polling?.cancel();
    _polling = pollBoard.execute().listen(
      (_) => _update(_state.copyWith(isLoading: false, clearError: !_state.hasOpenSheet)),
      onError: (Object error) {
        if (_state.hasOpenSheet) return;
        _update(_state.copyWith(isLoading: false, error: toUiText(error)));
      },
    );
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isRefreshing: true, clearError: true, clearNotice: true));
    if (_visible) _startPolling();
    await _loadReferences();
    _update(_state.copyWith(isRefreshing: false));
  }

  /// Órdenes (placa y número, solo con `WORK_ORDERS_READ`) y mecánicos de la sede. Sin red o sin permiso se
  /// sigue con lo que haya.
  Future<void> _loadReferences() async {
    if (_state.canReadWorkOrders) {
      try {
        await refreshOrders.execute();
      } on Object {
        // Se sigue con la caché.
      }
    }
    if (_state.availableMechanics.isEmpty) {
      try {
        final mechanics = await getMechanics.execute();
        _update(_state.copyWith(availableMechanics: mechanics));
      } on Object {
        // El tablero se muestra sin nombres.
      }
    }
  }

  void onFilterChange(BayFilter filter) => _update(_state.copyWith(filter: filter));

  // --- Hojas ---

  void onBayClick(WorkBay bay) {
    if (_state.isBusy) return;
    _update(
      _state.copyWith(
        sheet: BaySheet(bayId: bay.id),
        clearReassigningTask: true,
        clearError: true,
        clearNotice: true,
        clearInvalidField: true,
      ),
    );
  }

  void onDismissSheet() {
    if (_state.sheet == null) return;
    _update(_state.copyWith(clearSheet: true, clearReassigningTask: true, clearError: true, clearInvalidField: true));
  }

  void onMaintenanceClick() => _editSheet('');

  void onMaintenanceReasonChange(String value) => _editSheet(value);

  /// Vuelve de la captura del motivo a la hoja de la bahía libre.
  void onMaintenanceBack() {
    final sheet = _state.sheet;
    if (sheet == null || _state.isBusy) return;
    _update(_state.copyWith(sheet: BaySheet(bayId: sheet.bayId), clearError: true, clearInvalidField: true));
  }

  void _editSheet(String reason) {
    final sheet = _state.sheet;
    if (sheet == null || !_state.canManage || _state.isBusy) return;
    _update(
      _state.copyWith(
        sheet: BaySheet(bayId: sheet.bayId, maintenanceReason: reason),
        clearError: true,
        clearInvalidField: true,
      ),
    );
  }

  /// US40 E1: lleva la orden de la bahía abierta a [target].
  Future<void> onMoveOrder(WorkBay target) async {
    final occupant = _state.selectedItem?.occupant;
    if (occupant == null || !_state.canAssignBay) return;
    await _run(
      BayAction.move,
      () => reassignBay.execute(occupant.workOrderId, target),
      UiText.resource((s) => s.orderBayAssignedNotice(target.name)),
    );
  }

  /// Ingresa una orden sin bahía a la bahía libre abierta.
  Future<void> onAssignOrder(String workOrderId) async {
    final bay = _state.selectedItem?.bay;
    if (bay == null || !_state.canAssignBay) return;
    await _run(
      BayAction.assign,
      () => reassignBay.execute(workOrderId, bay),
      UiText.resource((s) => s.orderBayAssignedNotice(bay.name)),
    );
  }

  Future<void> onRelease() async {
    final item = _state.selectedItem;
    final occupant = item?.occupant;
    if (item == null || occupant == null || !_state.canReleaseBay) return;
    await _run(
      BayAction.release,
      () => releaseBay.execute(occupant.workOrderId),
      UiText.resource((s) => s.baysReleasedNotice(item.bay.name)),
    );
  }

  /// Abre (o cierra, con `null`) la lista de mecánicos de una tarea de la orden que ocupa la bahía.
  void onOpenReassignTaskMechanic(String? taskId) {
    if (_state.isBusy) return;
    _update(_state.copyWith(reassigningTaskId: taskId, clearReassigningTask: taskId == null, clearError: true));
  }

  /// US40 E1: cambia el mecánico de una tarea. En línea; la hoja sigue abierta y la lista se cierra.
  Future<void> onConfirmReassignTaskMechanic(String taskId, String mechanicId) async {
    if (!_state.canReleaseBay || !_state.canAct) return;
    var mechanicName = '';
    for (final mechanic in _state.availableMechanics) {
      if (mechanic.membershipId == mechanicId) mechanicName = mechanic.displayName;
    }
    _update(_state.copyWith(busyAction: BayAction.reassignMechanic, clearError: true, clearNotice: true));
    try {
      await reassignTaskMechanic.execute(taskId, mechanicId);
      _update(
        _state.copyWith(
          clearBusyAction: true,
          clearReassigningTask: true,
          notice: UiText.resource((s) => s.orderMechanicAssignedNotice(mechanicName)),
        ),
      );
    } on Object catch (error) {
      _update(_state.copyWith(clearBusyAction: true, error: toUiText(error)));
    }
  }

  Future<void> onConfirmMaintenance() async {
    final bay = _state.selectedItem?.bay;
    final reason = _state.sheet?.maintenanceReason;
    if (bay == null || reason == null || !_state.canManage) return;
    await _run(
      BayAction.maintenance,
      () => setBayMaintenance.execute(bay.id, reason),
      UiText.resource((s) => s.baysMaintenanceNotice(bay.name)),
    );
  }

  Future<void> onRestore() async {
    final bay = _state.selectedItem?.bay;
    if (bay == null || !_state.canManage) return;
    await _run(
      BayAction.restore,
      () => restoreBay.execute(bay.id),
      UiText.resource((s) => s.baysRestoredNotice(bay.name)),
    );
  }

  // --- Registrar bahía ---

  void onCreateClick() {
    if (!_state.canManage || _state.isBusy) return;
    _update(
      _state.copyWith(createForm: const CreateBayForm(), clearError: true, clearNotice: true, clearInvalidField: true),
    );
  }

  void onDismissCreate() {
    if (_state.createForm == null) return;
    _update(_state.copyWith(clearCreateForm: true, clearError: true, clearInvalidField: true));
  }

  void onCreateNameChange(String value) => _editCreate((f) => f.copyWith(name: value));

  void onCreateTypeChange(BayType type) => _editCreate((f) => f.copyWith(type: type));

  void _editCreate(CreateBayForm Function(CreateBayForm form) change) {
    final form = _state.createForm;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(createForm: change(form), clearError: true, clearInvalidField: true));
  }

  Future<void> onConfirmCreate() async {
    final form = _state.createForm;
    if (form == null || !_state.canManage) return;
    final name = form.name.trim();
    await _run(
      BayAction.create,
      () => createBay.execute(form.name, form.type),
      UiText.resource((s) => s.baysCreatedNotice(name)),
    );
  }

  /// Al salir bien se cierran las hojas; con error quedan abiertas y la asignación previa intacta (US40 E2).
  Future<void> _run(BayAction action, Future<void> Function() call, UiText notice) async {
    if (!_state.canAct) return;
    _update(_state.copyWith(busyAction: action, clearError: true, clearNotice: true, clearInvalidField: true));
    try {
      await call();
      _update(_state.copyWith(clearBusyAction: true, clearSheet: true, clearCreateForm: true, notice: notice));
    } on InvalidBayInputException catch (error) {
      _update(_state.copyWith(clearBusyAction: true, invalidField: error.field));
    } on BayUnavailableException {
      _update(_state.copyWith(clearBusyAction: true, error: UiText.resource((s) => s.baysUnavailableError)));
    } on Object catch (error) {
      _update(_state.copyWith(clearBusyAction: true, error: toUiText(error)));
    }
  }

  void _update(BaysUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _polling?.cancel();
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
