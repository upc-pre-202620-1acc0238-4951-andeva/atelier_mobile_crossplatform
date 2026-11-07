import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';

class GetHealthReportDetailUseCase {
  final HealthReportRepository repository;

  const GetHealthReportDetailUseCase({required this.repository});

  Future<HealthReportDetail> execute(String reportId) => repository.getDetail(reportId);
}
