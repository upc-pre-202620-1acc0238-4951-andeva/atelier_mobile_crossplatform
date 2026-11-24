import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
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
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US32: ficha del repuesto, lotes en orden FIFO, edición (`PARTS_MANAGE`) y operaciones de lote FIFO.
class PartDetailScreen extends StatefulWidget {
  final String partId;

  const PartDetailScreen({super.key, required this.partId});

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  late final PartDetailViewModel viewModel = getIt<PartDetailViewModel>(param1: widget.partId);
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
    return StateSheetHost<PartDetailSheet>(
      listenable: viewModel,
      value: () => viewModel.state.activeSheet == PartDetailSheet.none ? null : viewModel.state.activeSheet,
      onDismiss: viewModel.onDismissSheet,
      sheetBuilder: (context, sheet) {
        final state = viewModel.state;
        void dismiss() => Navigator.of(context).maybePop();
        return switch (sheet) {
          PartDetailSheet.editPart => EditPartSheetContent(
            state: state,
            onDismiss: dismiss,
            onNameChange: viewModel.onEditNameChange,
            onCategoryChange: viewModel.onEditCategoryChange,
            onBasePriceChange: viewModel.onEditBasePriceChange,
            onMinStockChange: viewModel.onEditMinStockChange,
            onStatusChange: viewModel.onEditStatusChange,
            onConfirm: viewModel.onConfirmEditPart,
          ),
          PartDetailSheet.receiveBatch => ReceiveDirectBatchSheetContent(
            state: state,
            onDismiss: dismiss,
            onBatchNumberChange: viewModel.onBatchNumberChange,
            onQuantityChange: viewModel.onBatchQuantityChange,
            onUnitCostChange: viewModel.onBatchUnitCostChange,
            onConfirm: viewModel.onConfirmReceiveBatch,
          ),
          PartDetailSheet.dispatchFifo => DispatchFifoSheetContent(
            state: state,
            onDismiss: dismiss,
            onQuantityChange: viewModel.onBatchQuantityChange,
            onConfirm: viewModel.onConfirmDispatchFifo,
          ),
          PartDetailSheet.restoreBatch => RestoreBatchSheetContent(
            state: state,
            onDismiss: dismiss,
            onQuantityChange: viewModel.onBatchQuantityChange,
            onSelectBatch: viewModel.onSelectedBatchIdChange,
            onReasonChange: viewModel.onRestoreReasonChange,
            onConfirm: viewModel.onConfirmRestoreBatch,
          ),
          PartDetailSheet.none => const SizedBox.shrink(),
        };
      },
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => PartDetailContent(
          state: viewModel.state,
          onBack: inventoryBack(context),
          onRefresh: () => viewModel.refresh(force: true),
          onOpenEditPart: viewModel.onOpenEditPart,
          onOpenReceiveBatch: viewModel.onOpenReceiveBatch,
          onOpenDispatchFifo: viewModel.onOpenDispatchFifo,
          onOpenRestoreBatch: viewModel.onOpenRestoreBatch,
          onOpenPurchaseOrders: () => AppNavigator.push(context, AppRoute.purchaseOrders),
        ),
      ),
    );
  }
}

class PartDetailContent extends StatelessWidget {
  final PartDetailUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenEditPart;
  final VoidCallback onOpenReceiveBatch;
  final VoidCallback onOpenDispatchFifo;
  final VoidCallback onOpenRestoreBatch;
  final VoidCallback? onOpenPurchaseOrders;

  const PartDetailContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onOpenEditPart,
    required this.onOpenReceiveBatch,
    required this.onOpenDispatchFifo,
    required this.onOpenRestoreBatch,
    this.onOpenPurchaseOrders,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final part = state.part;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Column(
        children: [
          AtelierFichaPanel(
            onBack: onBack,
            title: part?.name ?? strings.partDetailTitle,
            subtitle: part == null ? null : strings.partSku(part.sku),
            status: part == null
                ? null
                : AtelierChip(text: part.stockLabel(strings), kind: part.stockChipKind),
            actions: [
              if (state.canManageParts && part != null)
                IconButton(
                  onPressed: onOpenEditPart,
                  tooltip: strings.invSeg2PartEditBtn,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          AtelierRefreshBar(visible: state.isLoading && part != null),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: DelayedLoading(
                loading: part == null && state.isLoading,
                builder: (context, showPartBones) => DelayedLoading(
                  loading: state.batches.isEmpty && state.isLoading,
                  builder: (context, showBatchBones) =>
                      _list(context, strings, showPartBones, showBatchBones),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showPartBones, bool showBatchBones) {
    final part = state.part;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (state.actionBanner case final message?)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
            child: AtelierBanner(
              message: message.asString(strings),
              icon: Icons.check_circle_outline,
              kind: BannerKind.ok,
            ),
          ),
        if (state.showingCache)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AtelierBanner(
              message: state.error?.asString(strings) ?? strings.batchesCacheNotice,
              icon: Icons.info_outline,
              kind: BannerKind.info,
            ),
          ),
        if (showPartBones) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierSectionHeader(title: strings.inventoryDetailStockSection),
          ),
          for (var i = 0; i < 3; i++)
            const AtelierListRow(title: 'Existencias', subtitle: '14 unidades', loading: true),
        ] else if (part != null) ...[
          if (part.isLowStock || part.isOutOfStock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  AtelierBanner(
                    message: strings.invSeg2PartLowStockBanner(
                      part.totalStock.formatQuantity(),
                      part.minimumStock.formatQuantity(),
                    ),
                    icon: Icons.warning_amber_outlined,
                    kind: part.isOutOfStock ? BannerKind.bad : BannerKind.wait,
                  ),
                  if (state.canOpenPurchaseOrders && onOpenPurchaseOrders != null)
                    AtelierButton(
                      text: strings.invSeg2PartOpenPoBtn,
                      onClick: onOpenPurchaseOrders!,
                      style: AtelierButtonStyle.outlined,
                      icon: Icons.shopping_cart_outlined,
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierSectionHeader(title: strings.inventoryDetailStockSection),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
            child: _StockCalibrationCard(part: part),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
            child: AtelierSurface(
              tier: SurfaceTier.card,
              shape: cardLargeShape,
              child: Column(
                children: [
                  _Fact(label: strings.inventoryDetailStock, value: part.totalStock.formatQuantity()),
                  _Fact(
                    label: strings.inventoryDetailMinimum,
                    value: part.minimumStock.formatQuantity(),
                    showDivider: part.basePrice != null || part.category != null,
                  ),
                  if (part.basePrice case final price?)
                    _Fact(
                      label: strings.inventoryDetailPrice,
                      value: price.format(),
                      showDivider: part.category != null,
                    ),
                  if (part.category case final category?)
                    _Fact(
                      label: strings.inventoryDetailCategory,
                      value: category.label(strings),
                      showDivider: false,
                    ),
                ],
              ),
            ),
          ),
          if (state.hasAnyBatchAction)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  AtelierSectionHeader(title: strings.invSeg2BatchActionsHeader),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (state.canReceiveBatch)
                        AtelierButton(
                          text: strings.invSeg2BatchReceiveBtn,
                          onClick: onOpenReceiveBatch,
                          style: AtelierButtonStyle.tonal,
                          icon: Icons.add_box_outlined,
                        ),
                      if (state.canDispatchFifo)
                        AtelierButton(
                          text: strings.invSeg2BatchDispatchBtn,
                          onClick: onOpenDispatchFifo,
                          style: AtelierButtonStyle.outlined,
                          enabled: !part.isOutOfStock,
                          icon: Icons.output_outlined,
                        ),
                      if (state.canRestoreBatch)
                        AtelierButton(
                          text: strings.invSeg2BatchRestoreBtn,
                          onClick: onOpenRestoreBatch,
                          style: AtelierButtonStyle.outlined,
                          icon: Icons.restore_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierSectionHeader(
            title: strings.batchesTitle,
            count: state.canReadBatches && state.batches.isNotEmpty ? state.batches.length : null,
          ),
        ),
        if (!state.canReadBatches)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierNoPermissionState(text: strings.batchesNoPermission),
          )
        else if (showBatchBones)
          for (var i = 0; i < 2; i++)
            const AtelierListRow(
              title: 'Lote L-0001',
              subtitle: 'Saldo: 6 · Ingresó el 10/03/2026',
              loading: true,
            )
        else if (state.batches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierEmptyState(text: strings.batchesEmpty),
          )
        else
          for (final batch in state.batches)
            _BatchRow(key: ValueKey(batch.id), batch: batch, isNext: batch.id == state.nextBatchId),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _Fact({required this.label, required this.value, this.showDivider = true});

  @override
  Widget build(BuildContext context) {
    return AtelierListRow(
      title: label,
      showDivider: showDivider,
      trailing: Text(
        value,
        style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
      ),
    );
  }
}

class _BatchRow extends StatelessWidget {
  final PartBatch batch;
  final bool isNext;

  const _BatchRow({super.key, required this.batch, required this.isNext});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final arrival = batch.arrivalDate == null ? null : strings.batchArrival(batch.arrivalDate!.formatLimaDate());
    final cost = batch.unitCost == null ? null : strings.batchUnitCost(batch.unitCost!.format());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: cardLargeShape,
        child: AtelierListRow(
          title: strings.batchNumber(batch.batchNumber),
          subtitle: [
            strings.batchRemaining(batch.remainingQty.formatQuantity()),
            ?arrival,
            ?cost,
          ].join(' · '),
          showDivider: false,
          leading: isNext ? AtelierLiveBeacon(color: colors.info) : null,
          trailing: isNext
              ? AtelierChip(text: strings.batchNext, kind: ChipKind.info)
              : batch.isActive
              ? AtelierChip(text: strings.batchWaiting, kind: ChipKind.ok)
              : AtelierChip(text: strings.batchDepleted, kind: ChipKind.idle),
        ),
      ),
    );
  }
}

class _StockCalibrationCard extends StatelessWidget {
  final Part part;

  const _StockCalibrationCard({required this.part});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final stock = part.totalStock.toDouble().clamp(0.0, double.infinity);
    final minimum = part.minimumStock.toDouble().clamp(0.0, double.infinity);
    final scaleMax = [minimum * 2, stock * 1.15, 1.0].reduce((a, b) => a > b ? a : b);
    final progress = (stock / scaleMax).clamp(0.0, 1.0);
    final markerAt = minimum > 0 ? (minimum / scaleMax).clamp(0.08, 0.92) : null;
    final barColor = part.isOutOfStock
        ? colors.badMark
        : part.isLowStock
        ? colors.warnMark
        : colors.okMark;
    final statusText = part.isOutOfStock
        ? strings.premiumPartStockOut
        : part.isLowStock
        ? strings.premiumPartStockLow
        : strings.premiumPartStockHealthy;
    final statusColor = part.isOutOfStock
        ? colors.bad
        : part.isLowStock
        ? colors.warn
        : colors.ok;
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.premiumPartStockLevel,
                style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
              ),
              Text(
                strings.premiumPartStockRatio(
                  part.totalStock.formatQuantity(),
                  part.minimumStock.formatQuantity(),
                ),
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ],
          ),
          AtelierMetricBar(progress: progress, color: barColor, height: 8, markerAt: markerAt),
          Text(statusText, style: context.text.bodySmall?.copyWith(color: statusColor)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hojas

List<Widget> _sheetActions(
  AppLocalizations strings,
  PartDetailUiState state, {
  required String confirmText,
  required VoidCallback onConfirm,
  required VoidCallback onDismiss,
}) {
  return [
    if (!state.isOnline) const AtelierRequiresConnection(),
    AtelierButton(
      text: confirmText,
      onClick: onConfirm,
      enabled: state.isOnline && !state.isSubmitting,
      loading: state.isSubmitting,
    ),
    AtelierButton(
      text: strings.commonCancel,
      onClick: onDismiss,
      style: AtelierButtonStyle.text,
      enabled: !state.isSubmitting,
    ),
  ];
}

class EditPartSheetContent extends StatelessWidget {
  final PartDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onNameChange;
  final ValueChanged<ItemCategory> onCategoryChange;
  final ValueChanged<String> onBasePriceChange;
  final ValueChanged<String> onMinStockChange;
  final ValueChanged<PartStatus> onStatusChange;
  final VoidCallback onConfirm;

  const EditPartSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onNameChange,
    required this.onCategoryChange,
    required this.onBasePriceChange,
    required this.onMinStockChange,
    required this.onStatusChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isSubmitting;
    final labelStyle = context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary);
    return AtelierBottomSheet(
      title: strings.invSeg2PartEditTitle,
      actions: _sheetActions(
        strings,
        state,
        confirmText: strings.invSeg2Save,
        onConfirm: onConfirm,
        onDismiss: onDismiss,
      ),
      content: [
        AtelierTextField(
          label: strings.invSeg2PartName,
          value: state.editName,
          onValueChange: onNameChange,
          isError: state.editNameError != null,
          errorText: state.editNameError?.asString(strings),
          enabled: enabled,
        ),
        Text(strings.invSeg2PartCategory, style: labelStyle),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final category in ItemCategory.values)
              FilterChip(
                selected: state.editCategory == category,
                onSelected: enabled ? (_) => onCategoryChange(category) : null,
                label: Text(category.label(strings)),
                shape: controlShape,
              ),
          ],
        ),
        AtelierTextField(
          label: strings.invSeg2PartBasePrice,
          value: state.editBasePrice,
          onValueChange: onBasePriceChange,
          isError: state.editPriceError != null,
          errorText: state.editPriceError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AtelierTextField(
          label: strings.invSeg2PartMinStock,
          value: state.editMinStock,
          onValueChange: onMinStockChange,
          isError: state.editMinStockError != null,
          errorText: state.editMinStockError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        Text(strings.invSeg2PartStatus, style: labelStyle),
        Wrap(
          spacing: 8,
          children: [
            for (final status in PartStatus.values)
              FilterChip(
                selected: state.editStatus == status,
                onSelected: enabled ? (_) => onStatusChange(status) : null,
                label: Text(switch (status) {
                  PartStatus.active => strings.invSeg2PartStatusActive,
                  PartStatus.inactive => strings.invSeg2PartStatusInactive,
                  PartStatus.discontinued => strings.invSeg2PartStatusDiscontinued,
                }),
                shape: controlShape,
              ),
          ],
        ),
        if (state.sheetError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class ReceiveDirectBatchSheetContent extends StatelessWidget {
  final PartDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onBatchNumberChange;
  final ValueChanged<String> onQuantityChange;
  final ValueChanged<String> onUnitCostChange;
  final VoidCallback onConfirm;

  const ReceiveDirectBatchSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onBatchNumberChange,
    required this.onQuantityChange,
    required this.onUnitCostChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isSubmitting;
    return AtelierBottomSheet(
      title: strings.invSeg2BatchReceiveTitle,
      actions: _sheetActions(
        strings,
        state,
        confirmText: strings.invSeg2Confirm,
        onConfirm: onConfirm,
        onDismiss: onDismiss,
      ),
      content: [
        AtelierTextField(
          label: strings.invSeg2BatchNumberLabel,
          value: state.batchNumber,
          onValueChange: onBatchNumberChange,
          isError: state.batchNumberError != null,
          errorText: state.batchNumberError?.asString(strings),
          enabled: enabled,
        ),
        AtelierTextField(
          label: strings.invSeg2BatchQuantityLabel,
          value: state.batchQuantity,
          onValueChange: onQuantityChange,
          isError: state.batchQtyError != null,
          errorText: state.batchQtyError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AtelierTextField(
          label: strings.invSeg2BatchUnitCostLabel,
          value: state.batchUnitCost,
          onValueChange: onUnitCostChange,
          isError: state.batchCostError != null,
          errorText: state.batchCostError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.sheetError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class DispatchFifoSheetContent extends StatelessWidget {
  final PartDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onQuantityChange;
  final VoidCallback onConfirm;

  const DispatchFifoSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onQuantityChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.invSeg2BatchDispatchTitle,
      actions: _sheetActions(
        strings,
        state,
        confirmText: strings.invSeg2Confirm,
        onConfirm: onConfirm,
        onDismiss: onDismiss,
      ),
      content: [
        AtelierTextField(
          label: strings.invSeg2BatchQuantityLabel,
          value: state.batchQuantity,
          onValueChange: onQuantityChange,
          isError: state.batchQtyError != null,
          errorText: state.batchQtyError?.asString(strings),
          enabled: !state.isSubmitting,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.sheetError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class RestoreBatchSheetContent extends StatelessWidget {
  final PartDetailUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onQuantityChange;
  final ValueChanged<String?> onSelectBatch;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;

  const RestoreBatchSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onQuantityChange,
    required this.onSelectBatch,
    required this.onReasonChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isSubmitting;
    return AtelierBottomSheet(
      title: strings.invSeg2BatchRestoreTitle,
      actions: _sheetActions(
        strings,
        state,
        confirmText: strings.invSeg2Confirm,
        onConfirm: onConfirm,
        onDismiss: onDismiss,
      ),
      content: [
        AtelierTextField(
          label: strings.invSeg2BatchQuantityLabel,
          value: state.batchQuantity,
          onValueChange: onQuantityChange,
          isError: state.batchQtyError != null,
          errorText: state.batchQtyError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.batches.isNotEmpty) ...[
          Text(
            strings.invSeg2BatchSelectLabel,
            style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                selected: state.selectedBatchId == null,
                onSelected: enabled ? (_) => onSelectBatch(null) : null,
                label: Text(strings.invSeg2BatchSelectAuto),
                shape: controlShape,
              ),
              for (final batch in state.batches)
                FilterChip(
                  selected: state.selectedBatchId == batch.id,
                  onSelected: enabled ? (_) => onSelectBatch(batch.id) : null,
                  label: Text(strings.batchNumber(batch.batchNumber)),
                  shape: controlShape,
                ),
            ],
          ),
        ],
        AtelierTextField(
          label: strings.invSeg2BatchReasonLabel,
          value: state.restoreReason,
          onValueChange: onReasonChange,
          enabled: enabled,
        ),
        if (state.sheetError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
