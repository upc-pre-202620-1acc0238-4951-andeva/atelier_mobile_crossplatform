import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/components/category_filter_chips.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US31: catálogo con buscador por nombre o SKU, escáner, categorías, semáforo y alta (`PARTS_MANAGE`).
/// Es la raíz de la pestaña Stock: su flecha vuelve a la pestaña de inicio.
class PartsCatalogScreen extends StatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  State<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends State<PartsCatalogScreen> {
  late final PartsCatalogViewModel viewModel = getIt<PartsCatalogViewModel>();
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
    return StateSheetHost<bool>(
      listenable: viewModel,
      value: () => viewModel.state.createSheetOpen ? true : null,
      onDismiss: viewModel.onDismissCreateSheet,
      sheetBuilder: (context, _) => CreatePartSheetContent(
        state: viewModel.state,
        onDismiss: () => Navigator.of(context).maybePop(),
        onNameChange: viewModel.onFormNameChange,
        onSkuChange: viewModel.onFormSkuChange,
        onCategoryChange: viewModel.onFormCategoryChange,
        onBasePriceChange: viewModel.onFormBasePriceChange,
        onMinimumStockChange: viewModel.onFormMinimumStockChange,
        onConfirm: viewModel.onCreatePart,
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => PartsCatalogContent(
          state: viewModel.state,
          onBack: inventoryBack(context),
          onQueryChange: viewModel.onQueryChange,
          onCategoryClick: viewModel.onCategoryClick,
          onClearFilters: viewModel.onClearFilters,
          onRefresh: () => viewModel.refresh(force: true),
          onOpenPart: (id) => AppNavigator.push(context, AppRoute.partDetail, id),
          onOpenScanner: () => AppNavigator.push(context, AppRoute.skuScanner),
          onOpenCreateSheet: viewModel.onOpenCreateSheet,
        ),
      ),
    );
  }
}

class PartsCatalogContent extends StatelessWidget {
  final PartsCatalogUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<ItemCategory> onCategoryClick;
  final VoidCallback onClearFilters;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onOpenPart;
  final VoidCallback onOpenScanner;
  final VoidCallback onOpenCreateSheet;

  const PartsCatalogContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onQueryChange,
    required this.onCategoryClick,
    required this.onClearFilters,
    required this.onRefresh,
    required this.onOpenPart,
    required this.onOpenScanner,
    required this.onOpenCreateSheet,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canRead && state.canManage
          ? AtelierFab(
              text: strings.invSeg2PartNewFab,
              icon: Icons.add,
              onClick: onOpenCreateSheet,
            ).floatingBarPadding()
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.catalogTitle, onBack: onBack),
          if (!state.canRead)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.catalogNoPermission),
            )
          else ...[
            AtelierRefreshBar(visible: state.isRefreshing || state.isSearching),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: DelayedLoading(
                  loading: !state.isLoaded,
                  builder: (context, showSkeleton) =>
                      _list(context, strings, showSkeleton),
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
    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            AtelierTextField(
              label: strings.catalogSearchLabel,
              value: state.query,
              onValueChange: onQueryChange,
              leadingIcon: Icons.search,
              placeholder: strings.catalogSearchHint,
              textInputAction: TextInputAction.search,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.query.isNotEmpty)
                    IconButton(
                      onPressed: () => onQueryChange(''),
                      tooltip: strings.invSeg2Clear,
                      icon: const Icon(Icons.close),
                    ),
                  IconButton(
                    onPressed: onOpenScanner,
                    tooltip: strings.invSeg2ScannerOpenDesc,
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
            ),
            CategoryFilterChips(selected: state.category, onClick: onCategoryClick),
          ],
        ),
      ),
      if (state.bannerMessage case final message?)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: AtelierBanner(
            message: message.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        ),
      if (state.showingCache && state.parts.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: AtelierBanner(
            message: error?.asString(strings) ?? strings.catalogCacheNotice,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          ),
        ),
      if (showSkeleton)
        for (var i = 0; i < 6; i++)
          const AtelierListRow(
            title: 'Pastillas de freno',
            subtitle: 'SKU BRK-001 · Stock: 12',
            loading: true,
          )
      else if (!state.isLoaded && state.parts.isEmpty)
        const SizedBox.shrink()
      else if (state.parts.isEmpty && error != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
        )
      else if (state.parts.isEmpty && state.isLoaded)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierEmptyState(
            text: state.hasFilters ? strings.catalogEmptyFiltered : strings.catalogEmpty,
            actionLabel: state.hasFilters ? strings.catalogClearFilters : null,
            onAction: state.hasFilters ? onClearFilters : null,
          ),
        )
      else
        for (final part in state.parts)
          AtelierListRow(
            key: ValueKey(part.id),
            title: part.name,
            subtitle: strings.inventoryPartSubtitle(part.sku, part.totalStock.formatQuantity()),
            onClick: () => onOpenPart(part.id),
            trailing: AtelierChip(text: part.stockLabel(strings), kind: part.stockChipKind),
          ),
    ];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: (state.canManage ? 96 : 24) + FloatingBarInset.of(context),
      ),
      children: children,
    );
  }
}

class CreatePartSheetContent extends StatelessWidget {
  final PartsCatalogUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onNameChange;
  final ValueChanged<String> onSkuChange;
  final ValueChanged<ItemCategory> onCategoryChange;
  final ValueChanged<String> onBasePriceChange;
  final ValueChanged<String> onMinimumStockChange;
  final VoidCallback onConfirm;

  const CreatePartSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onNameChange,
    required this.onSkuChange,
    required this.onCategoryChange,
    required this.onBasePriceChange,
    required this.onMinimumStockChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isCreating;
    return AtelierBottomSheet(
      title: strings.invSeg2PartCreateTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.invSeg2Save,
          onClick: onConfirm,
          enabled: state.isOnline && !state.isCreating,
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
        AtelierTextField(
          label: strings.invSeg2PartName,
          value: state.formName,
          onValueChange: onNameChange,
          isError: state.nameError != null,
          errorText: state.nameError?.asString(strings),
          enabled: enabled,
        ),
        AtelierTextField(
          label: strings.invSeg2PartSku,
          value: state.formSku,
          onValueChange: onSkuChange,
          isError: state.skuError != null,
          errorText: state.skuError?.asString(strings),
          enabled: enabled,
          textCapitalization: TextCapitalization.characters,
        ),
        Text(
          strings.invSeg2PartCategory,
          style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final category in ItemCategory.values)
              FilterChip(
                selected: state.formCategory == category,
                onSelected: enabled ? (_) => onCategoryChange(category) : null,
                label: Text(category.label(strings)),
                shape: controlShape,
              ),
          ],
        ),
        AtelierTextField(
          label: strings.invSeg2PartBasePrice,
          value: state.formBasePrice,
          onValueChange: onBasePriceChange,
          isError: state.priceError != null,
          errorText: state.priceError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        AtelierTextField(
          label: strings.invSeg2PartMinStock,
          value: state.formMinimumStock,
          onValueChange: onMinimumStockChange,
          isError: state.minStockError != null,
          errorText: state.minStockError?.asString(strings),
          enabled: enabled,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (state.createError case final error?)
          AtelierBanner(
            message: error.asString(strings),
            icon: Icons.error_outline,
          ),
      ],
    );
  }
}
