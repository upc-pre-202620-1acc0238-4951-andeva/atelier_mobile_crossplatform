import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

const _keep = Object();

enum ProposalAction { approve, reject }

/// Formulario abierto sobre una propuesta: registrar la aprobación (crea la tarea) o el rechazo del cliente.
class ProposalForm {
  final String proposalId;
  final ProposalAction action;
  final String? serviceId;

  /// Tarifa del servicio sin IGV (consolidada desde catálogo cuando el servicio tiene precio base).
  final String finalPrice;
  final String laborHours;

  /// Mecánico opcional asignado directamente a la tarea creada.
  final String? mechanicId;

  /// Observaciones: opcionales al aprobar, obligatorias al rechazar (`customerNotes`).
  final String notes;

  const ProposalForm({
    required this.proposalId,
    required this.action,
    this.serviceId,
    this.finalPrice = '',
    this.laborHours = '',
    this.mechanicId,
    this.notes = '',
  });

  bool get isFilled => switch (action) {
    ProposalAction.approve => finalPrice.trim().isNotEmpty && laborHours.trim().isNotEmpty,
    ProposalAction.reject => notes.trim().isNotEmpty,
  };

  ProposalForm copyWith({
    Object? serviceId = _keep,
    String? finalPrice,
    String? laborHours,
    Object? mechanicId = _keep,
    String? notes,
  }) {
    return ProposalForm(
      proposalId: proposalId,
      action: action,
      serviceId: identical(serviceId, _keep) ? this.serviceId : serviceId as String?,
      finalPrice: finalPrice ?? this.finalPrice,
      laborHours: laborHours ?? this.laborHours,
      mechanicId: identical(mechanicId, _keep) ? this.mechanicId : mechanicId as String?,
      notes: notes ?? this.notes,
    );
  }
}

class ProposalsPanelUiState {
  final List<Proposal> proposals;
  final List<ServiceOption> services;
  final List<MechanicOption> availableMechanics;
  final bool isLoading;

  /// Propuesta con una operación en curso (notificar, aprobar o rechazar).
  final String? busyProposalId;
  final ProposalForm? form;
  final UiText? notice;
  final UiText? error;

  /// Campo del formulario que no pasó la validación (`serviceId`, `finalPrice`, `laborHours`, `notes`).
  final String? invalidField;
  final bool canNotify;
  final bool canResolve;
  final bool canReport;
  final bool isOnline;

  const ProposalsPanelUiState({
    this.proposals = const [],
    this.services = const [],
    this.availableMechanics = const [],
    this.isLoading = true,
    this.busyProposalId,
    this.form,
    this.notice,
    this.error,
    this.invalidField,
    this.canNotify = false,
    this.canResolve = false,
    this.canReport = false,
    this.isOnline = true,
  });

  bool get isBusy => busyProposalId != null;

  bool get canConfirm => (form?.isFilled ?? false) && !isBusy && isOnline;

  ServiceOption? get selectedCatalogService {
    final id = form?.serviceId;
    if (id == null) return null;
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  bool get isPriceLockedByCatalog => selectedCatalogService?.basePrice != null;

  ProposalsPanelUiState copyWith({
    List<Proposal>? proposals,
    List<ServiceOption>? services,
    List<MechanicOption>? availableMechanics,
    bool? isLoading,
    Object? busyProposalId = _keep,
    Object? form = _keep,
    Object? notice = _keep,
    Object? error = _keep,
    Object? invalidField = _keep,
    bool? canNotify,
    bool? canResolve,
    bool? canReport,
    bool? isOnline,
  }) {
    return ProposalsPanelUiState(
      proposals: proposals ?? this.proposals,
      services: services ?? this.services,
      availableMechanics: availableMechanics ?? this.availableMechanics,
      isLoading: isLoading ?? this.isLoading,
      busyProposalId: identical(busyProposalId, _keep)
          ? this.busyProposalId
          : busyProposalId as String?,
      form: identical(form, _keep) ? this.form : form as ProposalForm?,
      notice: identical(notice, _keep) ? this.notice : notice as UiText?,
      error: identical(error, _keep) ? this.error : error as UiText?,
      invalidField: identical(invalidField, _keep) ? this.invalidField : invalidField as String?,
      canNotify: canNotify ?? this.canNotify,
      canResolve: canResolve ?? this.canResolve,
      canReport: canReport ?? this.canReport,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
