import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

class FreezeTelemetryUseCase {
  final DiagnosticSession session;

  const FreezeTelemetryUseCase({required this.session});

  TelemetrySnapshot execute() {
    return session.freeze() ?? (throw const ObdNotConnectedException());
  }
}
