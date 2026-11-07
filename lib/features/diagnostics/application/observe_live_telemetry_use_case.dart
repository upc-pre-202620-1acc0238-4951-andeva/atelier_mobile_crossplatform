import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

class ObserveLiveTelemetryUseCase {
  final DiagnosticSession session;

  const ObserveLiveTelemetryUseCase({required this.session});

  Stream<LiveTelemetry> execute() => session.watchState();
}
