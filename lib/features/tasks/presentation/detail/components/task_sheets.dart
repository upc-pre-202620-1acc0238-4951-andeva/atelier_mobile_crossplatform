import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
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

/// US30 E1: confirma las horas efectivas (precargadas del cronómetro) y cierra la tarea.
class CompleteTaskSheet extends StatelessWidget {
  final CompleteTaskForm form;
  final bool isOnline;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onHoursChange;
  final ValueChanged<String> onNotesChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const CompleteTaskSheet({
    super.key,
    required this.form,
    required this.isOnline,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onHoursChange,
    required this.onNotesChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    final badHours = invalidField == 'actualLaborHours';
    final badNotes = invalidField == 'notes';
    return AtelierBottomSheet(
      title: strings.taskCompleteTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.taskCompleteConfirm,
          onClick: onConfirm,
          minHeight: 56,
          enabled: isOnline && !isSaving && form.hours.trim().isNotEmpty,
          loading: isSaving,
          icon: Icons.task_alt_outlined,
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
          strings.taskCompleteBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: strings.taskCompleteHours,
          value: form.hours,
          onValueChange: onHoursChange,
          enabled: !isSaving,
          isError: badHours,
          errorText: badHours ? strings.taskFieldHours : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.taskCompleteNotes,
          value: form.notes,
          onValueChange: onNotesChange,
          enabled: !isSaving,
          isError: badNotes,
          errorText: badNotes ? strings.taskFieldNotes : null,
          textInputAction: TextInputAction.done,
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// US29 E1: el técnico justifica la suspensión por una pieza defectuosa o faltante.
class RequestSuspensionSheet extends StatelessWidget {
  static const _maxResults = 6;

  final RequestSuspensionForm form;
  final bool isOnline;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onDescriptionChange;
  final ValueChanged<String> onPartQueryChange;
  final ValueChanged<PartOption> onPartSelect;
  final VoidCallback onPartClear;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const RequestSuspensionSheet({
    super.key,
    required this.form,
    required this.isOnline,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onDescriptionChange,
    required this.onPartQueryChange,
    required this.onPartSelect,
    required this.onPartClear,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    final selected = form.selectedPart;
    final badDescription = invalidField == 'missingItemDescription';
    return AtelierBottomSheet(
      title: strings.tasksSeg2SuspensionRequestTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.tasksSeg2SuspensionRequestConfirm,
          onClick: onConfirm,
          minHeight: 56,
          enabled: isOnline && !isSaving && form.missingItemDescription.trim().isNotEmpty,
          loading: isSaving,
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
          strings.tasksSeg2SuspensionRequestBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: strings.tasksSeg2SuspensionItemLabel,
          value: form.missingItemDescription,
          onValueChange: onDescriptionChange,
          enabled: !isSaving,
          placeholder: strings.tasksSeg2SuspensionItemHint,
          isError: badDescription,
          errorText: badDescription ? strings.tasksSeg2SuspensionItemError : null,
          textInputAction: TextInputAction.done,
        ),
        if (selected == null) ...[
          AtelierTextField(
            label: strings.tasksSeg2SuspensionPartOptional,
            value: form.partQuery,
            onValueChange: onPartQueryChange,
            enabled: !isSaving,
            placeholder: strings.catalogSearchHint,
            textInputAction: TextInputAction.search,
          ),
          if (form.isSearching)
            Text(
              strings.searchLoading,
              style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
            ),
          for (final part in form.partResults.take(_maxResults))
            AtelierSelectionCard(
              title: part.name,
              subtitle: part.isAvailable ? strings.partStock(part.totalStock.formatQuantity()) : strings.stockOut,
              selected: false,
              enabled: !isSaving,
              onClick: () => onPartSelect(part),
            ),
        ] else ...[
          AtelierSelectionCard(title: selected.name, selected: true, enabled: false, onClick: () {}),
          AtelierButton(
            text: strings.tasksSeg2SuspensionPartClear,
            onClick: onPartClear,
            style: AtelierButtonStyle.text,
            enabled: !isSaving,
          ),
        ],
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// US29 E1/E2: el supervisor audita el motivo y aprueba o desestima.
class ReviewSuspensionSheet extends StatelessWidget {
  final String? reason;
  final String? missingItemDescription;
  final DateTime? requestedAt;
  final bool isOnline;
  final TaskAction? busyAction;
  final UiText? error;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDismiss;

  const ReviewSuspensionSheet({
    super.key,
    required this.reason,
    this.missingItemDescription,
    required this.requestedAt,
    required this.isOnline,
    required this.busyAction,
    required this.error,
    required this.onApprove,
    required this.onReject,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    final reason = this.reason;
    final requestedAt = this.requestedAt;
    final isSaving = busyAction != null;
    return AtelierBottomSheet(
      title: strings.ordersSuspensionTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.ordersSuspensionApprove,
          onClick: onApprove,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          loading: busyAction == TaskAction.approveSuspension,
        ),
        AtelierButton(
          text: strings.ordersSuspensionReject,
          onClick: onReject,
          style: AtelierButtonStyle.outlined,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          loading: busyAction == TaskAction.rejectSuspension,
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
          reason != null && reason.trim().isNotEmpty ? reason : strings.ordersSuspensionNoReason,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        if (missingItemDescription != null && missingItemDescription!.trim().isNotEmpty)
          Text(
            strings.ordersSuspensionMissingItem(missingItemDescription!),
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
        if (requestedAt != null)
          Text(
            strings.tasksSeg2SuspensionRequestedAt(formatLimaDayTime(requestedAt)),
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// US29 E3: confirma que el repuesto está conforme y levanta la suspensión.
class ResumeSuspensionSheet extends StatelessWidget {
  final bool isOnline;
  final bool isSaving;
  final UiText? error;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const ResumeSuspensionSheet({
    super.key,
    required this.isOnline,
    required this.isSaving,
    required this.error,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = this.error;
    return AtelierBottomSheet(
      title: strings.tasksSeg2SuspensionResumeSheetTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.ordersResumeTask,
          onClick: onConfirm,
          minHeight: 56,
          enabled: isOnline && !isSaving,
          loading: isSaving,
          icon: Icons.play_arrow_outlined,
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
          strings.tasksSeg2SuspensionResumeSheetBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
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

/// Hoja para reintentar o descartar una evidencia fotográfica cuya subida falló en `pending_operations`.
class FailedEvidenceSheet extends StatelessWidget {
  final PendingEvidence evidence;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;
  final VoidCallback onDismiss;

  const FailedEvidenceSheet({
    super.key,
    required this.evidence,
    required this.onRetry,
    required this.onDiscard,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = evidence.lastErrorMessage;
    return AtelierBottomSheet(
      title: strings.tasksSeg2EvidenceFailedSheetTitle,
      actions: [
        AtelierButton(text: strings.syncRetryBtn, onClick: onRetry, minHeight: 56, icon: Icons.refresh_outlined),
        AtelierButton(
          text: strings.syncDiscardBtn,
          onClick: onDiscard,
          style: AtelierButtonStyle.destructive,
          minHeight: 56,
          icon: Icons.delete_outline,
        ),
        AtelierButton(text: strings.proposalsCancel, onClick: onDismiss, style: AtelierButtonStyle.text),
      ],
      content: [
        Text(
          evidence.description ?? '',
          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
        ),
        if (error != null && error.trim().isNotEmpty) AtelierBanner(message: error, icon: Icons.error_outline),
      ],
    );
  }
}

/// Confirmación al retroceder con una nota de evidencia escrita y aún no fotografiada.
class UnsavedEvidenceExitSheet extends StatelessWidget {
  final VoidCallback onConfirmExit;
  final VoidCallback onDismiss;

  const UnsavedEvidenceExitSheet({super.key, required this.onConfirmExit, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.tasksSeg2UnsavedExitTitle,
      actions: [
        AtelierButton(
          text: strings.tasksSeg2UnsavedExitConfirm,
          onClick: onConfirmExit,
          style: AtelierButtonStyle.destructive,
          minHeight: 56,
        ),
        AtelierButton(text: strings.proposalsCancel, onClick: onDismiss, style: AtelierButtonStyle.text),
      ],
      content: [
        Text(
          strings.tasksSeg2UnsavedExitBody,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
      ],
    );
  }
}
