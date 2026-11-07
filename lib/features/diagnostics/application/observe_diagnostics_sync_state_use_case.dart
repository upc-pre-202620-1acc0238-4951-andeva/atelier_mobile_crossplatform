import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

class ObserveDiagnosticsSyncStateUseCase {
  final DiagnosticsRepository repository;

  const ObserveDiagnosticsSyncStateUseCase({required this.repository});

  Stream<DiagnosticsSyncState> execute(String vehicleId) {
    return repository.watchSyncState(vehicleId);
  }
}
