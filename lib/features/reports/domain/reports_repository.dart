import 'dart:io';

import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';

/// Reportes (US41, US43 E2). Todo en línea y sin caché (06 §2): sin red lanza `NetworkException`.
abstract class ReportsRepository {
  /// Un reporte mal formado, sin moneda o con una desconocida falla en vez de mostrarse en PEN.
  Future<CashFlowSummary> getCashFlow(ReportPeriod period);

  Future<File> downloadCashFlowPdf(ReportPeriod period);

  /// Un cliente de otro taller da 404 con su `message`.
  Future<File> downloadFleetHealthPdf(String customerId);
}
