import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';

class _Message {
  final String hex;

  /// Llegó en varias tramas CAN: trae byte de cantidad y relleno.
  final bool isMultiFrame;

  const _Message(this.hex, {required this.isMultiFrame});
}

/// Decodifica las respuestas del ELM327 (docs/04-mobile-integration.md §4). Con `ATE0 ATL0 ATS0 ATH0`
/// llegan sin eco, sin espacios y sin cabeceras; en CAN, un mensaje de varias tramas llega como `0:…`,
/// `1:…` precedido de su longitud (`00A`).
abstract final class ObdResponseParser {
  static final _frame = RegExp(r'^[0-9A-F]:([0-9A-F]+)$');
  static final _hex = RegExp(r'^(?:[0-9A-F]{2})+$');
  static final _voltage = RegExp(r'^(\d+(?:\.\d+)?)V$');
  static final _vinChar = RegExp('[A-HJ-NPR-Z0-9]');
  static const _vinLength = 17;

  /// Respuestas del ELM327 que significan "la computadora del vehículo no contestó".
  static const _noResponse = [
    'NODATA',
    'UNABLETOCONNECT',
    'CANERROR',
    'BUSINIT',
    'BUSERROR',
    'BUSBUSY',
    'STOPPED',
    'ERROR',
    '?',
  ];

  static const _protocols = {
    '1': 'SAE J1850 PWM',
    '2': 'SAE J1850 VPW',
    '3': 'ISO 9141-2',
    '4': 'ISO 14230-4 KWP (5 baud)',
    '5': 'ISO 14230-4 KWP (fast init)',
    '6': 'ISO 15765-4 CAN (11 bit, 500 kbaud)',
    '7': 'ISO 15765-4 CAN (29 bit, 500 kbaud)',
    '8': 'ISO 15765-4 CAN (11 bit, 250 kbaud)',
    '9': 'ISO 15765-4 CAN (29 bit, 250 kbaud)',
    'A': 'SAE J1939 CAN',
  };

  /// Líneas útiles: en mayúsculas, sin espacios, sin el prompt `>` y sin `SEARCHING...`.
  static List<String> lines(String raw) {
    return raw
        .replaceAll('>', '')
        .split(RegExp(r'[\r\n]'))
        .map((line) => line.replaceAll(' ', '').trim().toUpperCase())
        .where((line) => line.isNotEmpty && !line.startsWith('SEARCHING'))
        .toList();
  }

  static bool isOk(String raw) => lines(raw).contains('OK');

  /// `NO DATA`: la ECU contestó, pero no tiene ese dato (modo 03 sin códigos o un PID no soportado).
  static bool isNoData(String raw) => lines(raw).contains('NODATA');

  /// Sin líneas o con un error del ELM327 (`NO DATA`, `UNABLE TO CONNECT`, `?`…).
  static bool isNoResponse(String raw) {
    final all = lines(raw);
    return all.isEmpty ||
        all.any((line) => _noResponse.any((error) => line.contains(error)));
  }

  static List<_Message> _messages(String raw) {
    final result = <_Message>[];
    final frames = StringBuffer();
    for (final line in lines(raw)) {
      final frame = _frame.firstMatch(line);
      if (frame != null) {
        frames.write(frame.group(1));
      } else if (_hex.hasMatch(line)) {
        result.add(_Message(line, isMultiFrame: false));
      }
    }
    if (frames.isNotEmpty) {
      result.add(_Message(frames.toString(), isMultiFrame: true));
    }
    return result;
  }

  static List<int> _bytes(String hex) {
    return [
      for (var i = 0; i + 2 <= hex.length; i += 2)
        int.parse(hex.substring(i, i + 2), radix: 16),
    ];
  }

  /// Bytes de datos del primer mensaje que empieza con [prefix] (p. ej. `410C`), sin el prefijo.
  static List<int>? data(String raw, String prefix) {
    for (final message in _messages(raw)) {
      if (message.hex.startsWith(prefix)) {
        return _bytes(message.hex.substring(prefix.length));
      }
    }
    return null;
  }

  /// Modo 03 (y la re-lectura de US20): códigos almacenados, sin repetir.
  static List<Dtc> dtcs(String raw) {
    final found = <Dtc>{};
    for (final message in _messages(raw)) {
      if (!message.hex.startsWith('43')) continue;
      final payload = _bytes(message.hex).sublist(1);
      // CAN antepone la cantidad de códigos (y en varias tramas rellena con ceros); los demás no.
      final pairs = message.isMultiFrame || payload.length.isOdd
          ? payload.skip(1).take((payload.firstOrNull ?? 0) * 2).toList()
          : payload;
      for (var i = 0; i + 2 <= pairs.length; i += 2) {
        if (pairs[i] != 0 || pairs[i + 1] != 0) {
          found.add(decodeDtc(pairs[i], pairs[i + 1]));
        }
      }
    }
    return found.toList();
  }

  /// Dos bytes → `P0xxx` / `Cxxxx` / `Bxxxx` / `Uxxxx` (SAE J2012).
  static Dtc decodeDtc(int a, int b) {
    final letter = 'PCBU'[(a >> 6) & 0x3];
    final second = (a & 0xF).toRadixString(16);
    final rest = (b & 0xFF).toRadixString(16).padLeft(2, '0');
    return Dtc.of('$letter${(a >> 4) & 0x3}$second$rest')!;
  }

  /// `0105`: A − 40 °C.
  static double? coolantTemp(String raw) {
    final value = data(raw, '4105')?.firstOrNull;
    return value == null ? null : value - 40.0;
  }

  /// `010C`: (256A + B) / 4 rpm.
  static int? engineRpm(String raw) {
    final bytes = data(raw, '410C');
    if (bytes == null || bytes.length < 2) return null;
    return (bytes[0] * 256 + bytes[1]) ~/ 4;
  }

  /// `010D`: A km/h.
  static int? speed(String raw) => data(raw, '410D')?.firstOrNull;

  /// `012F`: A × 100 / 255 %.
  static double? fuelLevel(String raw) {
    final value = data(raw, '412F')?.firstOrNull;
    return value == null ? null : value * 100.0 / 255.0;
  }

  /// `010B`: A kPa (presión absoluta del múltiple de admisión).
  static int? intakePressure(String raw) => data(raw, '410B')?.firstOrNull;

  /// `ATRV`: "12.6V".
  static double? voltage(String raw) {
    for (final line in lines(raw)) {
      final match = _voltage.firstMatch(line);
      if (match != null) return double.parse(match.group(1)!);
    }
    return null;
  }

  /// `0902`: los 17 caracteres del VIN; `null` si la ECU no lo informa.
  static String? vin(String raw) {
    final text = StringBuffer();
    for (final message in _messages(raw)) {
      if (!message.hex.startsWith('4902')) continue;
      // 49 02 + cantidad (CAN) o secuencia (otros protocolos).
      for (final byte in _bytes(message.hex).skip(3)) {
        final char = String.fromCharCode(byte);
        if (_vinChar.hasMatch(char)) text.write(char);
      }
    }
    final vin = text.toString();
    return vin.length >= _vinLength
        ? vin.substring(vin.length - _vinLength)
        : null;
  }

  /// `ATDPN`: "A6" (automático) o "6" → nombre del protocolo.
  static String? protocol(String raw) {
    final line = lines(raw).firstOrNull;
    if (line == null) return null;
    return _protocols[line.startsWith('A') ? line.substring(1) : line];
  }

  /// Cuadro congelado (modo 02, cuadro 00): los datos van después del número de cuadro.
  static List<int>? freezeFrameData(String raw, String pid) {
    return data(raw, '42$pid')?.skip(1).toList();
  }

  static Dtc? freezeFrameDtc(String raw) {
    final bytes = freezeFrameData(raw, '02');
    if (bytes == null || bytes.length < 2) return null;
    if (bytes[0] == 0 && bytes[1] == 0) return null;
    return decodeDtc(bytes[0], bytes[1]);
  }
}
