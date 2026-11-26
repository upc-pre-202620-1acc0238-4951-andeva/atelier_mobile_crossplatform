import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';

/// Reconecta con el último adaptador ELM327 cuando la sesión en vivo cae a `lost` (US16 E2, US18).
class ReconnectObdUseCase {
  final DiagnosticSession session;

  const ReconnectObdUseCase({required this.session});

  Future<ObdConnectionInfo> execute() => session.reconnect();
}
