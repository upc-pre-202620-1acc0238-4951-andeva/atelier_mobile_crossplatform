import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';

class StartLiveTelemetryUseCase {
  final DiagnosticSession session;

  const StartLiveTelemetryUseCase({required this.session});

  Future<void> execute(String vehicleId) => session.startStreaming(vehicleId);
}
