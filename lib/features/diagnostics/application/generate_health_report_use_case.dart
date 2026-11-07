import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_validation.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';

/// Lanza `InsufficientTelemetryException` en 422 (US20 E2); el resto, como `ApiException` con su `message`.
class GenerateHealthReportUseCase {
  final HealthReportRepository repository;

  const GenerateHealthReportUseCase({required this.repository});

  Future<HealthReport> execute(
    String vehicleId, {
    required int daysToAnalyze,
    bool? includeResolvedDtcHistory,
  }) async {
    if (!DiagnosticsValidation.isDaysToAnalyze(daysToAnalyze)) {
      throw const InvalidDiagnosticsInputException('daysToAnalyze');
    }
    try {
      return await repository.generate(
        vehicleId,
        daysToAnalyze: daysToAnalyze,
        includeResolvedDtcHistory: includeResolvedDtcHistory,
      );
    } on ApiException catch (e) {
      if (e.httpStatus == 422) throw InsufficientTelemetryException(e.message);
      rethrow;
    }
  }
}
