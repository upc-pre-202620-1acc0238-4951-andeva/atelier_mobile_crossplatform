import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// US27 E2/E3: hoja inferior para tipificar la pausa (`BREAK` o `END_OF_SHIFT`).
class PauseReasonSheet extends StatelessWidget {
  final bool isOnline;
  final bool isSaving;
  final ValueChanged<PauseReason> onSelect;
  final VoidCallback onDismiss;

  const PauseReasonSheet({
    super.key,
    required this.isOnline,
    required this.isSaving,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.taskPauseTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.taskPauseBreak,
          onClick: () => onSelect(PauseReason.breakTime),
          style: AtelierButtonStyle.tonal,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          icon: Icons.coffee_outlined,
        ),
        AtelierButton(
          text: strings.taskPauseEndOfShift,
          onClick: () => onSelect(PauseReason.endOfShift),
          style: AtelierButtonStyle.outlined,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          icon: Icons.logout_outlined,
        ),
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          strings.taskPauseBody,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
      ],
    );
  }
}

/// Reapertura de tarea completada (`POST /api/v1/tasks/{taskId}/reopen`).
class ReopenTaskSheet extends StatelessWidget {
  final ReopenTaskForm form;
  final bool isOnline;
  final bool isSaving;
  final UiText? error;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const ReopenTaskSheet({
    super.key,
    required this.form,
    required this.isOnline,
    required this.isSaving,
    required this.error,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    return AtelierBottomSheet(
      title: strings.tasksSeg2ReopenTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.tasksSeg2ReopenConfirm,
          onClick: onConfirm,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          loading: isSaving,
          icon: Icons.restart_alt_outlined,
        ),
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          strings.tasksSeg2ReopenBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: strings.tasksSeg2ReopenReasonLabel,
          value: form.reason,
          onValueChange: onReasonChange,
          enabled: !isSaving,
          placeholder: strings.tasksSeg2ReopenReasonHint,
          textInputAction: TextInputAction.done,
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
