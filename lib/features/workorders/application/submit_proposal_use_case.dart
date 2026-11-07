import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

import 'dart:io';

/// Proponer una tarea adicional por un hallazgo en foso, con severidad y foto (US14 E1). Sin foto no se
/// envía (E2). `HIGH` no se puede enviar (docs/api/README.md §8). Funciona sin red: se encola.
class SubmitProposalUseCase {
  final WorkOrderRepository repository;

  const SubmitProposalUseCase({required this.repository});

  Future<void> execute(
    WorkOrderId id, {
    required String description,
    required ProposalSeverity severity,
    required File? photo,
    String? suggestedServiceId,
  }) async {
    if (photo == null) throw const InvalidWorkOrderInputException('photo');
    if (!severity.isSubmittable) {
      throw const InvalidWorkOrderInputException('severity');
    }
    if (!WorkOrderValidation.isRequiredText(
      description,
      WorkOrderValidation.proposalDescriptionMax,
    )) {
      throw const InvalidWorkOrderInputException('description');
    }
    return repository.submitProposal(
      id,
      description: description,
      severity: severity,
      photo: photo,
      suggestedServiceId: suggestedServiceId,
    );
  }
}
