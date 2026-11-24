import 'dart:async';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_proposals_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:flutter/foundation.dart';

/// US14: reportar un hallazgo en foso con severidad, descripción y foto probatoria. Funciona sin red: la
/// propuesta se encola y el backend avisa a supervisión al sincronizar; mientras tanto aparece como
/// pendiente de envío.
class ReportFindingViewModel extends ChangeNotifier {
  final String workOrderId;
  final ObserveSessionUseCase observeSession;
  final SubmitProposalUseCase submitProposal;
  final ObservePendingProposalsUseCase observePending;
  final GetServiceCatalogUseCase getServices;

  ReportFindingViewModel({
    required this.workOrderId,
    required this.observeSession,
    required this.submitProposal,
    required this.observePending,
    required this.getServices,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(
          _state.copyWith(canCreate: session?.has(Permission.proposalsCreate) == true),
        ),
      ),
    );
    _subscriptions.add(
      observePending.execute(WorkOrderId(workOrderId)).listen(
        (list) => _update(_state.copyWith(pending: list)),
      ),
    );
    loadServices();
  }

  ReportFindingUiState _state = const ReportFindingUiState();
  ReportFindingUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  /// Servicios sugeridos (opcional). Sin permiso de lectura llega vacío y el hallazgo se envía sin sugerencia.
  Future<void> loadServices() async {
    _update(_state.copyWith(isLoadingServices: true));
    try {
      final list = await getServices.execute();
      _update(_state.copyWith(isLoadingServices: false, services: list));
    } on Object catch (error) {
      _update(_state.copyWith(isLoadingServices: false, error: toWorkOrderUiText(error)));
    }
  }

  void _edit(ReportFindingUiState Function(ReportFindingUiState) change) {
    if (_state.isSaving) return;
    _update(change(_state).copyWith(error: null, invalidField: null, saved: false));
  }

  void onDescriptionChange(String value) => _edit((s) => s.copyWith(description: value));

  void onSeverityChange(ProposalSeverity value) =>
      _edit((s) => value.isSubmittable ? s.copyWith(severity: value) : s);

  void onServiceChange(String? serviceId) => _edit((s) => s.copyWith(suggestedServiceId: serviceId));

  /// Foto tomada: reemplaza a la anterior, que se descarta. Se comprime y encola al enviar.
  void onPhotoCaptured(File file) {
    final previous = _state.photo;
    if (previous != null && previous.path != file.path && previous.existsSync()) {
      previous.deleteSync();
    }
    _edit((s) => s.copyWith(photo: file));
  }

  void onCameraDenied() =>
      _update(_state.copyWith(error: UiText.resource((s) => s.galleryCameraDenied)));

  Future<void> onSubmit() async {
    final state = _state;
    final severity = state.severity;
    final photo = state.photo;
    if (!state.canSubmit || severity == null || photo == null) return;
    _update(state.copyWith(isSaving: true, error: null, invalidField: null, saved: false));
    try {
      await submitProposal.execute(
        WorkOrderId(workOrderId),
        description: state.description.trim(),
        severity: severity,
        photo: photo,
        suggestedServiceId: state.suggestedServiceId,
      );
      if (photo.existsSync()) photo.deleteSync();
      _update(
        _state.copyWith(
          isSaving: false,
          saved: true,
          description: '',
          severity: null,
          photo: null,
          suggestedServiceId: null,
        ),
      );
    } on Object catch (error) {
      _update(
        _state.copyWith(
          isSaving: false,
          error: toWorkOrderUiText(error),
          invalidField: invalidWorkOrderField(error),
        ),
      );
    }
  }

  void _update(ReportFindingUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
