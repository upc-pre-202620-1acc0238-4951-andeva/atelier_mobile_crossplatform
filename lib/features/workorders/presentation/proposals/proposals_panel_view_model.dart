import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/notify_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// US15: panel del asesor con las propuestas de la orden. Notifica al cliente por correo y registra su
/// decisión: aprobada (el backend crea la tarea y recalcula el presupuesto) o rechazada con sus
/// observaciones. Todo en línea.
class ProposalsPanelViewModel extends ChangeNotifier {
  final String workOrderId;
  final ObserveSessionUseCase observeSession;
  final GetWorkOrderDetailUseCase getDetail;
  final GetServiceCatalogUseCase getServices;
  final NotifyProposalUseCase notifyProposal;
  final ApproveProposalUseCase approveProposal;
  final RejectProposalUseCase rejectProposal;
  final ConnectivityObserver? connectivity;
  final GetBranchMechanicsUseCase? getBranchMechanics;

  ProposalsPanelViewModel({
    required this.workOrderId,
    required this.observeSession,
    required this.getDetail,
    required this.getServices,
    required this.notifyProposal,
    required this.approveProposal,
    required this.rejectProposal,
    this.connectivity,
    this.getBranchMechanics,
  }) {
    _state = ProposalsPanelUiState(isOnline: connectivity?.isOnline ?? true);
    _subscription = observeSession.execute().listen((session) {
      _update(
        _state.copyWith(
          canNotify: session?.has(Permission.proposalsNotify) == true,
          canResolve: session?.has(Permission.proposalsResolve) == true,
          canReport: session?.has(Permission.proposalsCreate) == true,
        ),
      );
    });
    connectivity?.addListener(_onConnectivity);
    load();
  }

  late ProposalsPanelUiState _state;
  ProposalsPanelUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity?.isOnline ?? true;
    _update(_state.copyWith(isOnline: online));
  }

  /// `GET /work-orders/{id}`: propuestas de la orden, servicios del catálogo y mecánicos para crear la tarea.
  Future<void> load() async {
    _update(_state.copyWith(isLoading: true, error: null));
    List<ServiceOption> services = _state.services;
    try {
      services = await getServices.execute();
    } on Object {
      // Sin catálogo igual mostramos propuestas.
    }
    List<MechanicOption> mechanics = _state.availableMechanics;
    final fetchMechanics = getBranchMechanics;
    if (fetchMechanics != null) {
      try {
        mechanics = await fetchMechanics.execute();
      } on Object {
        // Sin mecánicos la tarea se aprueba sin asignar.
      }
    }
    try {
      final detail = await getDetail.execute(WorkOrderId(workOrderId));
      _update(
        _state.copyWith(
          isLoading: false,
          proposals: detail.proposals,
          services: services,
          availableMechanics: mechanics,
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          isLoading: false,
          services: services,
          availableMechanics: mechanics,
          error: toWorkOrderUiText(error),
        ),
      );
    }
  }

  /// US15 E1: envía la propuesta con su foto al correo del cliente.
  Future<void> onNotify(String proposalId) async {
    final state = _state;
    if (!state.canNotify || state.isBusy) return;
    _update(state.copyWith(busyProposalId: proposalId, notice: null, error: null));
    try {
      final email = await notifyProposal.execute(WorkOrderId(workOrderId), proposalId);
      _update(
        _state.copyWith(
          busyProposalId: null,
          notice: UiText.resource((s) => s.proposalsNotified(email)),
        ),
      );
    } on Object catch (error) {
      _fail(error);
    }
  }

  void onOpenForm(String proposalId, ProposalAction action) {
    final state = _state;
    if (!state.canResolve || state.isBusy) return;
    final proposal = state.proposals.where((p) => p.id == proposalId).firstOrNull;
    if (proposal == null) return;
    final suggested = proposal.serviceId == null
        ? null
        : state.services.where((s) => s.id == proposal.serviceId).firstOrNull;
    final prefilledPrice = action == ProposalAction.approve
        ? (suggested?.basePrice?.amount.toString() ?? '')
        : '';
    final prefilledHours = action == ProposalAction.approve ? _estimatedHoursText(suggested) : '';
    _update(
      state.copyWith(
        form: ProposalForm(
          proposalId: proposalId,
          action: action,
          serviceId: proposal.serviceId,
          finalPrice: prefilledPrice,
          laborHours: prefilledHours,
          mechanicId: null,
        ),
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
  }

  void onCloseForm() {
    if (_state.isBusy) return;
    _update(_state.copyWith(form: null, error: null, invalidField: null));
  }

  void _editForm(ProposalForm Function(ProposalForm) change) {
    final form = _state.form;
    if (form == null || _state.isBusy) return;
    _update(_state.copyWith(form: change(form), error: null, invalidField: null));
  }

  void onServiceChange(String serviceId) {
    final state = _state;
    final form = state.form;
    if (form == null || state.isBusy) return;
    final service = state.services.where((s) => s.id == serviceId).firstOrNull;
    final nextPrice = service?.basePrice?.amount.toString() ?? form.finalPrice;
    final hoursText = _estimatedHoursText(service);
    final nextHours = hoursText.trim().isEmpty ? form.laborHours : hoursText;
    _update(
      state.copyWith(
        form: form.copyWith(serviceId: serviceId, finalPrice: nextPrice, laborHours: nextHours),
        error: null,
        invalidField: null,
      ),
    );
  }

  void onFinalPriceChange(String value) {
    if (_state.isPriceLockedByCatalog) return;
    _editForm((f) => f.copyWith(finalPrice: value));
  }

  void onLaborHoursChange(String value) => _editForm((f) => f.copyWith(laborHours: value));

  void onMechanicChange(String? mechanicId) => _editForm((f) => f.copyWith(mechanicId: mechanicId));

  void onNotesChange(String value) => _editForm((f) => f.copyWith(notes: value));

  Future<void> onConfirm() async {
    final state = _state;
    final form = state.form;
    if (form == null || !state.canConfirm) return;
    switch (form.action) {
      case ProposalAction.approve:
        await _approve(form);
      case ProposalAction.reject:
        await _reject(form);
    }
  }

  Future<void> _approve(ProposalForm form) async {
    final serviceId = form.serviceId;
    final price = _toAmount(form.finalPrice);
    final hours = _toAmount(form.laborHours);
    final catalogPrice = _state.selectedCatalogService?.basePrice?.amount;
    final effectivePrice = catalogPrice ?? price;
    if (serviceId == null || effectivePrice == null || hours == null) {
      final field = serviceId == null
          ? 'serviceId'
          : effectivePrice == null
          ? 'finalPrice'
          : 'laborHours';
      _fail(InvalidWorkOrderInputException(field));
      return;
    }
    _update(
      _state.copyWith(
        busyProposalId: form.proposalId,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final trimmedNotes = form.notes.trim();
      final detail = await approveProposal.execute(
        WorkOrderId(workOrderId),
        form.proposalId,
        ProposalApproval(
          serviceId: serviceId,
          finalPrice: effectivePrice,
          laborHours: hours,
          mechanicId: form.mechanicId,
          notes: trimmedNotes.isEmpty ? null : trimmedNotes,
        ),
      );
      _update(
        _state.copyWith(
          busyProposalId: null,
          form: null,
          proposals: detail.proposals,
          notice: UiText.resource((s) => s.proposalsApproved),
        ),
      );
    } on Object catch (error) {
      _fail(error);
    }
  }

  Future<void> _reject(ProposalForm form) async {
    _update(
      _state.copyWith(
        busyProposalId: form.proposalId,
        notice: null,
        error: null,
        invalidField: null,
      ),
    );
    try {
      final updated = await rejectProposal.execute(
        WorkOrderId(workOrderId),
        form.proposalId,
        form.notes.trim(),
      );
      _update(
        _state.copyWith(
          busyProposalId: null,
          form: null,
          proposals: [
            for (final p in _state.proposals)
              if (p.id == updated.id) updated else p,
          ],
          notice: UiText.resource((s) => s.proposalsRejected),
        ),
      );
    } on Object catch (error) {
      _fail(error);
    }
  }

  Decimal? _toAmount(String raw) => Decimal.tryParse(raw.trim().replaceAll(',', '.'));

  String _estimatedHoursText(ServiceOption? service) {
    final minutes = service?.estimatedMinutes;
    if (minutes == null || minutes <= 0) return '';
    final hours = (minutes / 60.0);
    final formatted = hours.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
    return formatted;
  }

  void _fail(Object error) {
    _update(
      _state.copyWith(
        busyProposalId: null,
        error: toWorkOrderUiText(error),
        invalidField: invalidWorkOrderField(error),
      ),
    );
  }

  void _update(ProposalsPanelUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity?.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
