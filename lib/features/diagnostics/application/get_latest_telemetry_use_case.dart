import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Lectura remota (US18, `iot:telemetry:read`): la última telemetría que tiene el servidor. `null` si el
/// vehículo no tiene lecturas (404). En línea.
class GetLatestTelemetryUseCase {
  final DiagnosticsRepository repository;

  const GetLatestTelemetryUseCase({required this.repository});

  Future<TelemetrySample?> execute(String vehicleId) => repository.getLatestTelemetry(vehicleId);
}
