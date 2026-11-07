import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/diagnostics_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';

/// Informes de salud con IA: todo en línea, sin caché (06 §2).
class HealthReportRepositoryImpl implements HealthReportRepository {
  final IotApi api;
  final PdfDownloader pdfDownloader;

  const HealthReportRepositoryImpl({
    required this.api,
    required this.pdfDownloader,
  });

  @override
  Future<HealthReport> generate(
    String vehicleId, {
    required int daysToAnalyze,
    bool? includeResolvedDtcHistory,
  }) async {
    final dto = await api.generateHealthReport(
      vehicleId,
      daysToAnalyze: daysToAnalyze,
      includeResolvedDtcHistory: includeResolvedDtcHistory,
    );
    return dto.toDomain(vehicleId);
  }

  @override
  Future<HealthReport?> getLatest(String vehicleId) async {
    try {
      return (await api.getLatestHealthReport(vehicleId)).toDomain(vehicleId);
    } on ApiException catch (e) {
      if (e.httpStatus == 404) return null;
      rethrow;
    }
  }

  @override
  Future<HealthReportDetail> getDetail(String reportId) async {
    return (await api.getHealthReport(reportId)).toDomain();
  }

  @override
  Future<File> downloadPdf(String reportId) {
    return pdfDownloader.download(
      'informe-salud-$reportId',
      () => api.getHealthReportPdf(reportId),
    );
  }
}
