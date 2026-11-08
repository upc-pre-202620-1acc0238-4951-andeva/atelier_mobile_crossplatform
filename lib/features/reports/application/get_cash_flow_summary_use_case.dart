import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';

/// US41 (`invoicing:cashflow:export_pdf`): flujo de caja del taller en [period] (H30, H31).
class GetCashFlowSummaryUseCase {
  final ReportsRepository repository;

  const GetCashFlowSummaryUseCase({required this.repository});

  Future<CashFlowSummary> execute(ReportPeriod period) {
    return repository.getCashFlow(period);
  }
}
