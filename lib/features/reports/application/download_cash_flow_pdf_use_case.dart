import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';

/// US41: PDF del flujo de caja; abrirlo con un visor es de la UI.
class DownloadCashFlowPdfUseCase {
  final ReportsRepository repository;

  const DownloadCashFlowPdfUseCase({required this.repository});

  Future<File> execute(ReportPeriod period) {
    return repository.downloadCashFlowPdf(period);
  }
}
