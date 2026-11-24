import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/date_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US34 E2: órdenes de compra por estado y alta de borrador (`PURCHASE_ORDERS_CREATE`). Requiere
/// `PURCHASE_ORDERS_READ`. Es la raíz de la pestaña Compras. La recepción (US34) no está en esta versión.
class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  late final PurchaseOrdersViewModel viewModel = getIt<PurchaseOrdersViewModel>();
  int _lastHaptic = 0;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onState);
  }

  void _onState() {
    final state = viewModel.state;
    final createdId = state.createdOrderId;
    if (createdId != null) {
      viewModel.onCreatedOrderNavigated();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppNavigator.push(context, AppRoute.purchaseOrderDetail, createdId);
      });
    }
    if (state.hapticEvent != _lastHaptic) {
      _lastHaptic = state.hapticEvent;
      if (state.hapticEvent > 0) {
        final haptics = rememberAtelierHaptics();
        state.hapticIsError ? haptics.reject() : haptics.confirm();
      }
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_onState);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<bool>(
      listenable: viewModel,
      value: () => viewModel.state.createSheetOpen ? true : null,
      onDismiss: viewModel.onDismissCreateSheet,
      sheetBuilder: (context, _) => CreatePurchaseOrderSheetContent(
        state: viewModel.state,
        onDismiss: () => Navigator.of(context).maybePop(),
        onSelectSupplier: viewModel.onSelectSupplier,
        onPartQueryChange: viewModel.onPartQueryChange,
        onToggleLowStockOnly: viewModel.onToggleLowStockOnly,
        onSelectPart: viewModel.onSelectPart,
        onLineQuantityChange: viewModel.onLineQuantityChange,
        onLineUnitCostChange: viewModel.onLineUnitCostChange,
        onOrderNumberChange: viewModel.onOrderNumberChange,
        onNotesChange: viewModel.onNotesChange,
        onConfirm: viewModel.onCreateOrder,
        onConfirmLowStock: viewModel.onCreateLowStockOrder,
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => PurchaseOrdersContent(
          state: viewModel.state,
          onBack: inventoryBack(context),
          onStatusClick: viewModel.onStatusClick,
          onRefresh: viewModel.refresh,
          onOpenOrder: (id) => AppNavigator.push(context, AppRoute.purchaseOrderDetail, id),
          onOpenCreateSheet: viewModel.onOpenCreateSheet,
        ),
      ),
    );
  }
}

const _statusFilters = <PurchaseOrderStatus?>[
  PurchaseOrderStatus.draft,
  PurchaseOrderStatus.issued,
  PurchaseOrderStatus.received,
  PurchaseOrderStatus.canceled,
  null,
];

String _statusFilterLabel(AppLocalizations s, PurchaseOrderStatus? status) => switch (status) {
  PurchaseOrderStatus.draft => s.invSeg2PoFilterDraft,
  PurchaseOrderStatus.issued => s.inventoryPoFilterIssued,
  PurchaseOrderStatus.received => s.inventoryPoFilterReceived,
  PurchaseOrderStatus.canceled => s.invSeg2PoFilterCanceled,
  null => s.inventoryPoFilterAll,
};

class PurchaseOrdersContent extends StatelessWidget {
  final PurchaseOrdersUiState state;
  final VoidCallback onBack;
  final ValueChanged<PurchaseOrderStatus?> onStatusClick;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onOpenOrder;
  final VoidCallback onOpenCreateSheet;

  const PurchaseOrdersContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onStatusClick,
    required this.onRefresh,
    required this.onOpenOrder,
    required this.onOpenCreateSheet,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canRead && state.canCreate
          ? AtelierFab(
              text: strings.invSeg2PoNewFab,
              icon: Icons.add,
              onClick: onOpenCreateSheet,
            ).floatingBarPadding()
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.inventoryPoTitle, onBack: onBack),
          if (!state.canRead)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.inventoryPoNoPermission),
            )
          else ...[
            AtelierRefreshBar(visible: state.isLoading && state.orders.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: DelayedLoading(
                  loading: state.orders.isEmpty && state.isLoading,
                  builder: (context, showSkeleton) => _list(context, strings, showSkeleton),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final error = state.error;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: (state.canCreate ? 96 : 24) + FloatingBarInset.of(context)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: AtelierSegmentedControl<PurchaseOrderStatus?>(
            options: _statusFilters,
            selected: state.status,
            onSelect: onStatusClick,
            label: (status) => _statusFilterLabel(strings, status),
          ),
        ),
        if (showSkeleton)
          for (var i = 0; i < 4; i++)
            const AtelierListRow(
              title: 'Orden OC-0001',
              subtitle: '3 líneas · S/ 1,250.00',
              loading: true,
            )
        else if (state.orders.isEmpty && error != null && !state.isOnline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierOfflineState(onRetry: onRefresh),
          )
        else if (state.orders.isEmpty && error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
          )
        else if (state.orders.isEmpty && !state.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierEmptyState(text: strings.inventoryPoEmpty),
          )
        else
          for (final order in state.orders)
            _OrderRow(key: ValueKey(order.id), order: order, onClick: () => onOpenOrder(order.id)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final PurchaseOrder order;
  final VoidCallback onClick;

  const _OrderRow({super.key, required this.order, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final number = order.orderNumber;
    final receivedAt = order.receivedAt;
    final total = order.totalCost;
    return AtelierListRow(
      title: number != null ? strings.inventoryPoNumber(number) : strings.inventoryPoNoNumber,
      subtitle: [
        strings.inventoryPoLines(order.lines.length),
        if (total != null) total.format(),
        if (receivedAt != null) strings.inventoryPoReceivedOn(receivedAt.formatLimaDate()),
      ].join(' · '),
      onClick: onClick,
      trailing: AtelierChip(text: order.status.label(strings), kind: order.status.chipKind),
    );
  }
}

class CreatePurchaseOrderSheetContent extends StatelessWidget {
  final PurchaseOrdersUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onSelectSupplier;
  final ValueChanged<String> onPartQueryChange;
  final VoidCallback onToggleLowStockOnly;
  final ValueChanged<Part> onSelectPart;
  final ValueChanged<String> onLineQuantityChange;
  final ValueChanged<String> onLineUnitCostChange;
  final ValueChanged<String> onOrderNumberChange;
  final ValueChanged<String> onNotesChange;
  final VoidCallback onConfirm;
  final VoidCallback onConfirmLowStock;

  const CreatePurchaseOrderSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onSelectSupplier,
    required this.onPartQueryChange,
    required this.onToggleLowStockOnly,
    required this.onSelectPart,
    required this.onLineQuantityChange,
    required this.onLineUnitCostChange,
    required this.onOrderNumberChange,
    required this.onNotesChange,
    required this.onConfirm,
    required this.onConfirmLowStock,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final enabled = !state.isCreating;
    final labelStyle = context.text.titleSmall?.copyWith(color: colors.inkSecondary);
    final lowStockParts = state.lowStockParts;
    final filtered = state.filteredCatalogParts;
    final suppliersError = state.suppliersError;
    return AtelierBottomSheet(
      title: strings.invSeg2PoCreateTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.invSeg2PoCreateConfirm,
          onClick: onConfirm,
          enabled:
              state.isOnline &&
              state.selectedSupplierId != null &&
              state.selectedPartId != null &&
              !state.isCreating,
          loading: state.isCreating,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: enabled,
        ),
      ],
      content: [
        Text(strings.invSeg2PoSelectSupplier, style: labelStyle),
        if (state.isLoadingSuppliers)
          const LinearProgressIndicator()
        else if (suppliersError != null)
          AtelierBanner(message: suppliersError.asString(strings), icon: Icons.error_outline)
        else if (state.suppliers.isEmpty)
          AtelierBanner(
            message: strings.invSeg2PoNoSuppliers,
            icon: Icons.error_outline,
            kind: BannerKind.wait,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final supplier in state.suppliers)
                FilterChip(
                  selected: state.selectedSupplierId == supplier.id,
                  onSelected: enabled ? (_) => onSelectSupplier(supplier.id) : null,
                  label: Text(supplier.businessName),
                  shape: controlShape,
                ),
            ],
          ),
        if (lowStockParts.isNotEmpty && state.suppliers.isNotEmpty) ...[
          AtelierButton(
            text: strings.invSeg2PoGenerateLowStockBtn(lowStockParts.length),
            onClick: onConfirmLowStock,
            style: AtelierButtonStyle.outlined,
            icon: Icons.warning_amber_outlined,
            enabled: state.isOnline && state.selectedSupplierId != null && !state.isCreating,
            loading: state.isCreating,
          ),
          Text(
            strings.invSeg2PoGenerateLowStockHint,
            style: context.text.labelSmall?.copyWith(color: colors.inkSecondary),
          ),
        ],
        Text(strings.invSeg2PoInitialLineTitle, style: labelStyle),
        if (state.catalogParts.isEmpty)
          AtelierBanner(
            message: strings.invSeg2PoNoParts,
            icon: Icons.error_outline,
            kind: BannerKind.wait,
          )
        else ...[
          AtelierTextField(
            label: strings.invSeg2PoSelectPart,
            value: state.partQuery,
            onValueChange: onPartQueryChange,
            leadingIcon: Icons.search,
            placeholder: strings.invSeg2PoPartSearchHint,
            enabled: enabled,
          ),
          if (lowStockParts.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                selected: state.lowStockOnly,
                onSelected: enabled ? (_) => onToggleLowStockOnly() : null,
                label: Text(strings.invSeg2PoLowStockOnly(lowStockParts.length)),
                avatar: Icon(Icons.warning_amber_outlined, size: 16, color: colors.wait),
                selectedColor: colors.waitContainer,
                labelStyle: TextStyle(color: state.lowStockOnly ? colors.wait : null),
                shape: controlShape,
              ),
            ),
          if (filtered.isEmpty)
            Text(
              strings.invSeg2PoLowStockEmpty,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final part in filtered)
                  PurchaseOrderPartChip(
                    part: part,
                    selected: state.selectedPartId == part.id,
                    enabled: enabled,
                    onClick: () => onSelectPart(part),
                  ),
              ],
            ),
          AtelierTextField(
            label: strings.invSeg2BatchQuantityLabel,
            value: state.lineQuantity,
            onValueChange: onLineQuantityChange,
            isError: state.lineQtyError != null,
            errorText: state.lineQtyError?.asString(strings),
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          AtelierTextField(
            label: strings.invSeg2BatchUnitCostLabel,
            value: state.lineUnitCost,
            onValueChange: onLineUnitCostChange,
            isError: state.lineCostError != null,
            errorText: state.lineCostError?.asString(strings),
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
        AtelierTextField(
          label: strings.invSeg2PoNumberOptional,
          value: state.orderNumber,
          onValueChange: onOrderNumberChange,
          enabled: enabled,
        ),
        AtelierTextField(
          label: strings.invSeg2PoNotesOptional,
          value: state.notes,
          onValueChange: onNotesChange,
          enabled: enabled,
        ),
        if (state.createError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

/// Chip de repuesto de la orden: los agotados y los de stock mínimo se tiñen de rojo y ámbar y llevan aviso.
class PurchaseOrderPartChip extends StatelessWidget {
  final Part part;
  final bool selected;
  final bool enabled;
  final VoidCallback onClick;

  const PurchaseOrderPartChip({
    super.key,
    required this.part,
    required this.selected,
    required this.enabled,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final stockText = plainQuantity(part.totalStock);
    final minText = plainQuantity(part.minimumStock);
    final label = part.isOutOfStock
        ? strings.invSeg2PoPartChipOutOfStock(part.name, part.sku, minText)
        : part.isLowStock
        ? strings.invSeg2PoPartChipLowStock(part.name, part.sku, stockText, minText)
        : '${part.name} (${part.sku})';
    final tintInk = part.isOutOfStock ? colors.bad : colors.wait;
    final tintBg = part.isOutOfStock ? colors.badContainer : colors.waitContainer;
    return FilterChip(
      selected: selected,
      onSelected: enabled ? (_) => onClick() : null,
      label: Text(label),
      avatar: part.isLowStock ? Icon(Icons.warning_amber_outlined, size: 16, color: tintInk) : null,
      backgroundColor: part.isLowStock ? tintBg : null,
      labelStyle: part.isLowStock && !selected ? TextStyle(color: tintInk) : null,
      selectedColor: part.isLowStock ? context.scheme.primaryContainer : null,
      side: part.isLowStock && !selected ? BorderSide(color: tintInk.withValues(alpha: 0.55)) : null,
      shape: controlShape,
    );
  }
}
