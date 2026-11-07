import 'package:decimal/decimal.dart';

/// Resumen de un informe de salud con IA (`HealthReportCreatedResponse`, US21 E1).
class HealthReport {
  final String reportId;
  final String vehicleId;
  final int? overallHealthScore;
  final String? executiveSummary;
  final int? totalRisksDetected;
  final DateTime? generatedAt;

  const HealthReport({
    required this.reportId,
    required this.vehicleId,
    this.overallHealthScore,
    this.executiveSummary,
    this.totalRisksDetected,
    this.generatedAt,
  });
}

/// Informe completo (`HealthReportDetailResponse`): lo que el técnico contrasta con su criterio (US21 E1).
class HealthReportDetail {
  final String reportId;
  final String vehicleId;
  final int? daysAnalyzed;
  final DateTime? generatedAt;
  final HealthDiagnosis? diagnosis;

  const HealthReportDetail({
    required this.reportId,
    required this.vehicleId,
    this.daysAnalyzed,
    this.generatedAt,
    this.diagnosis,
  });
}

/// `VehicleHealthReportAiDto`.
class HealthDiagnosis {
  final int? healthScore;
  final String? overallCondition;
  final String? executiveSummary;
  final List<SubsystemEvaluation> subsystemEvaluations;
  final List<PredictiveRisk> predictiveRisks;
  final List<RecommendedServiceAction> recommendedActions;
  final List<DtcCorrelation> dtcCorrelations;

  const HealthDiagnosis({
    this.healthScore,
    this.overallCondition,
    this.executiveSummary,
    this.subsystemEvaluations = const [],
    this.predictiveRisks = const [],
    this.recommendedActions = const [],
    this.dtcCorrelations = const [],
  });
}

class SubsystemEvaluation {
  final String? subsystemName;
  final String? status;
  final int? score;
  final String? findings;

  const SubsystemEvaluation({
    this.subsystemName,
    this.status,
    this.score,
    this.findings,
  });
}

class PredictiveRisk {
  final String? category;
  final double? probability;
  final int? timeHorizonDays;
  final String? consequences;

  const PredictiveRisk({
    this.category,
    this.probability,
    this.timeHorizonDays,
    this.consequences,
  });
}

/// Servicio sugerido por el modelo. La API no indica la moneda de [estimatedCost]: por eso no es `Money`.
class RecommendedServiceAction {
  final String? serviceCode;
  final String? serviceName;
  final String? urgency;
  final Decimal? estimatedCost;
  final String? rationale;

  const RecommendedServiceAction({
    this.serviceCode,
    this.serviceName,
    this.urgency,
    this.estimatedCost,
    this.rationale,
  });
}

class DtcCorrelation {
  final String? dtcCode;
  final String? correlatedSensorReading;
  final String? anomalyExplanation;

  const DtcCorrelation({
    this.dtcCode,
    this.correlatedSensorReading,
    this.anomalyExplanation,
  });
}
