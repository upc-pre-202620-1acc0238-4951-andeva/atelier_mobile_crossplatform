import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';

/// Lee los códigos (modo 03) y registra los nuevos (US17). El cuadro congelado es un extra: si falla, los
/// códigos valen igual.
class ScanFaultsUseCase {
  final DiagnosticSession session;
  final DiagnosticsRepository repository;

  const ScanFaultsUseCase({required this.session, required this.repository});

  Future<FaultScanResult> execute(String vehicleId) async {
    final sessionId = session.sessionId;
    if (sessionId == null) throw const ObdNotConnectedException();
    final (dtcs, freezeFrame) = await session.withLink((link) async {
      final dtcs = await link.readDtcs();
      FreezeFrame? frame;
      if (dtcs.isNotEmpty) {
        try {
          frame = await link.readFreezeFrame();
        } on Exception {
          frame = null;
        }
      }
      return (dtcs, frame);
    });
    return FaultScanResult(
      faults: await repository.registerDetectedFaults(
        vehicleId,
        dtcs,
        sessionId,
      ),
      freezeFrame: freezeFrame,
    );
  }
}
