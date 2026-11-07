import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';

class ObservePredictiveAlertsUseCase {
  final DiagnosticsRepository repository;

  const ObservePredictiveAlertsUseCase({required this.repository});

  Stream<List<PredictiveAlert>> execute(String vehicleId) {
    return repository.watchPredictiveAlerts(vehicleId);
  }
}
