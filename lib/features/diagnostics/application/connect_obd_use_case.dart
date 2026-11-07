import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';

class ConnectObdUseCase {
  final DiagnosticSession session;

  const ConnectObdUseCase({required this.session});

  Future<ObdConnectionInfo> execute(ObdAdapter adapter) => session.connect(adapter);
}
