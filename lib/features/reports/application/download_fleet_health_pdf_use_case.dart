import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';

/// US43 E2: PDF de salud de la flota de un cliente. Habilitar con `Session.canReadAiReports()`.
class DownloadFleetHealthPdfUseCase {
  final ReportsRepository repository;

  const DownloadFleetHealthPdfUseCase({required this.repository});

  Future<File> execute(String customerId) async {
    final id = customerId.trim();
    if (id.isEmpty) throw const InvalidReportInputException('customerId');
    return repository.downloadFleetHealthPdf(id);
  }
}
