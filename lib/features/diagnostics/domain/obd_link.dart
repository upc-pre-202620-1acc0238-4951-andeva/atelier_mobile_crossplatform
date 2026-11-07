import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Canal con el adaptador ELM327 (04 §4). Lanza `BluetoothPermissionDeniedException`,
/// `BluetoothDisabledException`, `ObdAdapterUnreachableException`, `ObdNoResponseException`,
/// `ObdConnectionLostException` u `ObdNotConnectedException`.
abstract class ObdLink {
  bool get isConnected;

  /// Abre el canal, inicializa el ELM327 y comprueba que la ECU responda (US16 E1).
  Future<ObdConnectionInfo> connect(ObdAdapter adapter);

  /// Vuelve a abrir el último adaptador tras una caída de señal.
  Future<ObdConnectionInfo> reconnect();

  /// Modo 03: códigos almacenados (vacío = sin averías).
  Future<List<Dtc>> readDtcs();

  /// Modo 02: cuadro congelado del código que encendió el testigo; `null` si la ECU no guardó ninguno.
  Future<FreezeFrame?> readFreezeFrame();

  /// Modo 04: borra los códigos y apaga el testigo.
  Future<void> clearDtcs();

  /// Una muestra del modo 01 y el voltaje del adaptador.
  Future<TelemetrySample> readSample();

  Future<void> close();
}

/// Adaptadores disponibles: emparejados y, de mejor esfuerzo, los que se ven por BLE (04 §4).
abstract class ObdAdapterProvider {
  Future<List<ObdAdapter>> pairedAdapters();
}
