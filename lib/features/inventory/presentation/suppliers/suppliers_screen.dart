import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_navigation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Catálogo buscable de proveedores con alta y edición en hoja inferior (`SUPPLIERS_MANAGE`).
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final SuppliersViewModel viewModel = getIt<SuppliersViewModel>();
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
      value: () => viewModel.state.sheetOpen ? true : null,
      onDismiss: viewModel.onDismissSheet,
      sheetBuilder: (context, _) => SupplierFormSheetContent(
        state: viewModel.state,
        onDismiss: () => Navigator.of(context).maybePop(),
        onBusinessNameChange: viewModel.onBusinessNameChange,
        onTaxIdChange: viewModel.onTaxIdChange,
        onContactNameChange: viewModel.onContactNameChange,
        onPhoneChange: viewModel.onPhoneChange,
        onEmailChange: viewModel.onEmailChange,
        onAddressChange: viewModel.onAddressChange,
        onActiveChange: viewModel.onActiveChange,
        onSave: viewModel.onSave,
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => SuppliersContent(
          state: viewModel.state,
          onBack: inventoryBack(context),
          onQueryChange: viewModel.onQueryChange,
          onRefresh: viewModel.refresh,
          onOpenCreate: viewModel.onOpenCreate,
          onOpenEdit: viewModel.onOpenEdit,
        ),
      ),
    );
  }
}

class SuppliersContent extends StatelessWidget {
  final SuppliersUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onQueryChange;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenCreate;
  final ValueChanged<Supplier> onOpenEdit;

  const SuppliersContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onQueryChange,
    required this.onRefresh,
    required this.onOpenCreate,
    required this.onOpenEdit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canManage
          ? AtelierFab(text: strings.invSeg2SuppliersNewFab, icon: Icons.add, onClick: onOpenCreate)
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.invSeg2SuppliersTitle, onBack: onBack),
          if (!state.canManage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierNoPermissionState(text: strings.invSeg2SuppliersNoPermission),
            )
          else ...[
            AtelierRefreshBar(visible: state.isLoading && state.suppliers.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: DelayedLoading(
                  loading: state.suppliers.isEmpty && state.isLoading,
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
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: AtelierTextField(
            label: strings.invSeg2SuppliersSearchLabel,
            value: state.query,
            onValueChange: onQueryChange,
            leadingIcon: Icons.search,
            placeholder: strings.invSeg2SuppliersSearchHint,
            textInputAction: TextInputAction.search,
            trailing: state.query.isNotEmpty
                ? IconButton(
                    onPressed: () => onQueryChange(''),
                    tooltip: strings.invSeg2Clear,
                    icon: const Icon(Icons.close),
                  )
                : null,
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
        if (showSkeleton)
          for (var i = 0; i < 5; i++)
            const AtelierListRow(
              title: 'Distribuidora Automotriz SAC',
              subtitle: 'RUC 20512345678 · Carlos Ruiz',
              loading: true,
            )
        else if (state.suppliers.isEmpty && error != null && !state.isOnline)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierOfflineState(onRetry: onRefresh),
          )
        else if (state.suppliers.isEmpty && error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
          )
        else if (state.suppliers.isEmpty && !state.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AtelierEmptyState(
              text: state.query.trim().isNotEmpty
                  ? strings.invSeg2SuppliersEmptyFiltered
                  : strings.invSeg2SuppliersEmpty,
            ),
          )
        else
          for (final supplier in state.suppliers)
            _SupplierRow(
              key: ValueKey(supplier.id),
              supplier: supplier,
              onClick: () => onOpenEdit(supplier),
            ),
      ],
    );
  }
}

class _SupplierRow extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onClick;

  const _SupplierRow({super.key, required this.supplier, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final subtitle = [
      strings.invSeg2SuppliersTaxIdLine(supplier.taxId),
      ?supplier.contactName,
      ?supplier.phone,
    ].join(' · ');
    return AtelierListRow(
      title: supplier.businessName,
      subtitle: subtitle,
      onClick: onClick,
      trailing: AtelierChip(
        text: supplier.active ? strings.invSeg2SuppliersActive : strings.invSeg2SuppliersInactive,
        kind: supplier.active ? ChipKind.ok : ChipKind.idle,
      ),
    );
  }
}

class SupplierFormSheetContent extends StatelessWidget {
  final SuppliersUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<String> onBusinessNameChange;
  final ValueChanged<String> onTaxIdChange;
  final ValueChanged<String> onContactNameChange;
  final ValueChanged<String> onPhoneChange;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onAddressChange;
  final ValueChanged<bool> onActiveChange;
  final VoidCallback onSave;

  const SupplierFormSheetContent({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onBusinessNameChange,
    required this.onTaxIdChange,
    required this.onContactNameChange,
    required this.onPhoneChange,
    required this.onEmailChange,
    required this.onAddressChange,
    required this.onActiveChange,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final enabled = !state.isSaving;
    return AtelierBottomSheet(
      title: state.isEditing ? strings.invSeg2SuppliersEditTitle : strings.invSeg2SuppliersCreateTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.invSeg2Save,
          onClick: onSave,
          enabled: state.isOnline && !state.isSaving,
          loading: state.isSaving,
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
          label: strings.invSeg2SupplierBusinessName,
          value: state.businessName,
          onValueChange: onBusinessNameChange,
          isError: state.nameError != null,
          errorText: state.nameError?.asString(strings),
          enabled: enabled,
        ),
        AtelierTextField(
          label: strings.invSeg2SupplierTaxId,
          value: state.taxId,
          onValueChange: onTaxIdChange,
          isError: state.taxIdError != null,
          errorText: state.taxIdError?.asString(strings),
          enabled: !state.isEditing && enabled,
          keyboardType: TextInputType.number,
        ),
        AtelierTextField(
          label: strings.invSeg2SupplierContact,
          value: state.contactName,
          onValueChange: onContactNameChange,
          enabled: enabled,
        ),
        AtelierTextField(
          label: strings.invSeg2SupplierPhone,
          value: state.phone,
          onValueChange: onPhoneChange,
          enabled: enabled,
          keyboardType: TextInputType.phone,
        ),
        AtelierTextField(
          label: strings.invSeg2SupplierEmail,
          value: state.email,
          onValueChange: onEmailChange,
          isError: state.emailError != null,
          errorText: state.emailError?.asString(strings),
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
        ),
        AtelierTextField(
          label: strings.invSeg2SupplierAddress,
          value: state.address,
          onValueChange: onAddressChange,
          enabled: enabled,
        ),
        if (state.isEditing)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.invSeg2SupplierActiveToggle,
                style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
              ),
              Switch(value: state.active, onChanged: enabled ? onActiveChange : null),
            ],
          ),
        if (state.submitError case final error?)
          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
      ],
    );
  }
}
