import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// Valorización del inventario: una cifra en soles y las existencias por categoría. Requiere `BATCHES_READ`.
class InventoryValuationScreen extends StatefulWidget {
  const InventoryValuationScreen({super.key});

  @override
  State<InventoryValuationScreen> createState() => _InventoryValuationScreenState();
}

class _InventoryValuationScreenState extends State<InventoryValuationScreen> {
  late final InventoryValuationViewModel viewModel = getIt<InventoryValuationViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => InventoryValuationContent(
        state: viewModel.state,
        onBack: inventoryBack(context),
        onRefresh: viewModel.refresh,
      ),
    );
  }
}

class InventoryValuationContent extends StatelessWidget {
  final InventoryValuationUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const InventoryValuationContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AtelierTopBar(title: strings.inventoryValuationTitle, onBack: onBack),
            if (!state.canRead)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AtelierNoPermissionState(text: strings.inventoryValuationNoPermission),
              )
            else ...[
              AtelierReportPanel(
                context: strings.inventoryValuationContext,
                legend: state.valuation?.format() ?? 'S/ 00,000.00',
                caption: strings.inventoryValuationCaption,
                loading: state.valuation == null && state.isLoading,
                figures: [
                  PanelFigure(value: state.withStockCount.toString(), label: strings.inventoryValuationWithStock),
                  PanelFigure(value: state.lowStockCount.toString(), label: strings.inventoryValuationLow),
                  PanelFigure(value: state.outOfStockCount.toString(), label: strings.inventoryValuationOut),
                ],
              ),
              AtelierRefreshBar(visible: state.isLoading && state.valuation != null),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: DelayedLoading(
                    loading: state.isLoading && state.parts.isEmpty,
                    builder: (context, showBones) => _list(context, strings, showBones),
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
    final valuation = state.valuation;
    final error = state.error;
    final byCategory = state.byCategory;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (valuation == null && !state.isOnline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierOfflineState(onRetry: onRefresh),
          )
        else if (valuation == null && error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
          ),
        if (state.parts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
            child: _InventoryHealthCard(state: state),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: AtelierSectionHeader(title: strings.inventoryValuationByCategory),
        ),
        if (showBones)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(title: 'Frenos', subtitle: '8 repuestos', loading: true)
        else if (byCategory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierEmptyState(text: strings.inventoryValuationEmpty),
          )
        else
          for (final row in byCategory)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
              child: _CategoryValuationCard(
                row: row,
                categoryParts: [
                  for (final part in state.parts)
                    if (part.totalStock > Decimal.zero && part.category == row.category) part,
                ],
              ),
            ),
      ],
    );
  }
}

class _InventoryHealthCard extends StatelessWidget {
  final InventoryValuationUiState state;

  const _InventoryHealthCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final totalParts = state.parts.isEmpty ? 1 : state.parts.length;
    final healthyCount = (state.withStockCount - state.lowStockCount).clamp(0, 1 << 30);
    final progress = (state.withStockCount / totalParts).clamp(0.0, 1.0);
    final markerAt = state.lowStockCount > 0 || state.outOfStockCount > 0
        ? (healthyCount / totalParts).clamp(0.08, 0.92)
        : null;
    final barColor = state.outOfStockCount > healthyCount
        ? colors.badMark
        : state.lowStockCount > 0 || state.outOfStockCount > 0
        ? colors.warnMark
        : colors.okMark;
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: heroShape,
      contentPadding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.premiumValuationHealthTitle,
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
              Text(
                '${state.withStockCount}/${state.parts.length}',
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ],
          ),
          AtelierMetricBar(progress: progress, color: barColor, height: 8, markerAt: markerAt),
          Text(
            strings.premiumValuationHealthSummary(
              state.withStockCount,
              state.lowStockCount,
              state.outOfStockCount,
            ),
            style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

class _CategoryValuationCard extends StatelessWidget {
  final CategoryStock row;
  final List<Part> categoryParts;

  const _CategoryValuationCard({required this.row, required this.categoryParts});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final totalUnits = row.units.toDouble().clamp(0.0, double.infinity);
    final minDecimal = categoryParts.fold(Decimal.zero, (acc, part) => acc + part.minimumStock);
    final minUnits = minDecimal.toDouble().clamp(0.0, double.infinity);
    final scaleMax = [minUnits * 2, totalUnits * 1.15, 1.0].reduce((a, b) => a > b ? a : b);
    final progress = (totalUnits / scaleMax).clamp(0.0, 1.0);
    final markerAt = minUnits > 0 ? (minUnits / scaleMax).clamp(0.08, 0.92) : null;
    final hasOutOfStock = categoryParts.any((p) => p.isOutOfStock);
    final hasLowStock = categoryParts.any((p) => p.isLowStock);
    final barColor = totalUnits <= 0 || hasOutOfStock
        ? colors.badMark
        : totalUnits <= minUnits || hasLowStock
        ? colors.warnMark
        : colors.okMark;
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Row(
            spacing: Spacing.sm,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      row.category?.label(strings) ?? strings.inventoryValuationUncategorized,
                      style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                    ),
                    Text(
                      strings.inventoryValuationParts(row.partCount),
                      style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                strings.inventoryValuationUnits(row.units.formatQuantity()),
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ],
          ),
          AtelierMetricBar(progress: progress, color: barColor, height: 6, markerAt: markerAt),
          if (minUnits > 0)
            Text(
              strings.premiumValuationCategoryMin(minDecimal.formatQuantity()),
              style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
            ),
        ],
      ),
    );
  }
}
