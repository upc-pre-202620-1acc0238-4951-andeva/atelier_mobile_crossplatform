import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Serie histórica agregada por `time_bucket` (`GET /api/v1/iot/telemetry/vehicle/{vehicleId}/history`, permiso
/// `iot:telemetry:read`). En línea.
class GetVehicleTelemetryHistoryUseCase {
  final DiagnosticsRepository repository;

  const GetVehicleTelemetryHistoryUseCase({required this.repository});

  Future<List<TelemetryHistoryBucket>> execute(String vehicleId, {DateTime? from, DateTime? to, String? bucket}) {
    return repository.getVehicleTelemetryHistory(vehicleId, from: from, to: to, bucket: bucket);
  }
}
