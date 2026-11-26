import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bay_labels.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart' hide workOrderStatusChipKind, workOrderStatusLabel;
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Acciones de las hojas del tablero.
class BaySheetActions {
  final ValueChanged<String> onOpenOrder;
  final ValueChanged<WorkBay> onMoveOrder;
  final ValueChanged<String> onAssignOrder;
  final VoidCallback onRelease;
  final ValueChanged<String?> onOpenReassignTaskMechanic;
  final void Function(String taskId, String mechanicId) onConfirmReassignTaskMechanic;
  final VoidCallback onMaintenanceClick;
  final VoidCallback onMaintenanceBack;
  final ValueChanged<String> onMaintenanceReasonChange;
  final VoidCallback onConfirmMaintenance;
  final VoidCallback onRestore;
  final VoidCallback onDismiss;

  const BaySheetActions({
    required this.onOpenOrder,
    required this.onMoveOrder,
    required this.onAssignOrder,
    required this.onRelease,
    required this.onOpenReassignTaskMechanic,
    required this.onConfirmReassignTaskMechanic,
    required this.onMaintenanceClick,
    required this.onMaintenanceBack,
    required this.onMaintenanceReasonChange,
    required this.onConfirmMaintenance,
    required this.onRestore,
    required this.onDismiss,
  });
}

/// US40: hoja contextual de una bahía. Ocupada: abrir la orden, liberar, mover la orden a otra bahía libre o
/// cambiar el mecánico de cada tarea; libre: elegir la orden que ingresa o ponerla en mantenimiento; en
/// mantenimiento: restaurar.
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
    final bay = item.bay;
    final occupant = item.occupant;
    final busy = state.isBusy;
    final title = switch (bay.status) {
      BayStatus.occupied => strings.baysOccupiedSheetTitle,
      BayStatus.available => strings.baysAvailableSheetTitle,
      BayStatus.maintenance => strings.baysMaintenanceSheetTitle,
      null => bay.name,
    };
    final type = bayTypeLabel(strings, bay.type);
    return AtelierBottomSheet(
      title: title,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        ..._buttons(strings, reason, occupant),
        AtelierButton(
          text: strings.commonCancel,
          onClick: actions.onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !busy,
        ),
      ],
      content: [
        Text(bay.name, style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface)),
        if (type != null) Text(type, style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary)),
        if (occupant != null) ..._occupantContent(context, strings, occupant),
        if (bay.status == BayStatus.available) ..._availableContent(context, strings, reason),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }

  List<Widget> _buttons(AppLocalizations strings, String? reason, BayOccupant? occupant) {
    final busy = state.isBusy;
    switch (item.bay.status) {
      case BayStatus.occupied:
        if (occupant == null) return const [];
        return [
          if (state.canReadWorkOrders)
            AtelierButton(
              text: strings.baysOpenOrderBtn,
              onClick: () => actions.onOpenOrder(occupant.workOrderId),
              enabled: !busy,
            ),
          if (state.canReleaseBay)
            AtelierButton(
              text: strings.baysReleaseBtn,
              onClick: actions.onRelease,
              style: AtelierButtonStyle.destructive,
              enabled: state.canAct,
              loading: state.busyAction == BayAction.release,
            ),
        ];
      case BayStatus.available:
        if (!state.canManage) return const [];
        if (reason != null) {
          return [
            AtelierButton(
              text: strings.baysMaintenanceConfirmBtn,
              onClick: actions.onConfirmMaintenance,
              style: AtelierButtonStyle.destructiveFilled,
              enabled: state.canAct && reason.trim().isNotEmpty,
              loading: state.busyAction == BayAction.maintenance,
            ),
            AtelierButton(
              text: strings.commonBack,
              onClick: actions.onMaintenanceBack,
              style: AtelierButtonStyle.text,
              enabled: !busy,
            ),
          ];
        }
        return [
          AtelierButton(
            text: strings.baysSetMaintenanceBtn,
            onClick: actions.onMaintenanceClick,
            style: AtelierButtonStyle.outlined,
            icon: Icons.build_outlined,
            enabled: state.canAct,
          ),
        ];
      case BayStatus.maintenance:
        if (!state.canManage) return const [];
        return [
          AtelierButton(
            text: strings.baysRestoreBtn,
            onClick: actions.onRestore,
            enabled: state.canAct,
            loading: state.busyAction == BayAction.restore,
          ),
        ];
      case null:
        return const [];
    }
  }

  List<Widget> _occupantContent(BuildContext context, AppLocalizations strings, BayOccupant occupant) {
    final secondary = context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary);
    final elapsed = bayLiveElapsed(occupant, DateTime.now()) ?? occupant.laborElapsed;
    final mechanics = state.mechanicLabelsFor(occupant);
    final orderText = [
      if (occupant.internalNumber != null) strings.todayOrderNumber(occupant.internalNumber!),
      if (elapsed != null) strings.baysLabor(formatBayElapsed(elapsed)),
      if (mechanics.isNotEmpty) mechanics.join(', '),
    ].join(' · ');
    final busy = state.isBusy;
    return [
      if (occupant.plate case final plate?) AtelierPlate(plate: plate, size: PlateSize.l),
      if (orderText.isNotEmpty) Text(orderText, style: secondary),
      if (occupant.tasks.isNotEmpty) ...[
        AtelierSectionHeader(title: strings.baysMechanicsSection),
        for (final task in occupant.tasks) ...[
          _taskRow(strings, task, busy),
          if (state.reassigningTaskId == task.id.value)
            for (final mechanic in state.availableMechanics)
              AtelierSelectionCard(
                title: mechanic.displayName,
                subtitle: mechanic.jobTitle ?? strings.orderMechanicRoleDefault,
                selected: mechanic.membershipId == task.mechanicId,
                enabled: state.isOnline && !busy,
                onClick: () => actions.onConfirmReassignTaskMechanic(task.id.value, mechanic.membershipId),
              ),
        ],
      ],
      if (state.canAssignBay && state.availableBays.isNotEmpty) ...[
        AtelierSectionHeader(title: strings.baysReassignSection),
        for (final target in state.availableBays)
          AtelierSelectionCard(
            title: target.name,
            subtitle: bayTypeLabel(strings, target.type),
            enabled: state.isOnline && !busy,
            onClick: () => actions.onMoveOrder(target),
          ),
      ],
    ];
  }

  Widget _taskRow(AppLocalizations strings, TaskDetail task, bool busy) {
    final serviceName = task.serviceName;
    final title = serviceName != null && serviceName.trim().isNotEmpty ? serviceName : task.description;
    final mechanic = state.mechanicNameFor(task.mechanicId, task.mechanicName) ?? strings.orderMechanicUnassigned;
    final canReassign = state.canReleaseBay && state.isOnline && !busy && state.availableMechanics.isNotEmpty;
    final reassigningThis = state.reassigningTaskId == task.id.value;
    return AtelierListRow(
      title: title,
      subtitle: mechanic,
      onClick: canReassign ? () => actions.onOpenReassignTaskMechanic(reassigningThis ? null : task.id.value) : null,
      trailing: canReassign ? AtelierChip(text: strings.orderReassignMechanicBtn, kind: ChipKind.info) : null,
    );
  }

  List<Widget> _availableContent(BuildContext context, AppLocalizations strings, String? reason) {
    if (reason != null) {
      final invalid = state.invalidField == 'reason';
      return [
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
      ];
    }
    final orders = state.assignableOrders;
    if (!state.canAssignBay || orders.isEmpty) return const [];
    return [
      Text(
        strings.baysSelectOrderPrompt,
        style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
      ),
      for (final order in orders)
        AtelierListRow(
          title: order.customerName ?? orderNumberLabel(strings, order),
          subtitle: order.customerName != null ? orderNumberLabel(strings, order) : null,
          plate: order.plate,
          onClick: state.canAct ? () => actions.onAssignOrder(order.id.value) : null,
          trailing: AtelierChip(
            text: workOrderStatusLabel(strings, order.status),
            kind: workOrderStatusChipKind(order.status),
          ),
        ),
    ];
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
          text: strings.commonCancel,
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
        Text(strings.baysTypeLabel, style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary)),
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
