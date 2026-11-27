import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_components.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/cashier_labels.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Series de facturación": información fiscal del taller (RUC, razón social, nombre comercial y PSE administrado)
/// más las series SUNAT de la sede (F001, B001, FC01…). Empujada desde Módulos.
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
    return StateSheetHost<SeriesSheet>(
      listenable: vm,
      value: () => vm.state.sheet,
      onDismiss: vm.onDismissSheet,
      sheetBuilder: (context, sheet) => SeriesSheets(
        state: vm.state,
        sheet: sheet,
        onType: vm.onType,
        onSerie: vm.onSerie,
        onInitial: vm.onInitial,
        onSave: vm.onSave,
        onToggleActive: vm.onToggleActive,
        onTenantName: vm.onTenantName,
        onTenantLegalName: vm.onTenantLegalName,
        onSaveTenant: vm.onSaveTenant,
        onDismiss: vm.onDismissSheet,
      ),
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => FiscalSeriesContent(
          state: vm.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRefresh: vm.refresh,
          onAdd: vm.onAdd,
          onOpenSeries: vm.onOpenSeries,
          onEditTenant: vm.onEditTenant,
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
  final ValueChanged<FiscalSeries> onOpenSeries;
  final VoidCallback onEditTenant;

  const FiscalSeriesContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onAdd,
    required this.onOpenSeries,
    required this.onEditTenant,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      floatingActionButton: state.canManage
          ? AtelierFab(text: strings.cashierSeriesAdd, icon: Icons.add, onClick: onAdd).floatingBarPadding()
          : null,
      body: Column(
        children: [
          AtelierTopBar(title: strings.cashierSeriesTitle, onBack: onBack),
          AtelierRefreshBar(visible: state.isRefreshing && state.hasLoaded),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: DelayedLoading(
                loading: state.showSkeleton && state.hasAccess,
                builder: (context, showSkeleton) => _list(context, strings, showSkeleton),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    const side = EdgeInsets.symmetric(horizontal: 16);
    const card = EdgeInsets.symmetric(horizontal: 16, vertical: 4);
    final error = state.error;
    final notice = state.notice;
    if (!state.hasAccess) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: side,
            child: AtelierNoPermissionState(text: strings.cashierSeriesNoAccess),
          ),
        ],
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (notice != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AtelierBanner(
              message: notice.asString(strings),
              icon: Icons.check_circle_outline,
              kind: BannerKind.ok,
            ),
          ),
        if (state.canReadTenant || state.canUpdateTenant || state.tenantProfile != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AtelierSectionHeader(title: strings.cashierFiscalTenantSection),
          ),
          Padding(
            padding: card,
            child: _TenantFiscalSectionCard(
              profile: state.tenantProfile,
              canUpdateTenant: state.canUpdateTenant,
              isOnline: state.isOnline,
              onEdit: onEditTenant,
            ),
          ),
        ],
        const Padding(padding: card, child: _PseManagedCard()),
        if (state.canManage) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: AtelierSectionHeader(title: strings.cashierSeriesBranchSection, count: state.series.length),
          ),
          Padding(
            padding: card,
            child: Text(
              strings.cashierSeriesNcHint,
              style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
            ),
          ),
        ],
        if (showSkeleton)
          for (var i = 0; i < 3; i++)
            AtelierListRow(
              title: 'B001',
              subtitle: '${voucherTypeLabel(strings, VoucherType.boleta)} · ${strings.cashierSeriesCorrelative(0)}',
              trailing: Text(strings.cashierSeriesActive, style: context.text.labelLarge),
              loading: true,
            )
        else if (state.showSkeleton)
          const SizedBox.shrink()
        else if (error != null && state.series.isEmpty)
          Padding(
            padding: side,
            child: state.isOnline
                ? AtelierErrorState(message: error.asString(strings), onRetry: () => onRefresh())
                : AtelierOfflineState(onRetry: () => onRefresh()),
          )
        else if (state.series.isEmpty && state.canManage)
          Padding(
            padding: side,
            child: AtelierEmptyState(
              text: strings.cashierSeriesEmpty,
              actionLabel: strings.cashierSeriesAdd,
              onAction: onAdd,
            ),
          )
        else
          for (final series in state.series)
            AtelierListRow(
              key: ValueKey('series-${series.id}'),
              title: series.serie,
              subtitle: [
                voucherTypeLabel(strings, series.type),
                strings.cashierSeriesCorrelative(series.currentCorrelative),
              ].join(' · '),
              onClick: () => onOpenSeries(series),
              trailing: AtelierChip(
                text: series.active ? strings.cashierSeriesActive : strings.cashierSeriesInactive,
                kind: series.active ? ChipKind.ok : ChipKind.idle,
              ),
            ),
      ],
    );
  }
}

class _TenantFiscalSectionCard extends StatelessWidget {
  final TenantFiscalProfile? profile;
  final bool canUpdateTenant;
  final bool isOnline;
  final VoidCallback onEdit;

  const _TenantFiscalSectionCard({
    required this.profile,
    required this.canUpdateTenant,
    required this.isOnline,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final profile = this.profile;
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          if (profile != null) ...[
            Text(
              profile.legalName.trim().isEmpty ? profile.name : profile.legalName,
              style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
            ),
            if (profile.name.trim().isNotEmpty && profile.name != profile.legalName)
              Text(profile.name, style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary)),
            if (profile.taxId.trim().isNotEmpty)
              Text(
                '${strings.cashierDocRuc}: ${profile.taxId}',
                style: context.text.labelLarge?.copyWith(color: colors.primaryText),
              ),
          ],
          if (canUpdateTenant)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AtelierButton(
                text: strings.cashierFiscalTenantEdit,
                onClick: onEdit,
                style: AtelierButtonStyle.tonal,
                enabled: isOnline,
              ),
            ),
        ],
      ),
    );
  }
}

class _PseManagedCard extends StatelessWidget {
  const _PseManagedCard();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  strings.cashierFiscalPseManagedTitle,
                  style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
                ),
              ),
              AtelierChip(text: strings.cashierSeriesActive, kind: ChipKind.ok),
            ],
          ),
          Text(
            strings.cashierFiscalPseManagedBody,
            style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary),
          ),
        ],
      ),
    );
  }
}

/// Hojas de la pantalla: nueva serie, detalle de una serie (activar o desactivar con su confirmación) y edición de
/// los datos fiscales del taller.
class SeriesSheets extends StatelessWidget {
  final FiscalSeriesUiState state;
  final SeriesSheet sheet;
  final ValueChanged<VoucherType> onType;
  final ValueChanged<String> onSerie;
  final ValueChanged<String> onInitial;
  final VoidCallback onSave;
  final VoidCallback onToggleActive;
  final ValueChanged<String> onTenantName;
  final ValueChanged<String> onTenantLegalName;
  final VoidCallback onSaveTenant;
  final VoidCallback onDismiss;

  const SeriesSheets({
    super.key,
    required this.state,
    required this.sheet,
    required this.onType,
    required this.onSerie,
    required this.onInitial,
    required this.onSave,
    required this.onToggleActive,
    required this.onTenantName,
    required this.onTenantLegalName,
    required this.onSaveTenant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.sheetError;
    final errorBanner = error == null
        ? null
        : AtelierBanner(message: error.asString(strings), icon: Icons.error_outline);
    final cancel = AtelierButton(
      text: strings.commonCancel,
      onClick: onDismiss,
      style: AtelierButtonStyle.text,
      enabled: !state.isSaving,
    );
    switch (sheet) {
      case CreateSeriesSheet(:final form):
        return AtelierBottomSheet(
          title: strings.cashierSeriesNewTitle,
          actions: [
            AtelierButton(
              text: strings.cashierSeriesSave,
              onClick: onSave,
              enabled: form.canSubmit && state.isOnline,
              loading: state.isSaving,
            ),
            if (!state.isOnline) const AtelierRequiresConnection(),
            cancel,
          ],
          content: [..._formContent(context, strings, form), ?errorBanner],
        );
      case SeriesDetailSheet(:final series):
        return AtelierBottomSheet(
          title: strings.cashierSeriesDetailTitle(series.serie),
          actions: [
            AtelierButton(
              text: series.active ? strings.cashierSeriesDeactivate : strings.cashierSeriesActivate,
              onClick: onToggleActive,
              style: series.active ? AtelierButtonStyle.destructive : AtelierButtonStyle.filled,
              enabled: state.isOnline,
              loading: state.isSaving,
            ),
            if (!state.isOnline) const AtelierRequiresConnection(),
            cancel,
          ],
          content: [
            Text(
              [
                voucherTypeLabel(strings, series.type),
                strings.cashierSeriesCorrelative(series.currentCorrelative),
              ].join(' · '),
              style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
            ),
            Text(
              series.active ? strings.cashierSeriesDeactivateBody : strings.cashierSeriesActivateBody,
              style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
            ),
            ?errorBanner,
          ],
        );
      case EditTenantSheet(:final form):
        final nameInvalid = form.name.isNotEmpty && !form.nameValid;
        final legalInvalid = form.legalName.isNotEmpty && !form.legalNameValid;
        return AtelierBottomSheet(
          title: strings.cashierFiscalTenantSection,
          actions: [
            AtelierButton(
              text: strings.cashierFiscalTenantSave,
              onClick: onSaveTenant,
              enabled: form.canSubmit && state.isOnline,
              loading: state.isSaving,
            ),
            if (!state.isOnline) const AtelierRequiresConnection(),
            cancel,
          ],
          content: [
            if (form.taxId.trim().isNotEmpty)
              AtelierTextField(
                label: strings.cashierFiscalTenantRuc,
                value: form.taxId,
                onValueChange: (_) {},
                enabled: false,
              ),
            AtelierTextField(
              label: strings.cashierFiscalTenantLegalName,
              value: form.legalName,
              onValueChange: onTenantLegalName,
              isError: legalInvalid,
              errorText: legalInvalid ? strings.cashierErrTenantName : null,
            ),
            AtelierTextField(
              label: strings.cashierFiscalTenantName,
              value: form.name,
              onValueChange: onTenantName,
              isError: nameInvalid,
              errorText: nameInvalid ? strings.cashierErrTenantName : null,
            ),
            ?errorBanner,
          ],
        );
    }
  }

  List<Widget> _formContent(BuildContext context, AppLocalizations strings, SeriesForm form) {
    final serieInvalid = form.serie.length == 4 && !form.serieValid;
    final placeholder = switch (form.type) {
      VoucherType.factura => 'F001',
      VoucherType.boleta => 'B001',
      VoucherType.notaCredito => 'FC01',
    };
    return [
      Text(
        strings.cashierSeriesType,
        style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
      ),
      ChoiceGrid<VoucherType>(
        options: const [VoucherType.boleta, VoucherType.factura, VoucherType.notaCredito],
        selected: form.type,
        label: (type) => voucherTypeLabel(strings, type),
        onSelect: onType,
        enabled: !state.isSaving,
      ),
      AtelierTextField(
        label: strings.cashierSeriesSerie,
        value: form.serie,
        onValueChange: onSerie,
        placeholder: placeholder,
        isError: serieInvalid,
        errorText: serieInvalid
            ? (form.type == VoucherType.notaCredito ? strings.cashierNcSerieError : strings.cashierSeriesSerieError)
            : null,
        enabled: !state.isSaving,
        textCapitalization: TextCapitalization.characters,
        autocorrect: false,
        inputFormatters: [LengthLimitingTextInputFormatter(4), FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]'))],
      ),
      AtelierTextField(
        label: strings.cashierSeriesInitial,
        value: form.initial,
        onValueChange: onInitial,
        isError: !form.initialValid,
        errorText: !form.initialValid ? strings.cashierSeriesInitialError : null,
        enabled: !state.isSaving,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    ];
  }
}
