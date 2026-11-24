import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final _decimalFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];

/// Catálogo de servicios estándar del taller con alta, edición y eliminación (`SERVICES_MANAGE`).
class ServicesCatalogScreen extends StatefulWidget {
  const ServicesCatalogScreen({super.key});

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  late final ServicesCatalogViewModel viewModel = getIt<ServicesCatalogViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return StateSheetHost<ServiceEditorForm>(
      listenable: vm,
      value: () => vm.state.form,
      onDismiss: vm.onDismissForm,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          final s = vm.state;
          final form = s.form;
          if (form == null) return const SizedBox.shrink();
          final editingService = form.serviceId == null
              ? null
              : s.services.where((svc) => svc.id == form.serviceId).firstOrNull;
          return _ServiceEditorSheet(
            form: form,
            isSaving: s.isSaving,
            canConfirm: s.canConfirmForm,
            invalidField: s.invalidField,
            error: s.error,
            onNameChange: vm.onNameChange,
            onBasePriceChange: vm.onBasePriceChange,
            onEstimatedMinutesChange: vm.onEstimatedMinutesChange,
            onConfirm: vm.onConfirmForm,
            onDelete: editingService != null ? () => vm.onOpenDelete(editingService) : null,
          );
        },
      ),
      child: StateSheetHost<ServiceOption>(
        listenable: vm,
        value: () => vm.state.deletingService,
        onDismiss: vm.onDismissDelete,
        sheetBuilder: (context, _) => ListenableBuilder(
          listenable: vm,
          builder: (context, _) {
            final s = vm.state;
            final service = s.deletingService;
            if (service == null) return const SizedBox.shrink();
            return _DeleteServiceSheet(
              serviceName: service.name,
              isSaving: s.isSaving,
              error: s.error,
              onConfirm: vm.onConfirmDelete,
              onDismiss: vm.onDismissDelete,
            );
          },
        ),
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => ServicesCatalogContent(
            state: vm.state,
            onBack: () => Navigator.of(context).maybePop(),
            onRefresh: vm.load,
            onSearchQueryChange: vm.onSearchQueryChange,
            onOpenCreate: vm.onOpenCreate,
            onOpenEdit: vm.onOpenEdit,
            onOpenDelete: vm.onOpenDelete,
          ),
        ),
      ),
    );
  }
}

class ServicesCatalogContent extends StatelessWidget {
  final ServicesCatalogUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchQueryChange;
  final VoidCallback onOpenCreate;
  final ValueChanged<ServiceOption> onOpenEdit;
  final ValueChanged<ServiceOption> onOpenDelete;

  const ServicesCatalogContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onSearchQueryChange,
    required this.onOpenCreate,
    required this.onOpenEdit,
    required this.onOpenDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final notice = state.notice;
    final error = state.error;

    return Scaffold(
      floatingActionButton: state.canCreate
          ? AtelierFab(text: strings.servicesAdd, icon: Icons.add, onClick: onOpenCreate)
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.servicesTitle, onBack: onBack),
          AtelierRefreshBar(visible: state.isLoading && state.services.isNotEmpty),
          if (!state.canRead && !state.isLoading)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AtelierNoPermissionState(text: strings.servicesReadonlyHint),
              ),
            )
          else
            Expanded(
              child: DelayedLoading(
                loading: state.services.isEmpty && state.isLoading,
                builder: (context, showSkeleton) => RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      Text(
                        strings.servicesSubtitle,
                        style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                      ),
                      const SizedBox(height: 8),
                      if (!state.isOnline) ...[
                        const AtelierRequiresConnection(),
                        const SizedBox(height: 8),
                      ],
                      if (!state.canManage && state.canRead) ...[
                        AtelierBanner(
                          message: strings.servicesReadonlyHint,
                          icon: Icons.info_outline,
                          kind: BannerKind.info,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (notice != null) ...[
                        AtelierBanner(
                          message: notice.asString(strings),
                          icon: Icons.check_circle_outline,
                          kind: BannerKind.ok,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (error != null &&
                          state.form == null &&
                          state.deletingService == null &&
                          state.services.isNotEmpty) ...[
                        AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
                        const SizedBox(height: 8),
                      ],
                      if (state.services.isNotEmpty) ...[
                        AtelierTextField(
                          label: '',
                          placeholder: strings.servicesSearchHint,
                          value: state.searchQuery,
                          onValueChange: onSearchQueryChange,
                          leadingIcon: Icons.search,
                          trailing: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () => onSearchQueryChange(''),
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                          textInputAction: TextInputAction.search,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (showSkeleton)
                        for (var i = 0; i < 4; i++) ...[
                          const _ServiceSkeletonCard(),
                          const SizedBox(height: 8),
                        ]
                      else if (state.services.isEmpty && !state.isLoading && !state.isOnline)
                        AtelierOfflineState(onRetry: onRefresh)
                      else if (state.services.isEmpty && error != null && !state.isLoading)
                        AtelierErrorState(message: error.asString(strings), onRetry: onRefresh)
                      else if (state.services.isEmpty && !state.isLoading)
                        AtelierEmptyState(
                          text: strings.servicesEmpty,
                          actionLabel: state.canCreate ? strings.servicesAdd : null,
                          onAction: state.canCreate ? onOpenCreate : null,
                        )
                      else if (state.filteredServices.isEmpty)
                        AtelierEmptyState(text: strings.servicesEmptySearch)
                      else
                        for (final service in state.filteredServices) ...[
                          _ServiceCatalogCard(
                            service: service,
                            canManage: state.canManage && state.isOnline,
                            onClick: () => onOpenEdit(service),
                            onDelete: () => onOpenDelete(service),
                          ),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceCatalogCard extends StatelessWidget {
  final ServiceOption service;
  final bool canManage;
  final VoidCallback onClick;
  final VoidCallback onDelete;

  const _ServiceCatalogCard({
    required this.service,
    required this.canManage,
    required this.onClick,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final minutes = service.estimatedMinutes;
    final price = service.basePrice;
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      child: AtelierListRow(
        title: service.name,
        subtitle: minutes != null ? strings.servicesDurationMin(minutes) : null,
        showDivider: false,
        onClick: canManage ? onClick : null,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 2,
          children: [
            if (price != null)
              Text(
                price.format(),
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                maxLines: 1,
              ),
            if (canManage)
              IconButton(
                onPressed: onDelete,
                tooltip: strings.servicesDeleteAction,
                icon: Icon(Icons.delete_outline, color: context.atelier.bad),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSkeletonCard extends StatelessWidget {
  const _ServiceSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: const [
          Bone(loading: true, widthFraction: 0.68, child: SizedBox(height: 18)),
          Bone(loading: true, widthFraction: 0.32, child: SizedBox(height: 14)),
        ],
      ),
    );
  }
}

class _ServiceEditorSheet extends StatelessWidget {
  final ServiceEditorForm form;
  final bool isSaving;
  final bool canConfirm;
  final String? invalidField;
  final UiText? error;
  final ValueChanged<String> onNameChange;
  final ValueChanged<String> onBasePriceChange;
  final ValueChanged<String> onEstimatedMinutesChange;
  final VoidCallback onConfirm;
  final VoidCallback? onDelete;

  const _ServiceEditorSheet({
    required this.form,
    required this.isSaving,
    required this.canConfirm,
    required this.invalidField,
    required this.error,
    required this.onNameChange,
    required this.onBasePriceChange,
    required this.onEstimatedMinutesChange,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final currentError = error;
    return AtelierBottomSheet(
      title: form.isEditing ? strings.servicesEditTitle : strings.servicesNewTitle,
      actions: [
        AtelierButton(
          text: form.isEditing ? strings.servicesSaveEdit : strings.servicesSaveCreate,
          onClick: onConfirm,
          enabled: canConfirm,
          loading: isSaving,
        ),
        if (onDelete != null)
          AtelierButton(
            text: strings.servicesDeleteAction,
            onClick: onDelete!,
            style: AtelierButtonStyle.destructive,
            enabled: !isSaving,
          ),
      ],
      content: [
        AtelierTextField(
          label: strings.servicesNameLabel,
          placeholder: strings.servicesNameHint,
          value: form.name,
          onValueChange: onNameChange,
          enabled: !isSaving,
          isError: invalidField == 'name',
          errorText: invalidField == 'name' ? strings.servicesFieldName : null,
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.servicesPriceLabel,
          placeholder: strings.servicesPriceHint,
          value: form.basePrice,
          onValueChange: onBasePriceChange,
          enabled: !isSaving,
          isError: invalidField == 'basePrice',
          errorText: invalidField == 'basePrice' ? strings.servicesFieldPrice : null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: _decimalFormatters,
          textInputAction: TextInputAction.next,
        ),
        AtelierTextField(
          label: strings.servicesDurationLabel,
          placeholder: strings.servicesDurationHint,
          value: form.estimatedMinutes,
          onValueChange: onEstimatedMinutesChange,
          enabled: !isSaving,
          isError: invalidField == 'estimatedMinutes',
          errorText: invalidField == 'estimatedMinutes' ? strings.servicesFieldDuration : null,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
        ),
        if (currentError != null)
          AtelierBanner(message: currentError.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}

class _DeleteServiceSheet extends StatelessWidget {
  final String serviceName;
  final bool isSaving;
  final UiText? error;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  const _DeleteServiceSheet({
    required this.serviceName,
    required this.isSaving,
    required this.error,
    required this.onConfirm,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final currentError = error;
    return AtelierBottomSheet(
      title: strings.servicesDeleteTitle,
      actions: [
        AtelierButton(
          text: strings.servicesDeleteConfirm,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: !isSaving,
          loading: isSaving,
        ),
        AtelierButton(
          text: strings.quotationRejectBack,
          onClick: onDismiss,
          style: AtelierButtonStyle.text,
          enabled: !isSaving,
        ),
      ],
      content: [
        Text(
          strings.servicesDeleteBody(serviceName),
          style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (currentError != null)
          AtelierBanner(message: currentError.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
