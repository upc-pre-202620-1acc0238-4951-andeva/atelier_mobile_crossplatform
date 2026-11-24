import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
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
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_screen.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Orden de compra con su ciclo: agregar líneas (`DRAFT`), emitir (`ISSUED`) y anular (`CANCELED`).
/// Requiere `PURCHASE_ORDERS_READ`. La recepción con comprobante fotográfico (US34) no está en esta versión.
class PurchaseOrderDetailScreen extends StatefulWidget {
  final String orderId;

  const PurchaseOrderDetailScreen({super.key, required this.orderId});

  @override
  State<PurchaseOrderDetailScreen> createState() => _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  late final PurchaseOrderDetailViewModel viewModel = getIt<PurchaseOrderDetailViewModel>(
    param1: widget.orderId,
  );
  int _lastHaptic = 0;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_haptics);
  }

  void _haptics() {
    final state = viewModel.state;
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
    viewModel.removeListener(_haptics);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return StateSheetHost<bool>(
      listenable: vm,
      value: () => vm.state.showAddLineSheet ? true : null,
      onDismiss: vm.onDismissAddLine,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) => _AddLineSheet(
          state: vm.state,
          onDismiss: vm.onDismissAddLine,
          onPartQueryChange: vm.onPartQueryChange,
          onSelectPart: vm.onSelectPart,
          onQuantityChange: vm.onLineQuantityChange,
          onUnitCostChange: vm.onLineUnitCostChange,
          onConfirm: vm.onConfirmAddLine,
        ),
      ),
      child: StateSheetHost<bool>(
        listenable: vm,
        value: () => vm.state.showCancelSheet ? true : null,
        onDismiss: vm.onDismissCancel,
        sheetBuilder: (context, _) => ListenableBuilder(
          listenable: vm,
          builder: (context, _) => _CancelOrderSheet(
            state: vm.state,
            onDismiss: vm.onDismissCancel,
            onReasonChange: vm.onCancelReasonChange,
            onConfirm: vm.onConfirmCancel,
          ),
        ),
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => PurchaseOrderDetailContent(
            state: vm.state,
            onBack: inventoryBack(context),
            onRefresh: vm.refresh,
            onOpenAddLine: vm.onOpenAddLine,
            onIssueOrder: vm.onIssueOrder,
            onOpenCancel: vm.onOpenCancel,
          ),
        ),
      ),
    );
  }
}

class PurchaseOrderDetailContent extends StatelessWidget {
  final PurchaseOrderDetailUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAddLine;
  final VoidCallback onIssueOrder;
  final VoidCallback onOpenCancel;

  const PurchaseOrderDetailContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenAddLine,
    required this.onIssueOrder,
    required this.onOpenCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final order = state.order;
    final status = order?.status;
    return Scaffold(
      body: Column(
        children: [
          AtelierFichaPanel(
            onBack: onBack,
            title: order?.orderNumber != null
                ? strings.inventoryPoNumber(order!.orderNumber!)
                : strings.inventoryPoDetailTitle,
            subtitle: order?.totalCost?.format(),
            status: order == null
                ? null
                : AtelierChip(text: status.label(strings), kind: status.chipKind),
          ),
          if (!state.canRead)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AtelierNoPermissionState(text: strings.inventoryPoNoPermission),
              ),
            )
          else
            Expanded(
              child: DelayedLoading(
                loading: order == null && state.isLoading,
                builder: (context, showSkeleton) => Column(
                  children: [
                    AtelierRefreshBar(visible: state.isLoading && order != null),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: onRefresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 96),
                          children: [
                            if (state.actionBanner case final banner?)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: AtelierBanner(
                                  message: banner.asString(strings),
                                  icon: Icons.check_circle_outline,
                                  kind: BannerKind.ok,
                                ),
                              ),
                            if (state.actionError case final err?)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: AtelierBanner(
                                  message: err.asString(strings),
                                  icon: Icons.error_outline,
                                ),
                              ),
                            if (showSkeleton)
                              for (var i = 0; i < 3; i++)
                                const AtelierListRow(
                                  title: 'Filtro de aceite',
                                  subtitle: '4 × S/ 52.00',
                                  loading: true,
                                )
                            else if (order == null && !state.isOnline)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: AtelierOfflineState(onRetry: onRefresh),
                              )
                            else if (order == null && state.error != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: AtelierErrorState(
                                  message: state.error!.asString(strings),
                                  onRetry: onRefresh,
                                ),
                              )
                            else if (order != null)
                              ..._orderBody(context, strings, order),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _orderBody(BuildContext context, AppLocalizations strings, PurchaseOrder order) {
    final colors = context.atelier;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AtelierSectionHeader(
          title: strings.inventoryPoLinesHeader,
          count: order.lines.length,
          action: order.isDraft && state.canCreate
              ? AtelierButton(
                  text: strings.invSeg2PoAddLineBtn,
                  onClick: onOpenAddLine,
                  style: AtelierButtonStyle.text,
                  icon: Icons.add,
                )
              : null,
        ),
      ),
      if (order.lines.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierEmptyState(
            text: strings.invSeg2PoIssueHint,
            actionLabel: order.isDraft && state.canCreate ? strings.invSeg2PoAddLineBtn : null,
            onAction: order.isDraft && state.canCreate ? onOpenAddLine : null,
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierSurface(
            tier: SurfaceTier.card,
            shape: cardLargeShape,
            child: Column(
              children: [
                for (var i = 0; i < order.lines.length; i++)
                  _lineRow(context, strings, order.lines[i], showDivider: i < order.lines.length - 1),
              ],
            ),
          ),
        ),
      if (state.canCreate && (order.isDraft || order.canBeCanceled))
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              if (!state.isOnline) const AtelierRequiresConnection(),
              if (order.isDraft) ...[
                if (order.lines.isEmpty)
                  Text(
                    strings.invSeg2PoIssueHint,
                    style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                  ),
                AtelierButton(
                  text: strings.invSeg2PoIssueBtn,
                  onClick: onIssueOrder,
                  enabled: order.lines.isNotEmpty && state.isOnline && !state.isMutating,
                  loading: state.isMutating,
                ),
              ],
              if (order.canBeCanceled)
                AtelierButton(
                  text: strings.invSeg2PoCancelBtn,
                  onClick: onOpenCancel,
                  style: AtelierButtonStyle.destructive,
                  enabled: state.isOnline && !state.isMutating,
                ),
            ],
          ),
        ),
      if (order.receivedAt != null || order.receiptNumber != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierSectionHeader(title: strings.inventoryPoReceiptHeader),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierSurface(
            tier: SurfaceTier.card,
            shape: cardLargeShape,
            child: Column(
              children: [
                if (order.receiptNumber case final number?)
                  AtelierListRow(
                    title: strings.inventoryPoReceiptNumber,
                    showDivider: order.receivedAt != null,
                    trailing: Text(number, style: context.text.titleMedium),
                  ),
                if (order.receivedAt case final at?)
                  AtelierListRow(
                    title: strings.inventoryPoReceiptDate,
                    showDivider: false,
                    trailing: Text(at.formatLimaDate(), style: context.text.titleMedium),
                  ),
              ],
            ),
          ),
        ),
      ],
    ];
  }

  Widget _lineRow(
    BuildContext context,
    AppLocalizations strings,
    PurchaseOrderLine line, {
    required bool showDivider,
  }) {
    final qtyText = line.quantity.formatQuantity();
    final unitCost = line.unitCost;
    final totalCost = line.totalCost;
    return AtelierListRow(
      title: state.partNames[line.itemId] ?? strings.inventoryPoLineUnknown,
      subtitle: unitCost != null
          ? strings.inventoryPoLineSubtitle(qtyText, unitCost.format())
          : strings.inventoryPoLineQuantity(qtyText),
      showDivider: showDivider,
      trailing: totalCost != null
          ? Text(
              totalCost.format(),
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            )
          : null,
    );
  }
}

class _AddLineSheet extends StatelessWidget {
  final PurchaseOrderDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onPartQueryChange;
  final ValueChanged<Part> onSelectPart;
  final ValueChanged<String> onQuantityChange;
  final ValueChanged<String> onUnitCostChange;
  final VoidCallback onConfirm;

  const _AddLineSheet({
    required this.state,
    required this.onDismiss,
    required this.onPartQueryChange,
    required this.onSelectPart,
    required this.onQuantityChange,
    required this.onUnitCostChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isAddingLine;
    return AtelierBottomSheet(
      title: strings.invSeg2PoAddLineTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.invSeg2PoAddLineBtn,
          onClick: onConfirm,
          enabled: state.isOnline && state.selectedPartId != null && !state.isAddingLine,
          loading: state.isAddingLine,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: enabled,
        ),
      ],
      content: [
        AtelierTextField(
          label: strings.invSeg2PoSelectPart,
          value: state.partQuery,
          onValueChange: onPartQueryChange,
          leadingIcon: Icons.search,
          placeholder: strings.invSeg2PoPartSearchHint,
          enabled: enabled,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final part in state.filteredCatalogParts)
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
          onValueChange: onQuantityChange,
          isError: state.lineQtyError != null,
          errorText: state.lineQtyError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AtelierTextField(
          label: strings.invSeg2BatchUnitCostLabel,
          value: state.lineUnitCost,
          onValueChange: onUnitCostChange,
          isError: state.lineCostError != null,
          errorText: state.lineCostError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.addLineError case final err?)
          AtelierBanner(message: err.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class _CancelOrderSheet extends StatelessWidget {
  final PurchaseOrderDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;

  const _CancelOrderSheet({
    required this.state,
    required this.onDismiss,
    required this.onReasonChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return AtelierBottomSheet(
      title: strings.invSeg2PoCancelTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.invSeg2PoCancelConfirm,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: state.isOnline && !state.isCanceling,
          loading: state.isCanceling,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !state.isCanceling,
        ),
      ],
      content: [
        Text(
          strings.invSeg2PoCancelBody,
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
        AtelierTextField(
          label: strings.invSeg2PoCancelReason,
          value: state.cancelReason,
          onValueChange: onReasonChange,
          enabled: !state.isCanceling,
        ),
        if (state.cancelError case final err?)
          AtelierBanner(message: err.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
