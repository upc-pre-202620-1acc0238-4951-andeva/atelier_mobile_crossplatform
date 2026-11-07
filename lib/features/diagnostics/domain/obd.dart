import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';

/// Elige el transporte: Bluetooth clásico (SPP, solo Android) o BLE (docs/04-mobile-integration.md §4).
enum ObdAdapterKind { classic, ble }

/// Adaptador ELM327 disponible en el teléfono (US16). [address] es la MAC en Android; en iOS, un
/// identificador propio de cada teléfono (H41).
class ObdAdapter {
  final String name;
  final String address;
  final ObdAdapterKind kind;

  const ObdAdapter({
    required this.name,
    required this.address,
    required this.kind,
  });
}

/// Enlace con la computadora del vehículo (US16 E1): protocolo OBD-II y número de chasis si responde.
class ObdConnectionInfo {
  final String? protocol;
  final String? vin;

  const ObdConnectionInfo({this.protocol, this.vin});
}

/// Estado del enlace durante la sesión de diagnóstico.
enum ObdLinkState {
  disconnected,
  connecting,
  connected,
  streaming,
  reconnecting,

  /// Se cortó la señal y no se pudo recuperar (US16 E2): lo ya guardado no se pierde.
  lost,
}

/// Cuadro congelado (modo 02) del código que encendió el testigo (US17 E1). Solo se muestra: la API no
/// lo recibe (H19).
class FreezeFrame {
  final Dtc? dtc;
  final double? engineTempCelsius;
  final int? engineRpm;
  final int? speedKmh;

  const FreezeFrame({
    this.dtc,
    this.engineTempCelsius,
    this.engineRpm,
    this.speedKmh,
  });
}
