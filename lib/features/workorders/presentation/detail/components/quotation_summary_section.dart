import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/cascade.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// US22 + US23: una tarea con su desglose en cascada (mano de obra + repuestos imputados = total de la
/// tarea). Sin tarjeta: la fila de la tarea abre su cronómetro y debajo van mecánico, mano de obra y
/// repuestos, sangrados. Sin "Reanudar tarea" ni el chip de suspensión por aprobar (US29).
class TaskBlock extends StatelessWidget {
  final TaskDetail task;
  final WorkOrderDetailUiState state;
  final VoidCallback onOpenTask;
  final VoidCallback onEditLabor;
  final VoidCallback onAddPart;
  final ValueChanged<TaskProduct> onEditPart;
  final ValueChanged<TaskProduct> onReturnPart;
  final VoidCallback onAssignMechanic;
  final VoidCallback? onDeleteTask;
  final bool showOuterDivider;

  const TaskBlock({
    super.key,
    required this.task,
    required this.state,
    required this.onOpenTask,
    required this.onEditLabor,
    required this.onAddPart,
    required this.onEditPart,
    required this.onReturnPart,
    required this.onAssignMechanic,
    this.onDeleteTask,
    this.showOuterDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = context.scheme;
    final currency = state.breakdown?.currency ?? task.price?.currency ?? Money.pen;
    final title = state.taskTitle(task);
    final laborMoney = task.price ?? Money(amount: Decimal.zero, currency: currency);
    final mechanicName = state.mechanicNameFor(task);
    final unassigned = strings.orderMechanicUnassigned;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AtelierListRow(
          title: title,
          subtitle: mechanicName ?? unassigned,
          showDivider: false,
          onClick: onOpenTask,
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 4,
            children: [
              AtelierChip(
                text: taskStatusLabel(strings, task.status, task.holdReason),
                kind: taskStatusChipKind(task.status, task.holdReason),
              ),
              Text(
                cascadeTotalOf(task, currency).format(),
                style: context.text.titleMedium?.copyWith(color: scheme.onSurface),
                maxLines: 1,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DetailLine(
                label: strings.orderTaskMechanicLabel,
                value: mechanicName ?? unassigned,
                actionLabel: state.canChangeMechanic
                    ? (mechanicName != null
                          ? strings.orderReassignMechanicBtn
                          : strings.orderAssignMechanicBtn)
                    : null,
                onClick: state.canChangeMechanic ? onAssignMechanic : null,
              ),
              _DetailLine(
                label: strings.orderTaskLabor,
                value: laborMoney.format(),
                actionLabel: state.canModifyTasks ? strings.orderEditLabor : null,
                onClick: state.canModifyTasks ? onEditLabor : null,
              ),
              for (final product in task.products)
                _PartLine(
                  product: product,
                  title: state.productTitle(product) ?? strings.taskPartUnnamed,
                  currency: currency,
                  canEdit: state.canEditTaskParts,
                  onEdit: () => onEditPart(product),
                  onReturn: () => onReturnPart(product),
                ),
              if (state.canAddPartToTask ||
                  (state.canModifyTasks && task.status != TaskStatus.completed && onDeleteTask != null))
                Row(
                  spacing: 8,
                  children: [
                    if (state.canAddPartToTask)
                      AtelierButton(
                        text: strings.orderAddPart,
                        onClick: onAddPart,
                        style: AtelierButtonStyle.text,
                      ),
                    if (state.canModifyTasks && task.status != TaskStatus.completed && onDeleteTask != null)
                      AtelierButton(
                        text: strings.orderDeleteTask,
                        onClick: onDeleteTask!,
                        style: AtelierButtonStyle.destructive,
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (showOuterDivider) Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

/// Línea rótulo y valor de 48 dp; con [onClick] muestra su acción en el color de acento.
class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final String? actionLabel;
  final VoidCallback? onClick;

  const _DetailLine({
    required this.label,
    required this.value,
    required this.actionLabel,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final actionLabel = this.actionLabel;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary)),
                Text(
                  value,
                  style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            Text(
              actionLabel,
              style: context.text.labelLarge?.copyWith(color: colors.primaryText),
            ),
        ],
      ),
    );
    if (onClick == null) return content;
    return Semantics(button: true, child: InkWell(onTap: onClick, child: content));
  }
}

class _PartLine extends StatelessWidget {
  final TaskProduct product;
  final String title;
  final String currency;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onReturn;

  const _PartLine({
    required this.product,
    required this.title,
    required this.currency,
    required this.canEdit,
    required this.onEdit,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = context.scheme;
    final unit = product.unitPrice ?? Money(amount: Decimal.zero, currency: currency);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: context.text.bodyLarge?.copyWith(color: scheme.onSurface),
                      ),
                      Text(
                        strings.orderPartLineDetail(product.quantity.formatQuantity(), unit.format()),
                        style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  resolvedTotal(product, currency).format(),
                  style: context.text.bodyLarge?.copyWith(color: scheme.onSurface),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        if (canEdit)
          Row(
            spacing: 8,
            children: [
              AtelierButton(
                text: strings.taskPartEdit,
                onClick: onEdit,
                style: AtelierButtonStyle.text,
              ),
              AtelierButton(
                text: strings.taskPartReturn,
                onClick: onReturn,
                style: AtelierButtonStyle.text,
              ),
            ],
          ),
      ],
    );
  }
}

/// US24: las acciones de la proforma, generar el PDF y enviarlo por correo. Sin sssobre el resumen en
/// cascada (subtotal, IGV y total): es la historia US36. Sin conexión las acciones se apagan y se dice por qué.
class QuotationSection extends StatelessWidget {
  final bool canGeneratePdf;
  final bool canEmailQuotation;
  final bool showPdfActions;
  final bool showEmailAction;
  final WorkOrderDetailAction? busyAction;
  final VoidCallback onGeneratePdf;
  final VoidCallback onSendEmail;

  const QuotationSection({
    super.key,
    required this.canGeneratePdf,
    required this.canEmailQuotation,
    required this.showPdfActions,
    required this.showEmailAction,
    required this.busyAction,
    required this.onGeneratePdf,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          if (showPdfActions)
            Expanded(
              child: AtelierButton(
                text: strings.quotationGeneratePdf,
                onClick: onGeneratePdf,
                style: AtelierButtonStyle.tonal,
                enabled: canGeneratePdf,
                loading: busyAction == WorkOrderDetailAction.downloadPdf,
                icon: Icons.description_outlined,
              ),
            ),
          if (showEmailAction)
            Expanded(
              child: AtelierButton(
                text: strings.ordersQuotationSendShort,
                onClick: onSendEmail,
                style: AtelierButtonStyle.outlined,
                enabled: canEmailQuotation,
                loading: busyAction == WorkOrderDetailAction.sendEmail,
              ),
            ),
        ],
      ),
    );
  }
}
