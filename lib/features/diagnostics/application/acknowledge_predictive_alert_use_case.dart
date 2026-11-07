import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';

class AcknowledgePredictiveAlertUseCase {
  final DiagnosticsRepository repository;

  const AcknowledgePredictiveAlertUseCase({required this.repository});

  Future<PredictiveAlert> execute(String id) => repository.acknowledgePredictiveAlert(id);
}
