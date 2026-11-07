import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

import 'dart:io';

/// Proforma en PDF (US24). Abrirla y compartirla es de la UI. En línea.
class DownloadQuotationPdfUseCase {
  final WorkOrderRepository repository;

  const DownloadQuotationPdfUseCase({required this.repository});

  Future<File> execute(WorkOrderId id) {
    return repository.downloadQuotationPdf(id);
  }
}
