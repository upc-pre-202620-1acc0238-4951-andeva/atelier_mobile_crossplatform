import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';

class DownloadHealthReportPdfUseCase {
  final HealthReportRepository repository;

  const DownloadHealthReportPdfUseCase({required this.repository});

  Future<File> execute(String reportId) => repository.downloadPdf(reportId);
}
