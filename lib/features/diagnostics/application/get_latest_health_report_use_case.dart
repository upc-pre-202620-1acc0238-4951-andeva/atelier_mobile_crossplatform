import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';

class GetLatestHealthReportUseCase {
  final HealthReportRepository repository;

  const GetLatestHealthReportUseCase({required this.repository});

  /// `null` si el vehículo aún no tiene informes.
  Future<HealthReport?> execute(String vehicleId) => repository.getLatest(vehicleId);
}
