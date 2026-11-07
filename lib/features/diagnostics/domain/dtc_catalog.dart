import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';

class DtcEntry {
  final String description;
  final FaultSeverity severity;

  const DtcEntry(this.description, this.severity);
}

/// Descripción y severidad de cada DTC que se envía en `POST /iot/faults` (US17 E1). El backend exige
/// `severity` y no tiene catálogo (H20): códigos genéricos SAE conocidos y, para el resto, una regla por
/// familia. Es parte del cuerpo de la petición, no texto de pantalla: por eso no está en `app_es.arb`.
abstract final class DtcCatalog {
  static const _known = {
    'P0100': DtcEntry('Circuito del sensor de flujo de aire (MAF)', FaultSeverity.medium),
    'P0101': DtcEntry('Rango o rendimiento del sensor de flujo de aire (MAF)', FaultSeverity.medium),
    'P0110': DtcEntry('Circuito del sensor de temperatura del aire de admisión', FaultSeverity.low),
    'P0115': DtcEntry('Circuito del sensor de temperatura del refrigerante', FaultSeverity.medium),
    'P0116': DtcEntry('Rango o rendimiento del sensor de temperatura del refrigerante', FaultSeverity.medium),
    'P0117': DtcEntry('Señal baja del sensor de temperatura del refrigerante', FaultSeverity.medium),
    'P0118': DtcEntry('Señal alta del sensor de temperatura del refrigerante', FaultSeverity.medium),
    'P0120': DtcEntry('Circuito del sensor de posición del acelerador', FaultSeverity.medium),
    'P0130': DtcEntry('Circuito del sensor de oxígeno (banco 1, sensor 1)', FaultSeverity.low),
    'P0171': DtcEntry('Mezcla demasiado pobre (banco 1)', FaultSeverity.medium),
    'P0172': DtcEntry('Mezcla demasiado rica (banco 1)', FaultSeverity.medium),
    'P0174': DtcEntry('Mezcla demasiado pobre (banco 2)', FaultSeverity.medium),
    'P0175': DtcEntry('Mezcla demasiado rica (banco 2)', FaultSeverity.medium),
    'P0217': DtcEntry('Sobrecalentamiento del motor', FaultSeverity.critical),
    'P0300': DtcEntry('Falla de encendido aleatoria o en varios cilindros', FaultSeverity.critical),
    'P0325': DtcEntry('Circuito del sensor de detonación', FaultSeverity.medium),
    'P0335': DtcEntry('Circuito del sensor de posición del cigüeñal', FaultSeverity.critical),
    'P0340': DtcEntry('Circuito del sensor de posición del árbol de levas', FaultSeverity.medium),
    'P0401': DtcEntry('Flujo insuficiente de recirculación de gases (EGR)', FaultSeverity.low),
    'P0420': DtcEntry('Eficiencia del catalizador bajo el umbral (banco 1)', FaultSeverity.medium),
    'P0430': DtcEntry('Eficiencia del catalizador bajo el umbral (banco 2)', FaultSeverity.medium),
    'P0440': DtcEntry('Sistema de control de emisiones evaporativas', FaultSeverity.low),
    'P0442': DtcEntry('Fuga pequeña en el sistema de emisiones evaporativas', FaultSeverity.low),
    'P0455': DtcEntry('Fuga grande en el sistema de emisiones evaporativas', FaultSeverity.low),
    'P0500': DtcEntry('Sensor de velocidad del vehículo', FaultSeverity.medium),
    'P0505': DtcEntry('Sistema de control de ralentí', FaultSeverity.medium),
    'P0520': DtcEntry('Circuito del sensor de presión de aceite', FaultSeverity.medium),
    'P0524': DtcEntry('Presión de aceite del motor demasiado baja', FaultSeverity.critical),
    'P0562': DtcEntry('Voltaje del sistema bajo', FaultSeverity.medium),
    'P0563': DtcEntry('Voltaje del sistema alto', FaultSeverity.medium),
    'P0600': DtcEntry('Falla en el enlace de comunicación serial', FaultSeverity.medium),
    'P0700': DtcEntry('Falla en el sistema de control de la transmisión', FaultSeverity.medium),
    'U0100': DtcEntry('Comunicación perdida con el módulo de control del motor (ECM/PCM)', FaultSeverity.critical),
  };

  static final _misfire = RegExp(r'^P030[1-9]$|^P031[0-2]$');

  static DtcEntry describe(Dtc dtc) {
    final known = _known[dtc.code];
    if (known != null) return known;
    if (_misfire.hasMatch(dtc.code)) {
      final cylinder = dtc.code.substring(3).replaceFirst(RegExp('^0+'), '');
      return DtcEntry('Falla de encendido en el cilindro $cylinder', FaultSeverity.critical);
    }
    return DtcEntry('${_familyName(dtc)} ${dtc.code}', _familySeverity(dtc));
  }

  static String _familyName(Dtc dtc) {
    return switch (dtc.code[0]) {
      'P' => 'Falla de tren motriz',
      'C' => 'Falla de chasis',
      'B' => 'Falla de carrocería',
      _ => 'Falla de red de comunicación',
    };
  }

  /// Emisiones (P04xx) y carrocería (Bxxxx) no comprometen la marcha; el resto, `MEDIUM` por defecto.
  static FaultSeverity _familySeverity(Dtc dtc) {
    if (dtc.code.startsWith('P04') || dtc.code.startsWith('B')) {
      return FaultSeverity.low;
    }
    return FaultSeverity.medium;
  }
}
