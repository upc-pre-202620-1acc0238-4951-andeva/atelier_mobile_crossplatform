import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const _maxResults = 6;

/// US32 E2: hoja inferior para buscar un repuesto, elegirlo (bloqueando agotados, US31 E3) y fijar la cantidad.
/// Si pide más de lo disponible, el backend responde 409 y su `message` se muestra dentro de la hoja (E3).
class ChargePartSheet extends StatelessWidget {
  final ChargeForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<PartOption> onSelect;
  final ValueChanged<String> onQuantityChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const ChargePartSheet({
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
    final selected = form.selected;
    final error = this.error;
    return AtelierBottomSheet(
      title: strings.chargeTitle,
      actions: [
        AtelierButton(
          text: strings.chargeConfirm,
          onClick: onConfirm,
          minHeight: 56,
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
              style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
            )
          else if (form.results.isEmpty)
            Text(
              strings.catalogEmptyFiltered,
              style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                for (final part in form.results.take(_maxResults))
                  PartOptionRow(part: part, onSelect: onSelect, enabled: !isSaving),
              ],
            ),
        ] else ...[
          PartOptionRow(part: selected, onSelect: (_) {}, enabled: false, selected: true),
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
          ),
        ],
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class PartOptionRow extends StatelessWidget {
  final PartOption part;
  final ValueChanged<PartOption> onSelect;
  final bool enabled;
  final bool selected;

  const PartOptionRow({
    super.key,
    required this.part,
    required this.onSelect,
    required this.enabled,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final stockText = part.isAvailable
        ? strings.partStock(part.totalStock.formatQuantity())
        : strings.stockOut;
    final basePrice = part.basePrice;
    final priceFormatted = basePrice == null
        ? null
        : strings.partPrice(Money(amount: basePrice, currency: Money.pen).format());
    return AtelierSelectionCard(
      title: part.name,
      subtitle: stockText,
      price: priceFormatted,
      badgeText: part.isAvailable ? null : strings.stockOut,
      badgeColor: part.isAvailable ? null : context.atelier.badContainer,
      selected: selected,
      enabled: enabled && part.isAvailable,
      onClick: () => onSelect(part),
    );
  }
}

/// US33: hoja inferior para corregir la cantidad de un repuesto imputado o devolverlo al lote de origen.
class PartEditSheet extends StatelessWidget {
  final PartEditForm form;
  final bool isSaving;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onQuantityChange;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const PartEditSheet({
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
    final error = this.error;
    return AtelierBottomSheet(
      title: returning ? strings.returnTitle : strings.editPartTitle,
      actions: [
        AtelierButton(
          text: returning ? strings.returnConfirm : strings.editPartConfirm,
          onClick: onConfirm,
          style: returning ? AtelierButtonStyle.destructiveFilled : AtelierButtonStyle.filled,
          minHeight: 56,
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
          ),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
