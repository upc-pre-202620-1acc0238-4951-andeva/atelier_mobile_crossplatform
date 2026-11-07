/// Código de falla OBD-II (`P0301`, `U0100`…). Se normaliza a mayúsculas; el formato es el de
/// `RegisterVehicleFaultRequest.dtcCode` en docs/api/iot.md (`^[PBUC][0-9A-Fa-f]{4}$`).
final class Dtc {
  static final _format = RegExp(r'^[PBUC][0-9A-F]{4}$');

  final String code;

  const Dtc._(this.code);

  static String normalize(String code) => code.trim().toUpperCase();

  static bool isValid(String code) => _format.hasMatch(normalize(code));

  /// `null` si [code] no es un DTC válido.
  static Dtc? of(String code) {
    final normalized = normalize(code);
    return _format.hasMatch(normalized) ? Dtc._(normalized) : null;
  }

  @override
  bool operator ==(Object other) => other is Dtc && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => code;
}

/// `FaultSeverity` del backend: `POST /iot/faults` solo acepta estos tres valores.
enum FaultSeverity {
  low('LOW'),
  medium('MEDIUM'),
  critical('CRITICAL');

  final String value;

  const FaultSeverity(this.value);

  static FaultSeverity? fromString(String? value) {
    for (final severity in values) {
      if (severity.value == value) return severity;
    }
    return null;
  }
}
