import 'dart:async';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_transport.dart';

/// ELM327 simulado: cada comando responde lo que diga [responses]; sin respuesta definida, `NO DATA`.
class FakeObdTransport implements ObdTransport {
  final responses = <String, String>{
    'ATZ': 'ELM327 v1.5\r\r>',
    'ATE0': 'OK\r\r>',
    'ATL0': 'OK\r\r>',
    'ATS0': 'OK\r\r>',
    'ATH0': 'OK\r\r>',
    'ATSP0': 'OK\r\r>',
    '0100': 'SEARCHING...\r4100BE3EB811\r\r>',
    'ATDPN': 'A6\r\r>',
    '0902': '014\r0:490201314731\r1:4A433534343452\r2:37323532333637\r\r>',
  };
  final commands = <String>[];

  Exception? connectError;

  /// El canal cae al escribir este comando.
  String? failOn;

  /// El adaptador nunca contesta este comando.
  String? silentOn;

  /// Parte cada respuesta en trozos de este tamaño, como BLE.
  int? chunkSize;

  int connects = 0;
  int disconnects = 0;

  StreamController<String> _incoming = StreamController<String>.broadcast();

  @override
  Stream<String> get incoming => _incoming.stream;

  /// Algo que manda el adaptador por su cuenta.
  void emit(String chunk) => _incoming.add(chunk);

  /// Se cae el canal: el stream termina y otro `connect` abre uno nuevo.
  Future<void> drop({bool withError = false}) async {
    if (withError) _incoming.addError(const ObdConnectionLostException());
    await _incoming.close();
    _incoming = StreamController<String>.broadcast();
  }

  @override
  Future<void> connect(String address) async {
    connects++;
    final error = connectError;
    if (error != null) throw error;
  }

  @override
  Future<void> send(String command) async {
    commands.add(command);
    if (command == failOn) throw const ObdConnectionLostException();
    if (command == silentOn) return;
    final response = responses[command] ?? 'NO DATA\r\r>';
    final size = chunkSize ?? response.length;
    scheduleMicrotask(() {
      for (var i = 0; i < response.length; i += size) {
        final end = i + size < response.length ? i + size : response.length;
        _incoming.add(response.substring(i, end));
      }
    });
  }

  @override
  Future<void> disconnect() async {
    disconnects++;
  }
}
