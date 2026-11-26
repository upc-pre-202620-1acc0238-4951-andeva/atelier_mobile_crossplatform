import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';

enum ReportDownload { cashFlow, fleetHealth }

enum ReportPdfActionMode { open, share }

/// Periodo elegido en el selector. Los días son de Lima (`yyyy-MM-dd`).
sealed class PeriodChoice {
  const PeriodChoice();

  static const thisMonth = ThisMonthChoice();
  static const previousMonth = PreviousMonthChoice();
  static const thisYear = ThisYearChoice();
}

class ThisMonthChoice extends PeriodChoice {
  const ThisMonthChoice();
}

class PreviousMonthChoice extends PeriodChoice {
  const PreviousMonthChoice();
}

class ThisYearChoice extends PeriodChoice {
  const ThisYearChoice();
}

class CustomChoice extends PeriodChoice {
  final String from;
  final String to;

  const CustomChoice(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      other is CustomChoice && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// El rango de días de [choice] visto desde [today] (día de Lima, `yyyy-MM-dd`).
ReportPeriod periodFor(PeriodChoice choice, String today) {
  final day = DateTime.parse('${today}T00:00:00Z');
  return switch (choice) {
    ThisMonthChoice() => ReportPeriod.month(day.year, day.month),
    PreviousMonthChoice() => () {
      // `DateTime.utc(año, 0)` es diciembre del año anterior.
      final previous = DateTime.utc(day.year, day.month - 1);
      return ReportPeriod.month(previous.year, previous.month);
    }(),
    ThisYearChoice() => ReportPeriod.year(day.year),
    CustomChoice(:final from, :final to) =>
      from.compareTo(to) <= 0 ? ReportPeriod(from, to) : ReportPeriod(to, from),
  };
}

/// Cliente elegido para el consolidado de salud de flota (US43 E2).
class FleetCustomer {
  final String id;
  final String name;
  final String? taxId;

  const FleetCustomer({required this.id, required this.name, this.taxId});
}

/// Hoja para elegir al cliente del informe de salud de flota (US43 E2).
class FleetSheet {
  final String query;
  final List<FleetCustomer> results;
  final bool hasSearched;
  final bool isSearching;
  final ReportPdfActionMode actionMode;
  final UiText? error;

  const FleetSheet({
    this.query = '',
    this.results = const [],
    this.hasSearched = false,
    this.isSearching = false,
    this.actionMode = ReportPdfActionMode.open,
    this.error,
  });

  FleetSheet copyWith({
    String? query,
    List<FleetCustomer>? results,
    bool? hasSearched,
    bool? isSearching,
    ReportPdfActionMode? actionMode,
    UiText? error,
    bool clearError = false,
  }) {
    return FleetSheet(
      query: query ?? this.query,
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
      isSearching: isSearching ?? this.isSearching,
      actionMode: actionMode ?? this.actionMode,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// Reportes del taller: flujo de caja del periodo (todas las sedes, H30) y exportación PDF (US41), y el PDF
/// consolidado de salud de la flota de un cliente (US43 E2).
/// Nunca se muestran `totalExpenses` ni `accountsReceivable`: llegan siempre en 0 (H31).
class ReportsUiState {
  /// Hoy en Lima, `yyyy-MM-dd`.
  final String today;
  final PeriodChoice choice;
  final ReportPeriod period;
  final CashFlowSummary? summary;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canReadCashFlow;

  /// US43 E2: informes de salud (`iot:health_reports:read` con IA habilitada) y clientes (`crm:customers:read`).
  final bool canReadFleetHealth;

  /// El rol tiene el permiso de informes de salud pero el plan del taller no incluye la IA.
  final bool fleetLockedByPlan;
  final FleetSheet? fleetSheet;
  final bool showCustomRangePicker;
  final ReportDownload? busy;
  final File? pdf;
  final ReportPdfActionMode pdfActionMode;
  final UiText? actionError;

  const ReportsUiState({
    required this.today,
    required this.choice,
    required this.period,
    this.summary,
    this.isLoading = false,
    this.isOnline = true,
    this.error,
    this.canReadCashFlow = false,
    this.canReadFleetHealth = false,
    this.fleetLockedByPlan = false,
    this.fleetSheet,
    this.showCustomRangePicker = false,
    this.busy,
    this.pdf,
    this.pdfActionMode = ReportPdfActionMode.open,
    this.actionError,
  });

  bool get hasAnyAccess => canReadCashFlow || canReadFleetHealth || fleetLockedByPlan;

  ReportsUiState copyWith({
    PeriodChoice? choice,
    ReportPeriod? period,
    CashFlowSummary? summary,
    bool clearSummary = false,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canReadCashFlow,
    bool? canReadFleetHealth,
    bool? fleetLockedByPlan,
    FleetSheet? fleetSheet,
    bool clearFleetSheet = false,
    bool? showCustomRangePicker,
    ReportDownload? busy,
    bool clearBusy = false,
    File? pdf,
    bool clearPdf = false,
    ReportPdfActionMode? pdfActionMode,
    UiText? actionError,
    bool clearActionError = false,
  }) {
    return ReportsUiState(
      today: today,
      choice: choice ?? this.choice,
      period: period ?? this.period,
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : (error ?? this.error),
      canReadCashFlow: canReadCashFlow ?? this.canReadCashFlow,
      canReadFleetHealth: canReadFleetHealth ?? this.canReadFleetHealth,
      fleetLockedByPlan: fleetLockedByPlan ?? this.fleetLockedByPlan,
      fleetSheet: clearFleetSheet ? null : (fleetSheet ?? this.fleetSheet),
      showCustomRangePicker:
          showCustomRangePicker ?? this.showCustomRangePicker,
      busy: clearBusy ? null : (busy ?? this.busy),
      pdf: clearPdf ? null : (pdf ?? this.pdf),
      pdfActionMode: pdfActionMode ?? this.pdfActionMode,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }
}
