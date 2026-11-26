import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Qué se hace con el PDF del informe una vez descargado (US43 E1).
enum HealthPdfMode { open, share }

/// Estado único del informe de salud con IA, con la descarga del PDF por vehículo (US43 E1).
class AiHealthReportUiState {
  final String vehicleId;
  final String? plate;
  final Vehicle? vehicle;
  final bool planIncludesAi;
  final bool canGenerate;
  final bool canRead;
  final bool isOnline;
  final bool isLoading;
  final bool isGenerating;
  final HealthReport? latestSummary;
  final HealthReportDetail? detail;
  final bool generateSheetOpen;
  final int daysToAnalyze;
  final bool includeResolvedDtcHistory;
  final UiText? error;

  /// Descarga del PDF: [pdfBusy] es la acción en curso, [pdf] el archivo listo para abrir o compartir.
  final HealthPdfMode? pdfBusy;
  final HealthPdfMode pdfMode;
  final File? pdf;
  final UiText? pdfError;

  const AiHealthReportUiState({
    this.vehicleId = '',
    this.plate,
    this.vehicle,
    this.planIncludesAi = true,
    this.canGenerate = false,
    this.canRead = false,
    this.isOnline = true,
    this.isLoading = false,
    this.isGenerating = false,
    this.latestSummary,
    this.detail,
    this.generateSheetOpen = false,
    this.daysToAnalyze = 30,
    this.includeResolvedDtcHistory = true,
    this.error,
    this.pdfBusy,
    this.pdfMode = HealthPdfMode.open,
    this.pdf,
    this.pdfError,
  });

  String get displayPlate => vehicle?.plate ?? plate ?? '';

  int? get effectiveScore =>
      detail?.diagnosis?.healthScore ?? latestSummary?.overallHealthScore;

  String? get effectiveSummary =>
      detail?.diagnosis?.executiveSummary ?? latestSummary?.executiveSummary;

  bool get hasReport => latestSummary != null || detail != null;

  /// El PDF existe una vez generado el informe y con permiso de lectura (`iot:health_reports:read`).
  bool get canDownloadPdf => planIncludesAi && canRead && latestSummary != null;

  AiHealthReportUiState copyWith({
    Vehicle? vehicle,
    bool? planIncludesAi,
    bool? canGenerate,
    bool? canRead,
    bool? isOnline,
    bool? isLoading,
    bool? isGenerating,
    HealthReport? latestSummary,
    bool clearLatestSummary = false,
    HealthReportDetail? detail,
    bool clearDetail = false,
    bool? generateSheetOpen,
    int? daysToAnalyze,
    bool? includeResolvedDtcHistory,
    UiText? error,
    bool clearError = false,
    HealthPdfMode? pdfBusy,
    bool clearPdfBusy = false,
    HealthPdfMode? pdfMode,
    File? pdf,
    bool clearPdf = false,
    UiText? pdfError,
    bool clearPdfError = false,
  }) {
    return AiHealthReportUiState(
      vehicleId: vehicleId,
      plate: plate,
      vehicle: vehicle ?? this.vehicle,
      planIncludesAi: planIncludesAi ?? this.planIncludesAi,
      canGenerate: canGenerate ?? this.canGenerate,
      canRead: canRead ?? this.canRead,
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      latestSummary: clearLatestSummary
          ? null
          : (latestSummary ?? this.latestSummary),
      detail: clearDetail ? null : (detail ?? this.detail),
      generateSheetOpen: generateSheetOpen ?? this.generateSheetOpen,
      daysToAnalyze: daysToAnalyze ?? this.daysToAnalyze,
      includeResolvedDtcHistory:
          includeResolvedDtcHistory ?? this.includeResolvedDtcHistory,
      error: clearError ? null : (error ?? this.error),
      pdfBusy: clearPdfBusy ? null : (pdfBusy ?? this.pdfBusy),
      pdfMode: pdfMode ?? this.pdfMode,
      pdf: clearPdf ? null : (pdf ?? this.pdf),
      pdfError: clearPdfError ? null : (pdfError ?? this.pdfError),
    );
  }
}
