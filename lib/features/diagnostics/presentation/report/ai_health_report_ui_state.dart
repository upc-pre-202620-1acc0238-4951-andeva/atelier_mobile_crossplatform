import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Estado único del informe de salud con IA. La descarga y el envío del PDF (US43) no se portan.
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
  });

  String get displayPlate => vehicle?.plate ?? plate ?? '';

  int? get effectiveScore => detail?.diagnosis?.healthScore ?? latestSummary?.overallHealthScore;

  String? get effectiveSummary => detail?.diagnosis?.executiveSummary ?? latestSummary?.executiveSummary;

  bool get hasReport => latestSummary != null || detail != null;

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
      latestSummary: clearLatestSummary ? null : (latestSummary ?? this.latestSummary),
      detail: clearDetail ? null : (detail ?? this.detail),
      generateSheetOpen: generateSheetOpen ?? this.generateSheetOpen,
      daysToAnalyze: daysToAnalyze ?? this.daysToAnalyze,
      includeResolvedDtcHistory: includeResolvedDtcHistory ?? this.includeResolvedDtcHistory,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
