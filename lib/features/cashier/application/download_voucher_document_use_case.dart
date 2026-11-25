import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';

/// Descarga un archivo fiscal (`pdfUrl`, `xmlUrl` o `cdrUrl`) del comprobante a caché local.
class DownloadVoucherDocumentUseCase {
  final CashierRepository repository;

  const DownloadVoucherDocumentUseCase({required this.repository});

  Future<File> execute(String url, String fileNamePrefix) =>
      repository.downloadVoucherDocument(url, fileNamePrefix);
}
