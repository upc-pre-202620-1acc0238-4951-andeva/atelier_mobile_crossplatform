import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reports/infrastructure/remote/reports_api.dart';
import 'package:decimal/decimal.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsApi api;
  final PdfDownloader pdfDownloader;

  const ReportsRepositoryImpl({required this.api, required this.pdfDownloader});

  @override
  Future<CashFlowSummary> getCashFlow(ReportPeriod period) async {
    return (await api.getCashFlow(period.from, period.to)).toDomain();
  }

  @override
  Future<File> downloadCashFlowPdf(ReportPeriod period) {
    return pdfDownloader.download(
      'flujo-de-caja-${period.from}-${period.to}',
      () => api.getCashFlowPdf(period.from, period.to),
    );
  }

  @override
  Future<File> downloadFleetHealthPdf(String customerId) {
    return pdfDownloader.download(
      'salud-flota-$customerId',
      () => api.getFleetHealthPdf(customerId),
    );
  }
}

extension on CashFlowSummaryDto {
  /// Sin moneda por defecto: la app no inventa una (H31). Una desconocida falla en `Money`.
  CashFlowSummary toDomain() {
    final code = currency ?? (throw const FormatException('Falta la moneda'));
    Money money(Decimal? amount) =>
        Money(amount: _required(amount), currency: code);
    return CashFlowSummary(
      totalIncome: money(totalIncome),
      totalExpenses: money(totalExpenses),
      accountsReceivable: money(accountsReceivable),
      netCashFlow: _required(netCashFlow),
      currency: code,
      movements: [
        for (final movement in movements)
          CashFlowMovement(
            transactionId:
                movement.transactionId ??
                (throw const FormatException('Falta el id del movimiento')),
            movementDate: DateTime.parse(
              movement.movementDate ??
                  (throw const FormatException('Falta la fecha')),
            ),
            type: movement.type ?? '',
            category: movement.category ?? '',
            concept: movement.concept ?? '',
            referenceNumber: movement.referenceNumber ?? '',
            amount: _required(movement.amount),
            runningBalance: _required(movement.runningBalance),
          ),
      ],
    );
  }
}

Decimal _required(Decimal? amount) =>
    amount ?? (throw const FormatException('Falta un monto'));
