import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Alertas de stock mínimo (US34): repuestos con existencias en el mínimo o por debajo. Cada fila abre la ficha
/// del repuesto. Cuando la compra se recibe, la alerta sale de la lista sin recargar (E2). Requiere `ALERTS_READ`.
class StockAlertsScreen extends StatefulWidget {
  const StockAlertsScreen({super.key});

  @override
  State<StockAlertsScreen> createState() => _StockAlertsScreenState();
}

class _StockAlertsScreenState extends State<StockAlertsScreen> {
  late final StockAlertsViewModel viewModel = getIt<StockAlertsViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => StockAlertsContent(
        state: viewModel.state,
        onBack: inventoryBack(context),
        onRefresh: viewModel.refresh,
        onOpenPart: (alert) =>
            AppNavigator.push(context, AppRoute.partDetail, alert.itemId),
      ),
    );
  }
}

class StockAlertsContent extends StatelessWidget {
  final StockAlertsUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<StockAlert> onOpenPart;

  const StockAlertsContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenPart,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final outCount = state.alerts
        .where((a) => a.currentStock <= Decimal.zero)
        .length;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AtelierTopBar(title: strings.stockAlertsTitle, onBack: onBack),
            if (!state.canRead)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AtelierNoPermissionState(
                  text: strings.stockAlertsNoPermission,
                ),
              )
            else ...[
              AtelierReportPanel(
                context: strings.stockAlertsContext,
                legend: state.alerts.length.toString(),
                caption: strings.stockAlertsCaption,
                loading: state.isLoading && state.alerts.isEmpty,
                figures: [
                  PanelFigure(
                    value: outCount.toString(),
                    label: strings.stockAlertsOut,
                  ),
                  PanelFigure(
                    value: (state.alerts.length - outCount).toString(),
                    label: strings.stockAlertsLow,
                  ),
                ],
              ),
              AtelierRefreshBar(
                visible: state.isLoading && state.alerts.isNotEmpty,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: DelayedLoading(
                    loading: state.isLoading && state.alerts.isEmpty,
                    builder: (context, showBones) =>
                        _list(context, strings, showBones),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showBones) {
    final error = state.error;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (showBones)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(
              title: 'Pastillas de freno',
              subtitle: 'SKU-0001',
              loading: true,
            )
        else if (state.alerts.isEmpty && !state.isOnline && error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierOfflineState(onRetry: onRefresh),
          )
        else if (state.alerts.isEmpty && error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierErrorState(
              message: error.asString(strings),
              onRetry: onRefresh,
            ),
          )
        else if (state.alerts.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierEmptyState(text: strings.stockAlertsEmpty),
          )
        else
          for (final alert in state.alerts)
            AtelierListRow(
              key: ValueKey('alert-${alert.itemId}'),
              title: alert.name,
              subtitle: _subtitle(strings, alert),
              onClick: () => onOpenPart(alert),
              trailing: AtelierChip(
                text: alert.currentStock <= Decimal.zero
                    ? strings.stockAlertsChipOut
                    : strings.stockAlertsChipLow,
                kind: alert.currentStock <= Decimal.zero
                    ? ChipKind.bad
                    : ChipKind.wait,
              ),
            ),
      ],
    );
  }

  /// `SKU · Frenos` y, debajo en la misma línea, `Stock 1 · mínimo 5 · faltan 4`.
  String _subtitle(AppLocalizations strings, StockAlert alert) {
    final head = [alert.sku, ?alert.category?.label(strings)].join(' · ');
    final detail = strings.stockAlertsDetail(
      alert.currentStock.formatQuantity(),
      alert.minimumStock.formatQuantity(),
      alert.deficit.formatQuantity(),
    );
    return '$head\n$detail';
  }
}
