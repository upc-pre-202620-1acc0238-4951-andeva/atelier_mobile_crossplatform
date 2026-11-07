import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';

class DisconnectObdUseCase {
  final DiagnosticSession session;

  const DisconnectObdUseCase({required this.session});

  Future<void> execute() => session.disconnect();
}
