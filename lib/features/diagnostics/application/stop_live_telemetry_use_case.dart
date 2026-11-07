import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';

class StopLiveTelemetryUseCase {
  final DiagnosticSession session;

  const StopLiveTelemetryUseCase({required this.session});

  Future<void> execute() => session.stopStreaming();
}
