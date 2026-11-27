import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/profitability/profitability_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Fila "Rentabilidad" de la ficha de una orden (US35 E2). Se muestra con `inventory:batches:read` o
/// `invoicing:cashflow:export_pdf`; al tocarla se abre la hoja y el cálculo se pide entonces, solo en línea.
/// [partNames] son los nombres ya cargados por la ficha.
class WorkOrderProfitabilityCard extends StatefulWidget {
  final String workOrderId;
  final Map<String, String> partNames;
  final bool isOnline;

  const WorkOrderProfitabilityCard({
    super.key,
    required this.workOrderId,
    this.partNames = const {},
    required this.isOnline,
  });

  @override
  State<WorkOrderProfitabilityCard> createState() => _WorkOrderProfitabilityCardState();
}

class _WorkOrderProfitabilityCardState extends State<WorkOrderProfitabilityCard> {
  late final ProfitabilityViewModel viewModel = getIt<ProfitabilityViewModel>(param1: widget.workOrderId);

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _open() {
    viewModel.load();
    showAtelierSheetBuilder<void>(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ProfitabilitySheet(
          state: viewModel.state,
          partNames: widget.partNames,
          onRetry: viewModel.load,
          onDismiss: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        child: AtelierListRow(
          title: strings.ordersProfitabilityTitle,
          subtitle: strings.ordersProfitabilityHint,
          showDivider: false,
          onClick: widget.isOnline ? _open : null,
          trailing: Icon(Icons.keyboard_arrow_right_outlined, color: context.atelier.inkSecondary),
        ),
      ),
    );
  }
}

/// Hoja de rentabilidad (US35 E2): ingreso de repuestos contra su costo de ventas FIFO y el desglose por repuesto.
class ProfitabilitySheet extends StatelessWidget {
  final ProfitabilityUiState state;
  final Map<String, String> partNames;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const ProfitabilitySheet({
    super.key,
    required this.state,
    this.partNames = const {},
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final result = state.profitability;
    final error = state.error;
    return AtelierBottomSheet(
      title: strings.ordersProfitabilityTitle,
      actions: [
        AtelierButton(text: strings.quotationPdfClose, onClick: onDismiss, style: AtelierButtonStyle.text),
      ],
      content: [
        if (state.isLoading && result == null)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(title: 'Ingresos de repuestos', subtitle: 'Costo de ventas FIFO', loading: true)
        else if (error != null && result == null) ...[
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
          AtelierButton(text: strings.commonRetry, onClick: onRetry, style: AtelierButtonStyle.outlined),
        ] else if (result != null)
          ..._summary(context, strings, result),
      ],
    );
  }

  List<Widget> _summary(BuildContext context, AppLocalizations strings, Profitability result) {
    final currency = result.currency;
    Widget row(String label, Decimal? value, {bool emphasized = false}) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: (emphasized ? context.text.titleMedium : context.text.bodyLarge)?.copyWith(
              color: emphasized ? context.scheme.onSurface : context.atelier.inkSecondary,
            ),
          ),
        ),
        Text(
          profitabilityAmount(value, currency),
          style: (emphasized ? context.text.titleMedium : context.text.bodyLarge)?.copyWith(
            color: context.scheme.onSurface,
          ),
        ),
      ],
    );
    return [
      row(strings.ordersProfitLaborRevenue, result.laborRevenue),
      row(strings.ordersProfitPartsRevenue, result.partsRevenue),
      row(strings.ordersProfitCostOfSales, result.partsCostOfSales),
      Divider(color: context.scheme.outlineVariant, height: 1),
      row(strings.ordersProfitPartsGross, result.partsGrossProfit, emphasized: true),
      row(strings.ordersProfitSubtotal, result.subtotal),
      if (result.lines.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Semantics(
            header: true,
            child: Text(
              strings.ordersProfitLines,
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            ),
          ),
        ),
        for (final line in result.lines)
          AtelierListRow(
            title: partNames[line.productId] ?? strings.taskPartUnnamed,
            subtitle: strings.ordersProfitLineDetail(
              line.quantity.formatQuantity(),
              profitabilityAmount(line.costOfSales, currency),
            ),
            trailing: Text(
              profitabilityAmount(line.grossProfit, currency),
              maxLines: 1,
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            ),
          ),
      ],
    ];
  }
}

/// `S/ 19.00`, `−S/ 4.50` si la ganancia es negativa (la ganancia puede perder dinero) o `—` si falta el dato.
String profitabilityAmount(Decimal? amount, String? currency) {
  if (amount == null) return '—';
  final symbol = currency == 'USD' ? 'US\$' : 'S/';
  final text = '$symbol ${amount.abs().formatAmount()}';
  return amount < Decimal.zero ? '−$text' : text;
}
