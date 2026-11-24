import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/pending_work_order_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

const _keep = Object();

class ReportFindingUiState {
  final String description;
  final ProposalSeverity? severity;

  /// Foto del hallazgo: es obligatoria, sin ella el backend responde 400 (US14 E2).
  final File? photo;
  final String? suggestedServiceId;
  final List<ServiceOption> services;
  final bool isLoadingServices;
  final List<PendingProposal> pending;
  final bool isSaving;

  /// El último hallazgo quedó guardado: se enviará en cuanto haya señal.
  final bool saved;
  final UiText? error;

  /// Campo que no pasó la validación local (`description`, `severity`, `photo`).
  final String? invalidField;
  final bool canCreate;

  const ReportFindingUiState({
    this.description = '',
    this.severity,
    this.photo,
    this.suggestedServiceId,
    this.services = const [],
    this.isLoadingServices = true,
    this.pending = const [],
    this.isSaving = false,
    this.saved = false,
    this.error,
    this.invalidField,
    this.canCreate = false,
  });

  bool get canSubmit =>
      canCreate && !isSaving && description.trim().isNotEmpty && severity != null && photo != null;

  ReportFindingUiState copyWith({
    String? description,
    Object? severity = _keep,
    Object? photo = _keep,
    Object? suggestedServiceId = _keep,
    List<ServiceOption>? services,
    bool? isLoadingServices,
    List<PendingProposal>? pending,
    bool? isSaving,
    bool? saved,
    Object? error = _keep,
    Object? invalidField = _keep,
    bool? canCreate,
  }) {
    return ReportFindingUiState(
      description: description ?? this.description,
      severity: identical(severity, _keep) ? this.severity : severity as ProposalSeverity?,
      photo: identical(photo, _keep) ? this.photo : photo as File?,
      suggestedServiceId: identical(suggestedServiceId, _keep)
          ? this.suggestedServiceId
          : suggestedServiceId as String?,
      services: services ?? this.services,
      isLoadingServices: isLoadingServices ?? this.isLoadingServices,
      pending: pending ?? this.pending,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
      error: identical(error, _keep) ? this.error : error as UiText?,
      invalidField: identical(invalidField, _keep) ? this.invalidField : invalidField as String?,
      canCreate: canCreate ?? this.canCreate,
    );
  }
}
