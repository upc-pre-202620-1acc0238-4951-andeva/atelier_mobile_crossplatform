import 'package:decimal/decimal.dart';

/// `ProposalSeverity` de docs/api/README.md §8. El enum del backend tiene `HIGH`, pero la propuesta
/// solo se envía con `LOW`, `MEDIUM` o `CRITICAL` ([isSubmittable]); `HIGH` solo puede llegar al leer.
enum ProposalSeverity {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  final String value;
  const ProposalSeverity(this.value);

  bool get isSubmittable => this != high;

  static ProposalSeverity? fromString(String? raw) {
    for (final severity in values) {
      if (severity.value == raw) return severity;
    }
    return null;
  }
}

/// `ProposalStatus` de docs/api/README.md §8.
enum ProposalStatus {
  pendingReview('PENDING_REVIEW'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const ProposalStatus(this.value);

  static ProposalStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// Propuesta de tarea adicional por hallazgo en foso (`TaskProposalResource`, US14–US15).
class Proposal {
  final String id;
  final String workOrderId;
  final String? taskId;
  final String? serviceId;
  final String? mechanicId;
  final String description;
  final ProposalSeverity? severity;
  final String? imageUrl;
  final ProposalStatus? status;
  final String? customerNotes;
  final DateTime? createdAt;

  const Proposal({
    required this.id,
    required this.workOrderId,
    this.taskId,
    this.serviceId,
    this.mechanicId,
    required this.description,
    this.severity,
    this.imageUrl,
    this.status,
    this.customerNotes,
    this.createdAt,
  });
}

/// Aprobación del cliente (US15 E1): crea la tarea. [mechanicId] es el membershipId.
class ProposalApproval {
  final String serviceId;
  final Decimal finalPrice;
  final Decimal laborHours;
  final String? mechanicId;
  final String? notes;

  const ProposalApproval({
    required this.serviceId,
    required this.finalPrice,
    required this.laborHours,
    this.mechanicId,
    this.notes,
  });
}
