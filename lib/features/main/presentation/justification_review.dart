import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Hoja inferior de revisión de un descargo (Hoy y Equipo). Se abre sola mientras el ViewModel tenga un
/// descargo en revisión y se cierra cuando lo resuelve; el equivalente a `state.reviewing?.let { sheet }`.
class JustificationReviewHost extends StatelessWidget {
  final Listenable listenable;
  final TeamAttendance? Function() reviewing;
  final VoidCallback onDismiss;
  final Widget Function(BuildContext context, TeamAttendance item) sheetBuilder;
  final Widget child;

  const JustificationReviewHost({
    super.key,
    required this.listenable,
    required this.reviewing,
    required this.onDismiss,
    required this.sheetBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<TeamAttendance>(
      listenable: listenable,
      value: reviewing,
      onDismiss: onDismiss,
      sheetBuilder: sheetBuilder,
      child: child,
    );
  }
}

/// Contenido de la hoja: quién y cuándo, el motivo escrito y aprobar o rechazar (necesita permiso y red).
class JustificationSheet extends StatelessWidget {
  final TeamAttendance item;
  final String? who;
  final bool canApprove;
  final bool isOnline;
  final bool isSubmitting;
  final UiText? error;
  final ValueChanged<bool> onReview;

  const JustificationSheet({
    super.key,
    required this.item,
    required this.who,
    required this.canApprove,
    required this.isOnline,
    required this.isSubmitting,
    required this.error,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final reason = item.justificationReason;
    final error = this.error;
    return AtelierBottomSheet(
      title: justificationTitle(strings, item.status),
      actions: [
        if (!canApprove)
          AtelierNoPermissionState(text: strings.todayJustificationNoPermission)
        else if (!isOnline)
          const AtelierRequiresConnection()
        else ...[
          AtelierButton(
            text: strings.todayJustificationApprove,
            onClick: () => onReview(true),
            loading: isSubmitting,
          ),
          AtelierButton(
            text: strings.todayJustificationReject,
            onClick: () => onReview(false),
            style: AtelierButtonStyle.destructive,
            enabled: !isSubmitting,
          ),
        ],
      ],
      content: [
        Text(
          whoAndWhen(strings, item, who),
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        Text(
          reason != null && reason.trim().isNotEmpty
              ? reason
              : strings.todayJustificationNoReason,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        if (error != null)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
