import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';

/// Borra los códigos (modo 04) y los vuelve a leer: los que siguen son persistentes (US17 E2).
class ClearFaultsUseCase {
  final DiagnosticSession session;
  final DiagnosticsRepository repository;

  const ClearFaultsUseCase({required this.session, required this.repository});

  Future<ClearFaultsResult> execute(String vehicleId) async {
    final sessionId = session.sessionId;
    if (sessionId == null) throw const ObdNotConnectedException();
    final remaining = await session.withLink((link) async {
      await link.clearDtcs();
      return link.readDtcs();
    });
    return repository.applyClearedFaults(vehicleId, remaining, sessionId);
  }
}
