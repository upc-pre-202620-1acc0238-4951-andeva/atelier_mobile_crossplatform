import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_adaptive_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
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
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/date_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/document_intents.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

const _placeholderTotal = 'S/ 0.00';

enum _PeriodTab { thisMonth, previousMonth, thisYear, custom }

_PeriodTab _tabOf(PeriodChoice choice) => switch (choice) {
  ThisMonthChoice() => _PeriodTab.thisMonth,
  PreviousMonthChoice() => _PeriodTab.previousMonth,
  ThisYearChoice() => _PeriodTab.thisYear,
  CustomChoice() => _PeriodTab.custom,
};

/// "Reportes": el flujo de caja del taller en un periodo (todas las sedes, no solo la de la sesión) con su PDF
/// (US41), y el PDF consolidado de salud de la flota de un cliente (US43 E2). No muestra egresos ni cuentas por
/// cobrar: el backend los envía siempre en 0 (H31).
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportsViewModel viewModel = getIt<ReportsViewModel>();
  final AtelierHaptics _haptics = rememberAtelierHaptics();
  Object? _lastError;
  bool _pickerOpen = false;
  File? _handlingPdf;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_onChange);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onChange);
    viewModel.dispose();
    super.dispose();
  }

  void _onChange() {
    final state = viewModel.state;
    final err = state.actionError ?? state.error;
    if (err != null && !identical(err, _lastError)) {
      _haptics.reject();
    }
    _lastError = err;
    if (state.showCustomRangePicker && !_pickerOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openRangePicker());
    }
    final file = state.pdf;
    if (file != null && !identical(file, _handlingPdf)) {
      _handlingPdf = file;
      final mode = state.pdfActionMode;
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPdf(file, mode));
    }
  }

  Future<void> _openPdf(File file, ReportPdfActionMode mode) async {
    if (!mounted) return;
    final title = AppLocalizations.of(context).reportsPdfChooser;
    final opened = switch (mode) {
      ReportPdfActionMode.open => await DocumentIntents.openPdf(file, title),
      ReportPdfActionMode.share => await DocumentIntents.sharePdf(file, title),
    };
    _handlingPdf = null;
    if (!mounted) return;
    if (opened) {
      viewModel.onPdfHandled();
    } else {
      viewModel.onPdfOpenFailed();
    }
  }

  /// `DateRangePicker` de Material 3 en un diálogo, con el periodo vigente preseleccionado.
  Future<void> _openRangePicker() async {
    if (!mounted || _pickerOpen || !viewModel.state.showCustomRangePicker) {
      return;
    }
    _pickerOpen = true;
    final strings = AppLocalizations.of(context);
    final period = viewModel.state.period;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _parseDay(period.from), end: _parseDay(period.to)),
      confirmText: strings.commonConfirm,
      cancelText: strings.commonCancel,
    );
    _pickerOpen = false;
    if (range == null) {
      viewModel.onDismissCustomRange();
    } else {
      viewModel.onCustomRangePicked(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<FleetSheet>(
      listenable: viewModel,
      value: () => viewModel.state.fleetSheet,
      onDismiss: viewModel.onDismissFleet,
      sheetBuilder: (context, sheet) => FleetSheetContent(
        sheet: sheet,
        busy: viewModel.state.busy == ReportDownload.fleetHealth,
        online: viewModel.state.isOnline,
        onActionMode: viewModel.onFleetActionMode,
        onQuery: viewModel.onFleetQuery,
        onSearch: viewModel.onFleetSearch,
        onPick: (customer) {
          _haptics.confirm();
          viewModel.onFleetPick(customer);
        },
      ),
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ReportsContent(
          state: viewModel.state,
          onBack: () => Navigator.of(context).maybePop(),
          onRetry: viewModel.load,
          onChoice: viewModel.onChoice,
          onOpenCustomRange: viewModel.onOpenCustomRange,
          onOpenCashFlowPdf: () {
            _haptics.confirm();
            viewModel.onOpenCashFlowPdf();
          },
          onShareCashFlowPdf: () {
            _haptics.confirm();
            viewModel.onShareCashFlowPdf();
          },
          onOpenFleet: viewModel.onOpenFleet,
        ),
      ),
    );
  }
}

DateTime _parseDay(String day) => DateTime.parse('${day}T00:00:00');

/// `yyyy-MM-dd` como `dd/MM/yyyy`.
String _formatDay(String day) {
  final parts = day.split('-');
  if (parts.length != 3) return day;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

class ReportsContent extends StatelessWidget {
  final ReportsUiState state;
  final VoidCallback onBack;
  final Future<void> Function() onRetry;
  final ValueChanged<PeriodChoice> onChoice;
  final VoidCallback onOpenCustomRange;
  final VoidCallback? onOpenCashFlowPdf;
  final VoidCallback? onShareCashFlowPdf;
  final VoidCallback? onOpenFleet;

  const ReportsContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRetry,
    required this.onChoice,
    required this.onOpenCustomRange,
    this.onOpenCashFlowPdf,
    this.onShareCashFlowPdf,
    this.onOpenFleet,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final summary = state.summary;
    final rawSkeleton = state.canReadCashFlow && state.isLoading && summary == null && state.error == null;
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.reportsTitle, onBack: onBack),
          Expanded(
            child: DelayedLoading(
              loading: rawSkeleton,
              builder: (context, showSkeleton) => RefreshIndicator(
                onRefresh: onRetry,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: _items(context, strings, summary, rawSkeleton, showSkeleton),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _items(
    BuildContext context,
    AppLocalizations strings,
    CashFlowSummary? summary,
    bool rawSkeleton,
    bool showSkeleton,
  ) {
    const side = EdgeInsets.symmetric(horizontal: 16);
    return [
      if (state.canReadCashFlow)
        AtelierReportPanel(
          context: strings.reportsContext,
          legend: summary?.totalIncome.format() ?? _placeholderTotal,
          caption: strings.reportsLegendCaption,
          loading: showSkeleton,
          figures: summary == null
              ? const []
              : [
                  PanelFigure(
                    value: summary.movements.length.toString(),
                    label: strings.reportsMovementsLabel(summary.movements.length),
                  ),
                ],
        ),
      AtelierRefreshBar(visible: state.isLoading && summary != null),
      if (!state.hasAnyAccess)
        Padding(
          padding: side,
          child: AtelierNoPermissionState(text: strings.reportsNoAccess),
        )
      else ...[
        if (state.canReadFleetHealth || state.fleetLockedByPlan)
          _FleetHealthSection(state: state, onOpenFleet: onOpenFleet ?? () {}),
        if (state.canReadCashFlow) ..._cashFlow(context, strings, summary, rawSkeleton, showSkeleton),
      ],
    ];
  }

  List<Widget> _cashFlow(
    BuildContext context,
    AppLocalizations strings,
    CashFlowSummary? summary,
    bool rawSkeleton,
    bool showSkeleton,
  ) {
    const side = EdgeInsets.symmetric(horizontal: 16);
    return [
      ...[
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              AtelierBanner(message: strings.reportsScopeNote, icon: Icons.info_outlined, kind: BannerKind.info),
              Text(
                strings.reportsH31IncomeOnlyNote,
                style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary),
              ),
            ],
          ),
        ),
        _PeriodSelector(
          choice: state.choice,
          period: state.period,
          onChoice: onChoice,
          onOpenCustomRange: onOpenCustomRange,
        ),
        _Downloads(
          state: state,
          onOpenCashFlowPdf: onOpenCashFlowPdf ?? () {},
          onShareCashFlowPdf: onShareCashFlowPdf ?? () {},
        ),
        Padding(
          padding: side,
          child: AtelierSectionHeader(title: strings.reportsMovementsHeader, count: summary?.movements.length),
        ),
        if (showSkeleton)
          for (var i = 0; i < 3; i++)
            const AtelierListRow(title: 'Concepto del cobro', subtitle: '16/11/2026', loading: true)
        else if (rawSkeleton)
          const SizedBox.shrink()
        else if (summary == null)
          Padding(
            padding: side,
            child: state.isOnline
                ? AtelierErrorState(message: state.error?.asString(strings) ?? '', onRetry: () => onRetry())
                : AtelierOfflineState(onRetry: () => onRetry()),
          )
        else if (summary.movements.isEmpty)
          Padding(
            padding: side,
            child: AtelierEmptyState(text: strings.reportsMovementsEmpty),
          )
        else
          for (final movement in summary.movements)
            AtelierListRow(
              key: ValueKey(movement.transactionId),
              title: movement.concept.trim().isEmpty ? movement.category : movement.concept,
              subtitle: strings.reportsMovementDetail(movement.movementDate.formatLimaDate(), movement.referenceNumber),
              trailing: Text(
                _movementAmount(movement.amount, summary.currency),
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ),
      ],
    ];
  }
}

/// Importe con símbolo; los negativos llevan el signo menos tipográfico delante.
String _movementAmount(Decimal amount, String currency) {
  final money = Money(amount: amount.abs(), currency: currency == Money.usd ? Money.usd : Money.pen).format();
  return amount < Decimal.zero ? '−$money' : money;
}

class _Downloads extends StatelessWidget {
  final ReportsUiState state;
  final VoidCallback onOpenCashFlowPdf;
  final VoidCallback onShareCashFlowPdf;

  const _Downloads({required this.state, required this.onOpenCashFlowPdf, required this.onShareCashFlowPdf});

  @override
  Widget build(BuildContext context) {
    if (!state.canReadCashFlow) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierSectionHeader(title: strings.reportsDownloadsHeader),
          AtelierSurface(
            tier: SurfaceTier.elevated,
            shape: cardLargeShape,
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Text(
                  strings.reportsDownloadCashflow,
                  style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
                ),
                AtelierAdaptiveRow(
                  equalWidthInRow: true,
                  children: [
                    AtelierButton(
                      text: strings.reportsOpenPdf,
                      onClick: onOpenCashFlowPdf,
                      style: AtelierButtonStyle.tonal,
                      enabled: state.isOnline && state.busy == null,
                      loading: state.busy == ReportDownload.cashFlow && state.pdfActionMode == ReportPdfActionMode.open,
                    ),
                    AtelierButton(
                      text: strings.reportsSharePdf,
                      onClick: onShareCashFlowPdf,
                      style: AtelierButtonStyle.outlined,
                      enabled: state.isOnline && state.busy == null,
                      loading:
                          state.busy == ReportDownload.cashFlow && state.pdfActionMode == ReportPdfActionMode.share,
                    ),
                  ],
                ),
                if (!state.isOnline) const AtelierRequiresConnection(),
                if (state.actionError != null)
                  AtelierBanner(message: state.actionError!.asString(strings), icon: Icons.error_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final PeriodChoice choice;
  final ReportPeriod period;
  final ValueChanged<PeriodChoice> onChoice;
  final VoidCallback onOpenCustomRange;

  const _PeriodSelector({
    required this.choice,
    required this.period,
    required this.onChoice,
    required this.onOpenCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            AtelierSegmentedControl<_PeriodTab>(
              options: _PeriodTab.values,
              selected: _tabOf(choice),
              onSelect: (tab) => switch (tab) {
                _PeriodTab.thisMonth => onChoice(PeriodChoice.thisMonth),
                _PeriodTab.previousMonth => onChoice(PeriodChoice.previousMonth),
                _PeriodTab.thisYear => onChoice(PeriodChoice.thisYear),
                _PeriodTab.custom => onOpenCustomRange(),
              },
              label: (tab) => switch (tab) {
                _PeriodTab.thisMonth => strings.reportsPeriodMonth,
                _PeriodTab.previousMonth => strings.reportsPeriodPreviousMonth,
                _PeriodTab.thisYear => strings.reportsPeriodYear,
                _PeriodTab.custom => strings.reportsPeriodCustom,
              },
            ),
            Text(
              strings.reportsPeriodRange(_formatDay(period.from), _formatDay(period.to)),
              style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// US43 E2: botón que abre la hoja para elegir al cliente y bajar el PDF consolidado de salud de su flota. Con el
/// permiso pero sin IA en el plan, solo se dice que no está incluida. Solo en línea.
class _FleetHealthSection extends StatelessWidget {
  final ReportsUiState state;
  final VoidCallback onOpenFleet;

  const _FleetHealthSection({required this.state, required this.onOpenFleet});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierSectionHeader(title: strings.reportsFleetTitle),
          AtelierSurface(
            tier: SurfaceTier.elevated,
            shape: cardLargeShape,
            contentPadding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                if (state.canReadFleetHealth)
                  AtelierButton(
                    text: strings.reportsDownloadFleet,
                    onClick: onOpenFleet,
                    style: AtelierButtonStyle.outlined,
                    enabled: state.isOnline && state.busy == null,
                  ),
                if (state.fleetLockedByPlan) AtelierPlanLockedState(text: strings.reportsFleetLocked),
                if (!state.isOnline) const AtelierRequiresConnection(),
                if (state.actionError != null && !state.canReadCashFlow)
                  AtelierBanner(message: state.actionError!.asString(strings), icon: Icons.error_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hoja de salud de flota: modo (abrir o compartir), búsqueda del cliente y resultados; elegir uno descarga el PDF.
class FleetSheetContent extends StatelessWidget {
  final FleetSheet sheet;
  final bool busy;
  final bool online;
  final ValueChanged<ReportPdfActionMode> onActionMode;
  final ValueChanged<String> onQuery;
  final VoidCallback onSearch;
  final ValueChanged<FleetCustomer> onPick;

  const FleetSheetContent({
    super.key,
    required this.sheet,
    required this.busy,
    required this.online,
    required this.onActionMode,
    required this.onQuery,
    required this.onSearch,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final error = sheet.error;
    return AtelierBottomSheet(
      title: strings.reportsFleetTitle,
      actions: [
        AtelierButton(
          text: strings.reportsFleetSearchAction,
          onClick: onSearch,
          enabled: sheet.query.trim().isNotEmpty && !busy,
          loading: sheet.isSearching,
        ),
        if (!online) const AtelierRequiresConnection(),
      ],
      content: [
        Text(strings.reportsFleetHint, style: context.text.bodyLarge?.copyWith(color: colors.inkSecondary)),
        Text(strings.reportsFleetScopeNote, style: context.text.bodySmall?.copyWith(color: colors.inkSecondary)),
        AtelierSegmentedControl<ReportPdfActionMode>(
          options: ReportPdfActionMode.values,
          selected: sheet.actionMode,
          onSelect: onActionMode,
          label: (mode) => switch (mode) {
            ReportPdfActionMode.open => strings.reportsOpenPdf,
            ReportPdfActionMode.share => strings.reportsSharePdf,
          },
        ),
        AtelierTextField(label: strings.reportsFleetSearch, value: sheet.query, onValueChange: onQuery),
        if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
        if (sheet.hasSearched && sheet.results.isEmpty && error == null)
          AtelierEmptyState(text: strings.reportsFleetEmpty)
        else
          for (final customer in sheet.results)
            AtelierListRow(
              key: ValueKey('fleet-customer-${customer.id}'),
              title: customer.name,
              subtitle: customer.taxId,
              onClick: online && !busy ? () => onPick(customer) : null,
            ),
      ],
    );
  }
}
