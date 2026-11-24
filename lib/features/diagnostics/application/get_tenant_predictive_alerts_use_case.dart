import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';

/// Alertas predictivas activas de todo el taller (`iot:alerts:read`). En línea; también las guarda en la
/// caché `predictive_alerts`.
class GetTenantPredictiveAlertsUseCase {
  final DiagnosticsRepository repository;

  const GetTenantPredictiveAlertsUseCase({required this.repository});

  Future<List<PredictiveAlert>> execute() {
    return repository.getTenantPredictiveAlerts();
  }
}
