import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Sesión de diagnóstico en bahía: dueña del [ObdLink] mientras dure (un solo canal serie, así que el
/// muestreo en vivo y los escaneos se turnan). Las lecturas se guardan en Drift y salen en lotes por la
/// cola (06 §6).
abstract class DiagnosticSession {
  LiveTelemetry get state;

  /// Repite el estado actual al suscribirse.
  Stream<LiveTelemetry> watchState();

  /// Id de la conexión actual, para la `dedupe_key` de `REGISTER_FAULT`; `null` sin conexión.
  String? get sessionId;

  Future<ObdConnectionInfo> connect(ObdAdapter adapter);

  /// Muestreo cada 2 s de [vehicleId] (US18 E1, US19 E1). Sin conexión: `ObdNotConnectedException`.
  Future<void> startStreaming(String vehicleId);

  /// Detiene el muestreo y encola lo que falte enviar.
  Future<void> stopStreaming();

  Future<void> disconnect();

  /// La última muestra con sus avisos (US18 E2); `null` si aún no hay muestra.
  TelemetrySnapshot? freeze();

  /// Usa el canal en exclusiva, turnándose con el muestreo. Sin conexión: `ObdNotConnectedException`.
  Future<T> withLink<T>(Future<T> Function(ObdLink link) block);
}
