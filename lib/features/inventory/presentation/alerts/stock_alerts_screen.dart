import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// US34 E1: repuestos en el mínimo o debajo. Tocar uno abre el repuesto. Sin botón falso de resolver (H13); ofrece
/// crear una orden de compra (`PURCHASE_ORDERS_CREATE`). Cuando la compra se recibe, la alerta sale de la lista sin
/// recargar (E2). Requiere `ALERTS_READ`.
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
        onOpenPart: (alert) => AppNavigator.push(context, AppRoute.partDetail, alert.itemId),
        onCreatePurchaseOrder: () => AppNavigator.push(context, AppRoute.purchaseOrders),
      ),
    );
  }
}

class StockAlertsContent extends StatelessWidget {
  final StockAlertsUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<StockAlert> onOpenPart;
  final VoidCallback onCreatePurchaseOrder;

  const StockAlertsContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenPart,
    required this.onCreatePurchaseOrder,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canRead && state.canCreatePurchaseOrder
          ? AtelierFab(
              text: strings.invSeg2AlertsCreatePoFab,
              icon: Icons.shopping_cart_outlined,
              onClick: onCreatePurchaseOrder,
            ).floatingBarPadding()
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.inventoryAlertsTitle, onBack: onBack),
          if (!state.canRead)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.inventoryAlertsNoPermission),
            )
          else ...[
            AtelierRefreshBar(visible: state.isLoading && state.alerts.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: DelayedLoading(
                  loading: state.isLoading && state.alerts.isEmpty,
                  builder: (context, showBones) => _list(context, strings, showBones),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showBones) {
    const side = EdgeInsets.symmetric(horizontal: 16);
    final error = state.error;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: state.canCreatePurchaseOrder ? 96 : 24),
      children: [
        if (!state.isOnline)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AtelierBanner(
              message: strings.inventoryAlertsOffline,
              icon: Icons.info_outline,
              kind: BannerKind.info,
            ),
          ),
        Padding(
          padding: side,
          child: AtelierSectionHeader(
            title: strings.inventoryAlertsHeader,
            count: state.alerts.isEmpty ? null : state.alerts.length,
          ),
        ),
        if (showBones)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(title: 'Filtro de aceite', subtitle: 'SKU FLT-001 · 2 de 6', loading: true)
        else if (state.alerts.isEmpty && error != null)
          Padding(
            padding: side,
            child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
          )
        else if (state.alerts.isEmpty && !state.isLoading)
          Padding(
            padding: side,
            child: AtelierEmptyState(text: strings.inventoryAlertsEmpty),
          )
        else
          for (final alert in state.alerts)
            _AlertRow(key: ValueKey('alert-${alert.itemId}'), alert: alert, onClick: () => onOpenPart(alert)),
      ],
    );
  }
}

/// Fila de una alerta: stock actual contra el mínimo, con barra métrica y marca en el mínimo.
class _AlertRow extends StatelessWidget {
  final StockAlert alert;
  final VoidCallback onClick;

  const _AlertRow({super.key, required this.alert, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final out = alert.currentStock <= Decimal.zero;
    final minimum = alert.minimumStock.toDouble() < 1 ? 1.0 : alert.minimumStock.toDouble();
    final current = alert.currentStock.toDouble() < 0 ? 0.0 : alert.currentStock.toDouble();
    final progress = (current / minimum).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        onClick: onClick,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            AtelierListRow(
              title: alert.name,
              subtitle: strings.inventoryAlertSubtitle(
                alert.sku,
                alert.currentStock.formatQuantity(),
                alert.minimumStock.formatQuantity(),
              ),
              showDivider: false,
              trailing: out
                  ? AtelierChip(text: strings.stockOut, kind: ChipKind.bad)
                  : AtelierChip(
                      text: strings.inventoryAlertMissing(alert.deficit.formatQuantity()),
                      kind: ChipKind.warn,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AtelierMetricBar(
                progress: progress,
                color: out ? colors.badMark : colors.warnMark,
                height: 6,
                markerAt: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
