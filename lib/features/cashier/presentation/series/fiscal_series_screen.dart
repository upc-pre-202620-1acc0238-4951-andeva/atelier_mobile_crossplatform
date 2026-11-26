import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Series de comprobantes de la sede (US42): lista con tipo, serie, correlativo y estado; agregar una serie nueva y
/// activar o desactivar las existentes. Requiere `invoicing:fiscal_config:manage`. Empujada desde Módulos.
class FiscalSeriesScreen extends StatefulWidget {
  const FiscalSeriesScreen({super.key});

  @override
  State<FiscalSeriesScreen> createState() => _FiscalSeriesScreenState();
}

class _FiscalSeriesScreenState extends State<FiscalSeriesScreen> {
  late final FiscalSeriesViewModel viewModel = getIt<FiscalSeriesViewModel>();
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
      value: () => vm.state.showSheet ? true : null,
      onDismiss: vm.onDismissSheet,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: vm,
        builder: (context, _) => AddSeriesSheet(
          state: vm.state,
          onDismiss: vm.onDismissSheet,
          onTypeChange: vm.onTypeChange,
          onSerieChange: vm.onSerieChange,
          onInitialChange: vm.onInitialChange,
          onConfirm: vm.onConfirm,
        ),
      ),
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => FiscalSeriesContent(
          state: vm.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: vm.refresh,
          onAdd: vm.onOpenSheet,
          onToggle: vm.onToggleActive,
        ),
      ),
    );
  }
}

class FiscalSeriesContent extends StatelessWidget {
  final FiscalSeriesUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onAdd;
  final ValueChanged<FiscalSeries> onToggle;

  const FiscalSeriesContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onAdd,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final active = state.series.where((s) => s.active).toList();
    final facturas = active.where((s) => s.type == VoucherType.factura).length;
    final boletas = active.where((s) => s.type == VoucherType.boleta).length;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AtelierTopBar(title: strings.fiscalSeriesTitle, onBack: onBack),
            if (!state.canManage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AtelierNoPermissionState(
                  text: strings.fiscalSeriesNoPermission,
                ),
              )
            else ...[
              AtelierReportPanel(
                context: strings.fiscalSeriesContext,
                legend: active.length.toString(),
                caption: strings.fiscalSeriesCaption,
                loading: state.isLoading && state.series.isEmpty,
                figures: [
                  PanelFigure(
                    value: facturas.toString(),
                    label: strings.fiscalSeriesFigFactura,
                  ),
                  PanelFigure(
                    value: boletas.toString(),
                    label: strings.fiscalSeriesFigBoleta,
                  ),
                ],
              ),
              AtelierRefreshBar(
                visible: state.isLoading && state.series.isNotEmpty,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: onRefresh,
                  child: DelayedLoading(
                    loading: state.isLoading && state.series.isEmpty,
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
    const side = EdgeInsets.symmetric(horizontal: 16);
    final error = state.error;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AtelierBanner(
            message: strings.fiscalSeriesPse,
            icon: Icons.verified_outlined,
            kind: BannerKind.info,
          ),
        ),
        if (state.banner case final banner?)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AtelierBanner(
              message: banner.asString(strings),
              icon: Icons.check_circle_outline,
              kind: BannerKind.ok,
            ),
          ),
        if (state.actionError case final err?)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AtelierBanner(
              message: err.asString(strings),
              icon: Icons.error_outline,
            ),
          ),
        Padding(
          padding: side,
          child: AtelierSectionHeader(
            title: strings.fiscalSeriesListHeader,
            count: state.series.length,
            action: AtelierButton(
              text: strings.fiscalSeriesAdd,
              onClick: onAdd,
              style: AtelierButtonStyle.text,
              icon: Icons.add,
              enabled: state.isOnline,
            ),
          ),
        ),
        if (!state.isOnline)
          const Padding(padding: side, child: AtelierRequiresConnection()),
        if (showBones)
          for (var i = 0; i < 3; i++)
            const AtelierListRow(
              title: 'F001',
              subtitle: 'Factura · correlativo actual 45',
              loading: true,
            )
        else if (state.series.isEmpty && !state.isOnline)
          Padding(
            padding: side,
            child: AtelierOfflineState(onRetry: onRefresh),
          )
        else if (state.series.isEmpty && error != null)
          Padding(
            padding: side,
            child: AtelierErrorState(
              message: error.asString(strings),
              onRetry: onRefresh,
            ),
          )
        else if (state.series.isEmpty)
          Padding(
            padding: side,
            child: AtelierEmptyState(text: strings.fiscalSeriesEmpty),
          )
        else
          for (final series in state.series)
            AtelierListRow(
              key: ValueKey('series-${series.id}'),
              title: series.serie,
              subtitle: strings.fiscalSeriesRowSub(
                voucherTypeLabel(strings, series.type),
                series.currentCorrelative.toString(),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  AtelierChip(
                    text: series.active
                        ? strings.fiscalSeriesActive
                        : strings.fiscalSeriesInactive,
                    kind: series.active ? ChipKind.ok : ChipKind.idle,
                  ),
                  Semantics(
                    label: strings.fiscalSeriesToggleLabel(series.serie),
                    child: Switch(
                      value: series.active,
                      onChanged: state.isOnline && state.togglingId == null
                          ? (_) => onToggle(series)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Hoja "Agregar serie": tipo (factura o boleta), serie de 4 caracteres y correlativo inicial opcional. Una serie
/// repetida la rechaza el backend y su mensaje aparece al pie (US42 E2).
class AddSeriesSheet extends StatelessWidget {
  final FiscalSeriesUiState state;
  final VoidCallback onDismiss;
  final ValueChanged<VoucherType> onTypeChange;
  final ValueChanged<String> onSerieChange;
  final ValueChanged<String> onInitialChange;
  final VoidCallback onConfirm;

  const AddSeriesSheet({
    super.key,
    required this.state,
    required this.onDismiss,
    required this.onTypeChange,
    required this.onSerieChange,
    required this.onInitialChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final enabled = !state.isSaving;
    return AtelierBottomSheet(
      title: strings.fiscalSeriesSheetTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.fiscalSeriesSave,
          onClick: onConfirm,
          enabled: state.isOnline && enabled,
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
        Text(
          strings.fiscalSeriesSheetBody,
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
        AtelierSegmentedControl<VoucherType>(
          options: FiscalSeriesUiState.configurableTypes,
          selected: state.type,
          onSelect: (type) {
            if (enabled) onTypeChange(type);
          },
          label: (type) => voucherTypeLabel(strings, type),
        ),
        AtelierTextField(
          label: strings.fiscalSeriesSerieLabel,
          value: state.serie,
          onValueChange: onSerieChange,
          placeholder: state.type == VoucherType.boleta ? 'B001' : 'F001',
          isError: state.serieError != null,
          errorText: state.serieError?.asString(strings),
          enabled: enabled,
          textCapitalization: TextCapitalization.characters,
          autocorrect: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          ],
        ),
        AtelierTextField(
          label: strings.fiscalSeriesInitialLabel,
          value: state.initialCorrelative,
          onValueChange: onInitialChange,
          isError: state.initialError != null,
          errorText: state.initialError?.asString(strings),
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        if (state.formError case final err?)
          AtelierBanner(
            message: err.asString(strings),
            icon: Icons.error_outline,
          ),
      ],
    );
  }
}
