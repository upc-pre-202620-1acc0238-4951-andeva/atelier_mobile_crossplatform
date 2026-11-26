import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
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

/// Tarjeta "Rentabilidad" de la ficha de una orden (US35 E2): ingreso de repuestos, costo de ventas FIFO y ganancia
/// bruta, con el desglose por línea. Se muestra con `inventory:batches:read` o `invoicing:cashflow:export_pdf`; el
/// cálculo se pide a demanda y solo en línea. [partNames] son los nombres ya cargados por la ficha.
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
  State<WorkOrderProfitabilityCard> createState() =>
      _WorkOrderProfitabilityCardState();
}

class _WorkOrderProfitabilityCardState
    extends State<WorkOrderProfitabilityCard> {
  late final ProfitabilityViewModel viewModel = getIt<ProfitabilityViewModel>(
    param1: widget.workOrderId,
  );

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ProfitabilityCardContent(
        state: viewModel.state,
        partNames: widget.partNames,
        isOnline: widget.isOnline,
        onLoad: viewModel.load,
      ),
    );
  }
}

class ProfitabilityCardContent extends StatelessWidget {
  final ProfitabilityUiState state;
  final Map<String, String> partNames;
  final bool isOnline;
  final VoidCallback onLoad;

  const ProfitabilityCardContent({
    super.key,
    required this.state,
    this.partNames = const {},
    required this.isOnline,
    required this.onLoad,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final result = state.profitability;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(
              strings.profitabilityTitle,
              style: context.text.titleMedium?.copyWith(
                color: context.scheme.onSurface,
              ),
            ),
            Text(
              strings.profitabilityHint,
              style: context.text.bodySmall?.copyWith(
                color: colors.inkSecondary,
              ),
            ),
            if (state.error case final err?)
              AtelierBanner(
                message: err.asString(strings),
                icon: Icons.error_outline,
              ),
            if (result != null) ..._figures(context, strings, result),
            AtelierButton(
              text: result == null
                  ? strings.profitabilityCalculate
                  : strings.profitabilityRefresh,
              onClick: onLoad,
              style: AtelierButtonStyle.outlined,
              icon: Icons.calculate_outlined,
              enabled: isOnline && !state.isLoading,
              loading: state.isLoading,
            ),
            if (!isOnline)
              Text(
                strings.profitabilityNeedsConnection,
                style: context.text.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _figures(
    BuildContext context,
    AppLocalizations strings,
    Profitability result,
  ) {
    final colors = context.atelier;
    final currency = result.currency;
    final profit = result.partsGrossProfit;
    final profitColor = profit == null
        ? context.scheme.onSurface
        : profit < Decimal.zero
        ? colors.bad
        : colors.ok;
    Widget row(
      String title,
      String value, {
      Color? color,
      bool divider = true,
    }) => AtelierListRow(
      title: title,
      showDivider: divider,
      trailing: Text(
        value,
        style: context.text.titleMedium?.copyWith(
          color: color ?? context.scheme.onSurface,
        ),
      ),
    );
    return [
      row(
        strings.profitabilityRevenue,
        profitabilityAmount(result.partsRevenue, currency),
      ),
      row(
        strings.profitabilityCost,
        profitabilityAmount(result.partsCostOfSales, currency),
      ),
      row(
        strings.profitabilityGross,
        profitabilityAmount(profit, currency),
        color: profitColor,
        divider: result.laborRevenue != null || result.lines.isNotEmpty,
      ),
      if (result.laborRevenue != null)
        row(
          strings.profitabilityLabor,
          profitabilityAmount(result.laborRevenue, currency),
          divider: result.lines.isNotEmpty,
        ),
      if (result.lines.isNotEmpty) ...[
        Text(
          strings.profitabilityLines,
          style: context.text.labelLarge?.copyWith(color: colors.inkSecondary),
        ),
        for (var i = 0; i < result.lines.length; i++)
          _line(
            context,
            strings,
            result.lines[i],
            currency,
            divider: i < result.lines.length - 1,
          ),
      ],
      Text(
        strings.profitabilityNoTax,
        style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
      ),
    ];
  }

  Widget _line(
    BuildContext context,
    AppLocalizations strings,
    PartProfitability line,
    String? currency, {
    required bool divider,
  }) {
    final colors = context.atelier;
    final profit = line.grossProfit;
    return AtelierListRow(
      title: partNames[line.productId] ?? strings.profitabilityLineUnknown,
      subtitle: strings.profitabilityLineDetail(
        line.quantity.formatQuantity(),
        profitabilityAmount(line.revenue, currency),
        profitabilityAmount(line.costOfSales, currency),
      ),
      showDivider: divider,
      trailing: Text(
        profitabilityAmount(profit, currency),
        style: context.text.titleMedium?.copyWith(
          color: profit != null && profit < Decimal.zero
              ? colors.bad
              : context.scheme.onSurface,
        ),
      ),
    );
  }
}

/// `S/ 19.00`, `−S/ 4.50` si la ganancia es negativa (la ganancia puede perder dinero) o `—` si falta el dato.
String profitabilityAmount(Decimal? amount, String? currency) {
  if (amount == null) return '—';
  final symbol = currency == 'USD' ? 'US\$' : 'S/';
  final text = '$symbol ${amount.abs().formatAmount()}';
  return amount < Decimal.zero ? '−$text' : text;
}
