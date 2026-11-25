import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_forms.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Fila de cifras: rótulo a la izquierda, monto a la derecha. [emphasized] para el total.
class AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const AmountRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.atelier;
    final style = emphasized ? context.text.titleMedium : context.text.bodyLarge;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Text(
              label,
              style: style?.copyWith(color: emphasized ? scheme.onSurface : colors.inkSecondary),
            ),
          ),
          Text(
            value,
            style: style?.copyWith(color: scheme.onSurface),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// Elegir una opción entre pocas, en filas de [columns]: la elegida va en tonal, las demás en contorno.
class ChoiceGrid<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T option) label;
  final ValueChanged<T> onSelect;
  final int columns;
  final bool enabled;

  const ChoiceGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.label,
    required this.onSelect,
    this.columns = 3,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<T>>[];
    for (var i = 0; i < options.length; i += columns) {
      final end = i + columns > options.length ? options.length : i + columns;
      rows.add(options.sublist(i, end));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final row in rows)
          Row(
            spacing: 8,
            children: [
              for (final option in row)
                Expanded(
                  child: Semantics(
                    selected: option == selected,
                    child: AtelierButton(
                      text: label(option),
                      onClick: () => onSelect(option),
                      style: option == selected
                          ? AtelierButtonStyle.tonal
                          : AtelierButtonStyle.outlined,
                      enabled: enabled,
                    ),
                  ),
                ),
              for (var pad = row.length; pad < columns; pad++) const Spacer(),
            ],
          ),
      ],
    );
  }
}

/// Contenido reutilizable de la hoja de anulación de comprobante.
class VoidSheetContent extends StatelessWidget {
  final VoidForm form;
  final ValueChanged<String> onReasonChange;
  final String? error;

  const VoidSheetContent({
    super.key,
    required this.form,
    required this.onReasonChange,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final reasonTooLong = form.reason.trim().length > 250;
    final hasError = (form.reason.isNotEmpty && !form.reasonValid) || reasonTooLong;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          strings.cashierVoidBody,
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: strings.cashierVoidReasonLabel,
          value: form.reason,
          onValueChange: onReasonChange,
          placeholder: strings.cashierVoidReasonPlaceholder,
          isError: hasError,
          errorText: hasError ? strings.cashierVoidReasonError : null,
        ),
        if (error != null)
          AtelierBanner(message: error!, icon: Icons.error_outline),
      ],
    );
  }
}

/// Contenido reutilizable de la hoja de emisión de nota de crédito.
class CreditNoteSheetContent extends StatelessWidget {
  final CreditNoteForm form;
  final ValueChanged<String> onReasonChange;
  final ValueChanged<String> onAmountChange;
  final ValueChanged<String>? onSerieChange;
  final String? error;

  const CreditNoteSheetContent({
    super.key,
    required this.form,
    required this.onReasonChange,
    required this.onAmountChange,
    this.onSerieChange,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final amountInvalid = form.amount.trim().isNotEmpty && form.parsedAmount == null;
    final reasonInvalid = form.reason.isNotEmpty && !form.reasonValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          strings.cashierNcReference(form.referenceLabel),
          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
        ),
        if (form.availableSeries.length > 1 && onSerieChange != null) ...[
          Text(
            strings.cashierNcSerieLabel,
            style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
          ),
          ChoiceGrid<String>(
            options: [for (final s in form.availableSeries) s.serie],
            selected: form.selectedSerie.trim().isEmpty
                ? form.availableSeries.first.serie
                : form.selectedSerie,
            label: (serie) => serie,
            onSelect: onSerieChange!,
          ),
        ],
        AtelierTextField(
          label: strings.cashierNcReasonLabel,
          value: form.reason,
          onValueChange: onReasonChange,
          placeholder: strings.cashierNcReasonPlaceholder,
          isError: reasonInvalid,
          errorText: reasonInvalid ? strings.cashierNcReasonError : null,
        ),
        AtelierTextField(
          label: strings.cashierNcAmountLabel,
          value: form.amount,
          onValueChange: onAmountChange,
          isError: amountInvalid,
          errorText: amountInvalid ? strings.cashierNcAmountError : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        Text(
          strings.cashierNcIrreversible,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (error != null)
          AtelierBanner(message: error!, icon: Icons.error_outline),
      ],
    );
  }
}
