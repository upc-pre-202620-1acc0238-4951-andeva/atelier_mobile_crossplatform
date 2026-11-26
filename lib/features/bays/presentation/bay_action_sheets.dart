import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bay_labels.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Acciones de las hojas del tablero.
class BaySheetActions {
  final ValueChanged<String> onOpenOrder;
  final ValueChanged<WorkBay> onMoveOrder;
  final ValueChanged<String> onAssignOrder;
  final VoidCallback onRelease;
  final VoidCallback onMaintenanceClick;
  final ValueChanged<String> onMaintenanceReasonChange;
  final VoidCallback onConfirmMaintenance;
  final VoidCallback onRestore;
  final VoidCallback onDismiss;

  const BaySheetActions({
    required this.onOpenOrder,
    required this.onMoveOrder,
    required this.onAssignOrder,
    required this.onRelease,
    required this.onMaintenanceClick,
    required this.onMaintenanceReasonChange,
    required this.onConfirmMaintenance,
    required this.onRestore,
    required this.onDismiss,
  });
}

/// US40: hoja de una bahía ocupada, libre o en mantenimiento.
class BayDetailSheet extends StatelessWidget {
  final BaysUiState state;
  final BayBoardItem item;
  final BaySheetActions actions;

  const BayDetailSheet({super.key, required this.state, required this.item, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final reason = state.sheet?.maintenanceReason;
    final error = state.error;
    final (title, content, buttons) = switch (item.bay.status) {
      BayStatus.occupied => _occupied(context, strings),
      BayStatus.available when reason != null => _maintenanceForm(strings, reason),
      BayStatus.available => _available(context, strings),
      BayStatus.maintenance => _maintenance(context, strings),
      null => (item.bay.name, const <Widget>[], const <Widget>[]),
    };
    return AtelierBottomSheet(
      title: title,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        ...buttons,
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: actions.onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !state.isBusy,
        ),
      ],
      content: [
        Text(item.bay.name, style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface)),
        ...content,
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }

  Widget _hint(BuildContext context, String text) =>
      Text(text, style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary));

  (String, List<Widget>, List<Widget>) _occupied(BuildContext context, AppLocalizations strings) {
    final occupant = item.occupant;
    final others = [for (final other in state.items) if (other.bay.id != item.bay.id) other.bay];
    return (
      strings.baysOccupiedSheetTitle,
      [
        _hint(context, strings.bayStatusOccupiedDesc),
        if (state.canReassign && occupant != null) ...[
          Text(
            strings.baysReassignSection,
            style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
          ),
          if (others.isEmpty) _hint(context, strings.baysNoFreeTargets),
          // US40 E2: las ocupadas y en mantenimiento se ven, pero no se pueden elegir.
          for (final bay in others)
            AtelierSelectionCard(
              title: bay.name,
              subtitle: switch (bay.status) {
                BayStatus.available => strings.bayStatusAvailableDesc,
                BayStatus.occupied => strings.bayStatusOccupiedDesc,
                BayStatus.maintenance => strings.bayStatusMaintenanceDesc,
                null => null,
              },
              badgeText: bayStatusLabel(strings, bay.status),
              enabled: bay.canReceive && state.canAct,
              onClick: () => actions.onMoveOrder(bay),
            ),
        ],
      ],
      [
        if (occupant != null)
          AtelierButton(
            text: strings.baysOpenOrderBtn,
            onClick: () => actions.onOpenOrder(occupant.workOrderId),
            minHeight: 56,
            enabled: !state.isBusy,
          ),
        if (occupant != null && state.canReassign)
          AtelierButton(
            text: strings.baysReleaseBtn,
            onClick: actions.onRelease,
            style: AtelierButtonStyle.destructive,
            enabled: state.canAct,
            loading: state.busyAction == BayAction.release,
          ),
      ],
    );
  }

  (String, List<Widget>, List<Widget>) _available(BuildContext context, AppLocalizations strings) {
    final orders = state.assignableOrders;
    return (
      strings.baysAvailableSheetTitle,
      [
        _hint(context, strings.bayStatusAvailableDesc),
        if (state.canReassign) ...[
          Text(
            strings.baysSelectOrderPrompt,
            style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
          ),
          if (orders.isEmpty) _hint(context, strings.baysNoAssignableOrders),
          for (final order in orders)
            AtelierSelectionCard(
              title: order.plate ?? orderNumberLabel(strings, order),
              subtitle: [
                if (order.plate != null) orderNumberLabel(strings, order),
                ?order.customerName,
              ].join(' · '),
              enabled: state.canAct,
              onClick: () => actions.onAssignOrder(order.id.value),
            ),
        ],
      ],
      [
        if (state.canManage)
          AtelierButton(
            text: strings.baysSetMaintenanceBtn,
            onClick: actions.onMaintenanceClick,
            style: AtelierButtonStyle.outlined,
            minHeight: 56,
            enabled: state.canAct,
          ),
      ],
    );
  }

  (String, List<Widget>, List<Widget>) _maintenanceForm(AppLocalizations strings, String reason) {
    final invalid = state.invalidField == 'reason';
    return (
      strings.baysSetMaintenanceBtn,
      [
        AtelierTextField(
          label: strings.baysMaintenanceReasonLabel,
          value: reason,
          onValueChange: actions.onMaintenanceReasonChange,
          enabled: !state.isBusy,
          placeholder: strings.baysMaintenanceReasonHint,
          isError: invalid,
          errorText: invalid ? strings.baysMaintenanceFieldError : null,
          textInputAction: TextInputAction.done,
        ),
      ],
      [
        AtelierButton(
          text: strings.baysMaintenanceConfirmBtn,
          onClick: actions.onConfirmMaintenance,
          minHeight: 56,
          enabled: state.canAct && reason.trim().isNotEmpty,
          loading: state.busyAction == BayAction.maintenance,
        ),
      ],
    );
  }

  (String, List<Widget>, List<Widget>) _maintenance(BuildContext context, AppLocalizations strings) {
    return (
      strings.baysMaintenanceSheetTitle,
      [_hint(context, strings.bayStatusMaintenanceDesc)],
      [
        if (state.canManage)
          AtelierButton(
            text: strings.baysRestoreBtn,
            onClick: actions.onRestore,
            minHeight: 56,
            enabled: state.canAct,
            loading: state.busyAction == BayAction.restore,
          ),
      ],
    );
  }
}

/// US40: registrar una bahía física (`operations:bays:manage`).
class CreateBaySheet extends StatelessWidget {
  final BaysUiState state;
  final CreateBayForm form;
  final ValueChanged<String> onNameChange;
  final ValueChanged<BayType> onTypeChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const CreateBaySheet({
    super.key,
    required this.state,
    required this.form,
    required this.onNameChange,
    required this.onTypeChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    final invalid = state.invalidField == 'name';
    return AtelierBottomSheet(
      title: strings.baysCreateDialogTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.baysCreateConfirm,
          onClick: onConfirm,
          minHeight: 56,
          enabled: state.canAct && form.name.trim().isNotEmpty,
          loading: state.busyAction == BayAction.create,
        ),
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !state.isBusy,
        ),
      ],
      content: [
        AtelierTextField(
          label: strings.baysNameLabel,
          value: form.name,
          onValueChange: onNameChange,
          enabled: !state.isBusy,
          placeholder: strings.baysNameHint,
          isError: invalid,
          errorText: invalid ? strings.baysNameError : null,
          textInputAction: TextInputAction.done,
        ),
        Text(
          strings.baysTypeLabel,
          style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
        ),
        for (final type in creatableBayTypes)
          AtelierSelectionCard(
            title: bayTypeLabel(strings, type) ?? type.value,
            selected: form.type == type,
            enabled: !state.isBusy,
            onClick: () => onTypeChange(type),
          ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
