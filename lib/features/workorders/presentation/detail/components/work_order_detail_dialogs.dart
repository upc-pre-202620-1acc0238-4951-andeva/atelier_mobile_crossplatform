import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/date_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/cascade.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/components/quotation_summary_section.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/pick_row.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _maxPartResults = 8;

/// Los campos de importe aceptan coma o punto decimal.
final _decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
const _decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

class _SheetError extends StatelessWidget {
  final UiText? error;

  const _SheetError(this.error);

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error == null) return const SizedBox.shrink();
    return AtelierBanner(
      message: error.asString(AppLocalizations.of(context)),
      icon: Icons.error_outline,
    );
  }
}

/// US22 E1: agregar una nueva tarea con su servicio y precio de mano de obra sin IGV.
class AddTaskSheet extends StatelessWidget {
  final AddTaskForm form;
  final List<ServiceOption> services;
  final List<MechanicOption> mechanics;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<ServiceOption> onSelectService;
  final ValueChanged<String> onDescriptionChange;
  final ValueChanged<String> onPriceChange;
  final ValueChanged<String?> onSelectMechanic;
  final VoidCallback onConfirm;

  const AddTaskSheet({
    super.key,
    required this.form,
    required this.services,
    required this.mechanics,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onSelectService,
    required this.onDescriptionChange,
    required this.onPriceChange,
    required this.onSelectMechanic,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final labelStyle = context.text.labelLarge?.copyWith(color: colors.inkSecondary);
    return AtelierBottomSheet(
      title: strings.orderAddTaskTitle,
      actions: [
        AtelierButton(
          text: strings.orderAddTaskConfirm,
          onClick: onConfirm,
          enabled: form.serviceId != null && form.description.trim().isNotEmpty && !isSaving,
          loading: isSaving,
        ),
      ],
      content: [
        Text(strings.orderAddTaskService, style: labelStyle),
        Column(
          children: [
            for (final service in services)
              PickRow(
                title: service.name,
                subtitle: service.basePrice?.format(),
                selected: service.id == form.serviceId,
                enabled: !isSaving,
                onClick: () => onSelectService(service),
              ),
          ],
        ),
        if (invalidField == 'serviceId')
          Text(
            strings.orderFieldService,
            style: context.text.bodyMedium?.copyWith(color: colors.bad),
          ),
        AtelierTextField(
          label: strings.orderAddTaskDescription,
          value: form.description,
          onValueChange: onDescriptionChange,
          enabled: !isSaving,
          isError: invalidField == 'description',
          errorText: invalidField == 'description' ? strings.orderFieldDescription : null,
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.orderAddTaskPrice,
          value: form.price,
          onValueChange: onPriceChange,
          enabled: !isSaving,
          isError: invalidField == 'price',
          errorText: invalidField == 'price' ? strings.orderFieldPrice : null,
          keyboardType: _decimalKeyboard,
          textInputAction: TextInputAction.done,
          inputFormatters: _decimalFormatters,
        ),
        if (mechanics.isNotEmpty) ...[
          Text(strings.orderAddTaskMechanic, style: labelStyle),
          Column(
            children: [
              PickRow(
                title: strings.openOrderMechanicNone,
                selected: form.mechanicId == null,
                enabled: !isSaving,
                onClick: () => onSelectMechanic(null),
              ),
              for (final mechanic in mechanics)
                PickRow(
                  title: mechanic.displayName,
                  subtitle: _mechanicRole(mechanic),
                  selected: mechanic.membershipId == form.mechanicId,
                  enabled: !isSaving,
                  onClick: () => onSelectMechanic(mechanic.membershipId),
                ),
            ],
          ),
        ],
        _SheetError(error),
      ],
    );
  }
}

String? _mechanicRole(MechanicOption mechanic) {
  final title = mechanic.jobTitle;
  return mechanic.name != null && title != null && title.trim().isNotEmpty ? title : null;
}

/// US22 E2: actualizar el precio de mano de obra sin IGV de una tarea existente.
class EditLaborSheet extends StatelessWidget {
  final EditLaborForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onPriceChange;
  final VoidCallback onConfirm;

  const EditLaborSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onPriceChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.orderEditLaborTitle,
      actions: [
        AtelierButton(
          text: strings.orderEditLaborConfirm,
          onClick: onConfirm,
          enabled: form.price.trim().isNotEmpty && !isSaving,
          loading: isSaving,
        ),
      ],
      content: [
        Text(
          form.taskTitle,
          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
        ),
        AtelierTextField(
          label: strings.orderAddTaskPrice,
          value: form.price,
          onValueChange: onPriceChange,
          enabled: !isSaving,
          isError: invalidField == 'price',
          errorText: invalidField == 'price' ? strings.orderFieldPrice : null,
          keyboardType: _decimalKeyboard,
          textInputAction: TextInputAction.done,
          inputFormatters: _decimalFormatters,
        ),
        _SheetError(error),
      ],
    );
  }
}

/// Confirmación para eliminar una tarea no completada de la orden de trabajo.
class DeleteTaskSheet extends StatelessWidget {
  final String taskTitle;
  final bool hasProducts;
  final bool isSaving;
  final UiText? error;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const DeleteTaskSheet({
    super.key,
    required this.taskTitle,
    required this.hasProducts,
    required this.isSaving,
    required this.error,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.orderDeleteTaskTitle,
      actions: [
        AtelierButton(
          text: strings.orderDeleteTaskConfirm,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: !hasProducts && !isSaving,
          loading: isSaving,
        ),
        AtelierButton(
          text: strings.quotationRejectBack,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        if (hasProducts)
          AtelierBanner(
            message: strings.orderDeleteTaskHasParts,
            icon: Icons.error_outline,
            kind: BannerKind.wait,
          )
        else
          Text(
            strings.orderDeleteTaskBody(taskTitle),
            style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
          ),
        _SheetError(error),
      ],
    );
  }
}

/// US25 E2: «Cancelar la orden» tras el desistimiento del cliente. Los repuestos reservados vuelven al
/// inventario; exige el motivo (`reason`).
class RejectQuotationSheet extends StatelessWidget {
  final RejectQuotationForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const RejectQuotationSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _ReasonSheet(
      title: strings.quotationRejectTitle,
      body: strings.quotationRejectBody,
      label: strings.quotationRejectReasonLabel,
      hint: strings.quotationRejectReasonHint,
      fieldError: strings.quotationRejectFieldError,
      confirmText: strings.quotationRejectConfirm,
      value: form.reason,
      isSaving: isSaving,
      invalid: invalidField == 'reason',
      error: error,
      onReasonChange: onReasonChange,
      onConfirm: onConfirm,
      onDismiss: onDismiss,
    );
  }
}

/// Cancelar la orden en cualquier momento: siempre se confirma aquí y pide el motivo.
class CancelOrderSheet extends StatelessWidget {
  final CancelOrderForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const CancelOrderSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return _ReasonSheet(
      title: strings.ordersCancelTitle,
      body: strings.ordersCancelBody,
      label: strings.ordersCancelReasonLabel,
      hint: strings.ordersCancelReasonHint,
      fieldError: strings.ordersCancelFieldError,
      confirmText: strings.ordersCancelConfirm,
      value: form.reason,
      isSaving: isSaving,
      invalid: invalidField == 'reason',
      error: error,
      onReasonChange: onReasonChange,
      onConfirm: onConfirm,
      onDismiss: onDismiss,
    );
  }
}

class _ReasonSheet extends StatelessWidget {
  final String title;
  final String body;
  final String label;
  final String hint;
  final String fieldError;
  final String confirmText;
  final String value;
  final bool isSaving;
  final bool invalid;
  final UiText? error;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const _ReasonSheet({
    required this.title,
    required this.body,
    required this.label,
    required this.hint,
    required this.fieldError,
    required this.confirmText,
    required this.value,
    required this.isSaving,
    required this.invalid,
    required this.error,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: title,
      actions: [
        AtelierButton(
          text: confirmText,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: value.trim().isNotEmpty && !isSaving,
          loading: isSaving,
        ),
        AtelierButton(
          text: strings.quotationRejectBack,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          body,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: label,
          value: value,
          onValueChange: onReasonChange,
          enabled: !isSaving,
          placeholder: hint,
          isError: invalid,
          errorText: invalid ? fieldError : null,
          textInputAction: TextInputAction.done,
        ),
        _SheetError(error),
      ],
    );
  }
}

/// US25: la proforma espera la respuesta del cliente. Aceptó inicia los trabajos; rechazó pasa al motivo y
/// cancela la orden.
class QuotationDecisionSheet extends StatelessWidget {
  final bool isApproving;
  final bool isBusy;
  final bool isOnline;
  final UiText? error;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const QuotationDecisionSheet({
    super.key,
    required this.isApproving,
    required this.isBusy,
    required this.isOnline,
    required this.error,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.ordersQuotationDecisionTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.quotationApproveAction,
          onClick: onApprove,
          enabled: !isBusy,
          loading: isApproving,
        ),
        AtelierButton(
          text: strings.quotationRejectAction,
          onClick: onReject,
          style: AtelierButtonStyle.destructive,
          enabled: !isBusy,
        ),
      ],
      content: [
        Text(
          strings.quotationCustomerQuestion,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        _SheetError(error),
      ],
    );
  }
}

/// US24 + US36: la proforma generada, con el resumen de liquidación en cascada y lista para compartir.
class PdfPreviewSheet extends StatelessWidget {
  final File pdfFile;
  final CascadeBreakdown? breakdown;
  final VoidCallback onShare;
  final VoidCallback onDismiss;

  const PdfPreviewSheet({
    super.key,
    required this.pdfFile,
    this.breakdown,
    required this.onShare,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final name = pdfFile.uri.pathSegments.isEmpty ? pdfFile.path : pdfFile.uri.pathSegments.last;
    final currentBreakdown = breakdown;
    return AtelierBottomSheet(
      title: strings.quotationPdfPreviewTitle,
      actions: [
        AtelierButton(
          text: strings.quotationShareChooser,
          onClick: onShare,
          icon: Icons.share_outlined,
        ),
        AtelierButton(
          text: strings.quotationPdfClose,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
        ),
      ],
      content: [
        Text(
          name,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (currentBreakdown != null) ...[
          SummaryRow(label: strings.quotationSubtotal, value: currentBreakdown.subtotal.format()),
          SummaryRow(label: strings.quotationIgv, value: currentBreakdown.taxAmount.format()),
          SummaryRow(
            label: strings.quotationTotal,
            value: currentBreakdown.totalAmount.format(),
            emphasized: true,
          ),
        ],
        AtelierBanner(
          message: strings.quotationPdfReady,
          icon: Icons.description_outlined,
          kind: BannerKind.info,
        ),
      ],
    );
  }
}

/// Asignar o reasignar el mecánico responsable de una tarea (US12 E2, US22 E2).
class AssignMechanicSheet extends StatelessWidget {
  final String taskTitle;
  final String? currentMechanicId;
  final List<MechanicOption> mechanics;
  final bool isSaving;
  final UiText? error;
  final ValueChanged<MechanicOption> onSelectMechanic;
  final VoidCallback onDismiss;

  const AssignMechanicSheet({
    super.key,
    required this.taskTitle,
    required this.currentMechanicId,
    required this.mechanics,
    required this.isSaving,
    required this.error,
    required this.onSelectMechanic,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return AtelierBottomSheet(
      title: strings.orderAssignMechanicTitle,
      actions: [
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          strings.orderAssignMechanicSubtitle(taskTitle),
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
        if (mechanics.isEmpty)
          Text(
            strings.orderMechanicsEmpty,
            style: context.text.bodyLarge?.copyWith(color: colors.inkSecondary),
          )
        else
          Column(
            children: [
              for (final mechanic in mechanics)
                PickRow(
                  title: mechanic.displayName,
                  subtitle: _mechanicRole(mechanic),
                  selected: mechanic.membershipId == currentMechanicId,
                  enabled: !isSaving,
                  onClick: () => onSelectMechanic(mechanic),
                  leading: Icon(Icons.person_outline, color: colors.inkSecondary),
                  trailing: mechanic.membershipId == currentMechanicId
                      ? AtelierChip(text: strings.orderMechanicCurrent, kind: ChipKind.info)
                      : null,
                ),
            ],
          ),
        _SheetError(error),
      ],
    );
  }
}

/// US32 E2: buscar el repuesto e imputarlo desde la orden en hoja inferior (acciones al alcance del pulgar).
class OrderChargePartSheet extends StatelessWidget {
  final ChargeForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<PartOption> onSelect;
  final ValueChanged<String> onQuantityChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const OrderChargePartSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onQueryChange,
    required this.onSelect,
    required this.onQuantityChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final selected = form.selected;
    return AtelierBottomSheet(
      title: strings.chargeTitle,
      actions: [
        AtelierButton(
          text: strings.chargeConfirm,
          onClick: onConfirm,
          enabled: selected != null && form.quantity.trim().isNotEmpty && !isSaving,
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
        if (selected == null) ...[
          AtelierTextField(
            label: strings.catalogSearchLabel,
            value: form.query,
            onValueChange: onQueryChange,
            enabled: !isSaving,
            placeholder: strings.catalogSearchHint,
            textInputAction: TextInputAction.search,
          ),
          Text(
            strings.chargeSelectPartPrompt,
            style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
          ),
          if (form.isSearching)
            Text(
              strings.searchLoading,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            )
          else if (form.results.isEmpty)
            Text(
              strings.catalogEmptyFiltered,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            )
          else
            for (final part in form.results.take(_maxPartResults))
              _OrderPartOptionRow(part: part, onSelect: onSelect, enabled: !isSaving),
        ] else ...[
          _OrderPartOptionRow(part: selected, onSelect: (_) {}, enabled: false, selected: true),
          AtelierButton(
            text: strings.chargeChangePartBtn,
            onClick: () => onQueryChange(form.query),
            style: AtelierButtonStyle.text,
            enabled: !isSaving,
          ),
          AtelierTextField(
            label: strings.chargeQuantity,
            value: form.quantity,
            onValueChange: onQuantityChange,
            enabled: !isSaving,
            isError: invalidField == 'quantity',
            errorText: invalidField == 'quantity' ? strings.taskFieldQuantity : null,
            keyboardType: _decimalKeyboard,
            textInputAction: TextInputAction.done,
            inputFormatters: _decimalFormatters,
          ),
        ],
        _SheetError(error),
      ],
    );
  }
}

class _OrderPartOptionRow extends StatelessWidget {
  final PartOption part;
  final ValueChanged<PartOption> onSelect;
  final bool enabled;
  final bool selected;

  const _OrderPartOptionRow({
    required this.part,
    required this.onSelect,
    required this.enabled,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stockText = part.isAvailable
        ? strings.partStock(_formatQuantity(part.totalStock))
        : strings.stockOut;
    final basePrice = part.basePrice;
    final priceFormatted = basePrice == null
        ? null
        : strings.partPrice(Money(amount: basePrice, currency: Money.pen).format());
    return AtelierSelectionCard(
      title: part.name,
      subtitle: stockText,
      price: priceFormatted,
      badgeText: !part.isAvailable ? strings.stockOut : null,
      badgeColor: !part.isAvailable ? context.atelier.badContainer : null,
      selected: selected,
      enabled: enabled && part.isAvailable,
      onClick: () => onSelect(part),
    );
  }
}

String _formatQuantity(Decimal value) => value.formatQuantity();

/// US33: corregir la cantidad de un repuesto imputado o devolverlo al lote de origen en hoja inferior.
class OrderPartEditSheet extends StatelessWidget {
  final PartEditForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onQuantityChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const OrderPartEditSheet({
    super.key,
    required this.form,
    required this.isSaving,
    required this.invalidField,
    required this.error,
    required this.onQuantityChange,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final returning = form.mode == PartEditMode.returnPart;
    return AtelierBottomSheet(
      title: returning ? strings.returnTitle : strings.editPartTitle,
      actions: [
        AtelierButton(
          text: returning ? strings.returnConfirm : strings.editPartConfirm,
          onClick: onConfirm,
          style: returning ? AtelierButtonStyle.destructiveFilled : AtelierButtonStyle.filled,
          enabled: (returning || form.quantity.trim().isNotEmpty) && !isSaving,
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
          form.product.productName ?? strings.taskPartUnnamed,
          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
        ),
        Text(
          returning ? strings.returnBody : strings.editPartBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (!returning)
          AtelierTextField(
            label: strings.chargeQuantity,
            value: form.quantity,
            onValueChange: onQuantityChange,
            enabled: !isSaving,
            isError: invalidField == 'quantity',
            errorText: invalidField == 'quantity' ? strings.taskFieldQuantity : null,
            keyboardType: _decimalKeyboard,
            textInputAction: TextInputAction.done,
            inputFormatters: _decimalFormatters,
          ),
        _SheetError(error),
      ],
    );
  }
}

/// US33 E2: qué repuestos salieron de qué lote y cuánto volvió. Se pide al abrir la hoja. Sin la hoja de
/// rentabilidad de la orden (US35).
class PartMovementsSheet extends StatelessWidget {
  final OnDemand<List<PartMovement>> state;
  final String? Function(String productId) partName;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const PartMovementsSheet({
    super.key,
    required this.state,
    required this.partName,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final data = state.data;
    final error = state.error;
    return AtelierBottomSheet(
      title: strings.ordersMovementsTitle,
      actions: [
        AtelierButton(
          text: strings.quotationPdfClose,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
        ),
      ],
      content: [
        if (state.isLoading)
          Column(
            spacing: 8,
            children: [
              for (var i = 0; i < 4; i++)
                const AtelierListRow(
                  title: 'Ingresos de repuestos',
                  subtitle: 'Costo de ventas FIFO',
                  loading: true,
                ),
            ],
          )
        else if (error != null) ...[
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
          AtelierButton(
            text: strings.commonRetry,
            onClick: onRetry,
            style: AtelierButtonStyle.outlined,
          ),
        ] else if (data != null && data.isEmpty)
          AtelierEmptyState(text: strings.ordersMovementsEmpty)
        else if (data != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final movement in data)
                AtelierListRow(
                  title: partName(movement.productId) ?? strings.taskPartUnnamed,
                  subtitle: _movementSubtitle(strings, movement),
                ),
            ],
          ),
      ],
    );
  }
}

String _movementSubtitle(AppLocalizations strings, PartMovement movement) {
  final returned = movement.returnedQuantity > Decimal.zero;
  final buffer = StringBuffer(
    strings.ordersMovementDetail(
      movement.chargedQuantity.formatQuantity(),
      movement.returnedQuantity.formatQuantity(),
    ),
  );
  final when = returned ? movement.lastReturnedAt : movement.chargedAt;
  if (when != null) buffer.write(' · ${when.formatLimaDate()}');
  final reason = movement.lastReturnReason;
  if (returned && reason != null && reason.trim().isNotEmpty) buffer.write(' · $reason');
  return buffer.toString();
}
