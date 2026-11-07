import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';

/// Informes de salud con IA (US21, US43 E1). Todo en línea: inferencia en el servidor y cuota mensual
/// (06 §2).
abstract class HealthReportRepository {
  /// `POST /iot/health-reports/generate` (síncrono, H21): el resumen; el detalle se pide con [getDetail].
  Future<HealthReport> generate(
    String vehicleId, {
    required int daysToAnalyze,
    bool? includeResolvedDtcHistory,
  });

  /// `null`: el vehículo no tiene informes (404).
  Future<HealthReport?> getLatest(String vehicleId);

  Future<HealthReportDetail> getDetail(String reportId);

  /// Abrirlo o compartirlo es de la UI (04 §8).
  Future<File> downloadPdf(String reportId);
}
