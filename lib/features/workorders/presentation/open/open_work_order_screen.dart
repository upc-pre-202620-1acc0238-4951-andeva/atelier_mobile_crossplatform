import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/bottom_action_bar.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/choice_chip.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/components/pick_row.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// US12: apertura de la orden de servicio (kilometraje, combustible, motivo y faenas). Se hace en línea. Al
/// quedar lista sigue con las fotos de recepción y, al volver, regresa a la búsqueda, no al formulario.
class OpenWorkOrderScreen extends StatefulWidget {
  final OpenWorkOrderArgs args;

  const OpenWorkOrderScreen({super.key, required this.args});

  @override
  State<OpenWorkOrderScreen> createState() => _OpenWorkOrderScreenState();
}

class _OpenWorkOrderScreenState extends State<OpenWorkOrderScreen> {
  late final OpenWorkOrderViewModel viewModel = getIt<OpenWorkOrderViewModel>(param1: widget.args);
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onState);
  }

  void _onState() {
    final done = viewModel.state.doneWorkOrderId;
    if (done == null || _opened) return;
    _opened = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppNavigator.pushReplacement<void, void>(context, AppRoute.intakeGallery, done);
    });
  }

  @override
  void dispose() {
    viewModel.removeListener(_onState);
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => OpenWorkOrderContent(
        state: viewModel.state,
        onBack: () => Navigator.of(context).maybePop(),
        onMileageChange: viewModel.onMileageChange,
        onFuelChange: viewModel.onFuelChange,
        onReasonChange: viewModel.onReasonChange,
        onToggleService: viewModel.onToggleService,
        onMechanicChange: viewModel.onMechanicChange,
        onRetryCatalog: viewModel.loadCatalog,
        onSubmit: viewModel.onSubmit,
      ),
    );
  }
}

class OpenWorkOrderContent extends StatelessWidget {
  final OpenWorkOrderUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onMileageChange;
  final ValueChanged<FuelLevel> onFuelChange;
  final ValueChanged<String> onReasonChange;
  final ValueChanged<String> onToggleService;
  final ValueChanged<String?> onMechanicChange;
  final VoidCallback onRetryCatalog;
  final VoidCallback onSubmit;

  const OpenWorkOrderContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onMileageChange,
    required this.onFuelChange,
    required this.onReasonChange,
    required this.onToggleService,
    required this.onMechanicChange,
    required this.onRetryCatalog,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.openOrderTitle, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  if (!state.hasPermission)
                    AtelierNoPermissionState(text: strings.receptionNoPermission)
                  else ...[
                    if (state.isCompletingDraft)
                      AtelierBanner(
                        message: strings.openOrderDraftNotice,
                        icon: Icons.info_outline,
                        kind: BannerKind.info,
                      ),
                    if (state.orderSaved)
                      AtelierBanner(
                        message: strings.openOrderSavedPendingTasks,
                        icon: Icons.info_outline,
                        kind: BannerKind.info,
                      ),
                    AtelierTextField(
                      label: strings.openOrderMileage,
                      value: state.mileage,
                      onValueChange: onMileageChange,
                      enabled: !state.formLocked,
                      isError: state.invalidField == 'mileageIn',
                      errorText: state.invalidField == 'mileageIn'
                          ? strings.openOrderFieldMileage
                          : null,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    AtelierSectionHeader(title: strings.openOrderFuel),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final level in FuelLevel.values)
                          WorkOrderChoiceChip(
                            label: _fuelLabel(strings, level),
                            selected: state.fuel == level,
                            enabled: !state.formLocked,
                            onClick: () => onFuelChange(level),
                          ),
                      ],
                    ),
                    AtelierTextField(
                      label: strings.openOrderReason,
                      value: state.reason,
                      onValueChange: onReasonChange,
                      enabled: !state.formLocked,
                      isError: state.invalidField == 'diagnosticSummary',
                      errorText: state.invalidField == 'diagnosticSummary'
                          ? strings.openOrderFieldReason
                          : null,
                    ),
                    if (!state.formLocked && state.reason.trim().isEmpty)
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final preset in [
                            strings.openOrderQuickReasonGeneral,
                            strings.openOrderQuickReasonPreventive,
                          ])
                            WorkOrderChoiceChip(
                              label: preset,
                              selected: false,
                              enabled: true,
                              onClick: () => onReasonChange(preset),
                            ),
                        ],
                      ),
                    _Catalog(
                      state: state,
                      onToggleService: onToggleService,
                      onMechanicChange: onMechanicChange,
                      onRetryCatalog: onRetryCatalog,
                    ),
                    if (error != null)
                      AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
                  ],
                ],
              ),
            ),
          ),
          if (state.hasPermission)
            WorkOrderBottomBar(
              children: [
                if (!state.isOnline) const AtelierRequiresConnection(),
                AtelierButton(
                  text: state.orderSaved ? strings.openOrderRetryTasks : strings.openOrderSubmit,
                  onClick: onSubmit,
                  enabled: state.canSubmit,
                  loading: state.isSaving,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Catalog extends StatelessWidget {
  final OpenWorkOrderUiState state;
  final ValueChanged<String> onToggleService;
  final ValueChanged<String?> onMechanicChange;
  final VoidCallback onRetryCatalog;

  const _Catalog({
    required this.state,
    required this.onToggleService,
    required this.onMechanicChange,
    required this.onRetryCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        AtelierSectionHeader(title: strings.openOrderTasks),
        if (state.isLoadingCatalog)
          DelayedLoading(
            loading: true,
            builder: (context, show) => show
                ? Column(
                    children: [
                      for (var i = 0; i < 3; i++)
                        const AtelierListRow(
                          title: 'Cambio de aceite',
                          subtitle: 'S/ 120.00',
                          loading: true,
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          )
        else if (state.services.isEmpty)
          AtelierEmptyState(
            text: strings.openOrderTasksEmpty,
            actionLabel: strings.commonRetry,
            onAction: onRetryCatalog,
          )
        else
          Column(
            children: [
              for (final service in state.services)
                _ServiceRow(
                  title: state.addedServiceIds.contains(service.id)
                      ? strings.openOrderTaskAdded(service.name)
                      : service.name,
                  subtitle: service.basePrice?.format(),
                  checked:
                      state.selectedServiceIds.contains(service.id) ||
                      state.addedServiceIds.contains(service.id),
                  enabled: !state.isSaving && !state.addedServiceIds.contains(service.id),
                  onToggle: () => onToggleService(service.id),
                ),
            ],
          ),
        if (state.mechanics.isNotEmpty) ...[
          AtelierSectionHeader(title: strings.openOrderMechanic),
          Column(
            children: [
              PickRow(
                title: strings.openOrderMechanicNone,
                selected: state.selectedMechanicId == null,
                enabled: !state.isSaving,
                onClick: () => onMechanicChange(null),
              ),
              for (final mechanic in state.mechanics)
                PickRow(
                  title: mechanic.displayName,
                  selected: state.selectedMechanicId == mechanic.membershipId,
                  enabled: !state.isSaving,
                  onClick: () => onMechanicChange(mechanic.membershipId),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Fila de selección múltiple: la marca es un ícono, no solo color.
class _ServiceRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool checked;
  final bool enabled;
  final VoidCallback onToggle;

  const _ServiceRow({
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.atelier;
    final subtitle = this.subtitle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          checked: checked,
          enabled: enabled,
          child: InkWell(
            onTap: enabled ? onToggle : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 12,
                  children: [
                    Icon(
                      checked ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                      size: 24,
                      color: checked ? scheme.primary : colors.muted,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.text.titleMedium?.copyWith(
                              color: enabled ? scheme.onSurface : colors.muted,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
      ],
    );
  }
}

String _fuelLabel(AppLocalizations strings, FuelLevel level) => switch (level) {
  FuelLevel.reserve => strings.fuelReserve,
  FuelLevel.quarter => strings.fuelQuarter,
  FuelLevel.half => strings.fuelHalf,
  FuelLevel.threeQuarters => strings.fuelThreeQuarters,
  FuelLevel.full => strings.fuelFull,
};
