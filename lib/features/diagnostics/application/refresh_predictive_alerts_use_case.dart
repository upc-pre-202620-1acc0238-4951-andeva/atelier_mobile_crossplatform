import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';

class RefreshPredictiveAlertsUseCase {
  final DiagnosticsRepository repository;

  const RefreshPredictiveAlertsUseCase({required this.repository});

  Future<void> execute(String vehicleId) => repository.refreshPredictiveAlerts(vehicleId);
}
