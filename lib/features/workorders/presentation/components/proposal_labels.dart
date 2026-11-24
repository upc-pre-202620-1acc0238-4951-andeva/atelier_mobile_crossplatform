import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/proposal.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Severidades que se pueden enviar: el backend rechaza `HIGH` con 400 (docs/api/README.md §8).
final List<ProposalSeverity> submittableSeverities = [
  for (final severity in ProposalSeverity.values)
    if (severity.isSubmittable) severity,
];

extension ProposalSeverityLabels on ProposalSeverity {
  String label(AppLocalizations strings) => switch (this) {
    ProposalSeverity.low => strings.severityLow,
    ProposalSeverity.medium => strings.severityMedium,
    ProposalSeverity.high => strings.severityHigh,
    ProposalSeverity.critical => strings.severityCritical,
  };

  ChipKind get chipKind => switch (this) {
    ProposalSeverity.low => ChipKind.info,
    ProposalSeverity.medium => ChipKind.wait,
    ProposalSeverity.high || ProposalSeverity.critical => ChipKind.bad,
  };
}

extension ProposalStatusLabels on ProposalStatus {
  String label(AppLocalizations strings) => switch (this) {
    ProposalStatus.pendingReview => strings.proposalStatusPending,
    ProposalStatus.approved => strings.proposalStatusApproved,
    ProposalStatus.rejected => strings.proposalStatusRejected,
  };

  ChipKind get chipKind => switch (this) {
    ProposalStatus.pendingReview => ChipKind.wait,
    ProposalStatus.approved => ChipKind.ok,
    ProposalStatus.rejected => ChipKind.idle,
  };
}
