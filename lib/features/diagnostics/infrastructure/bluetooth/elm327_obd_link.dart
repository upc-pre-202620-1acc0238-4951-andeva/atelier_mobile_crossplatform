import 'dart:async';

import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_response_parser.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';

/// Protocolo ELM327 (04 §4) sobre un [ObdTransport]: `ATZ ATE0 ATL0 ATS0 ATH0 ATSP0` → `0100` (¿responde la
/// ECU?) → `ATDPN` (protocolo) → `0902` (VIN). El transporte entrega trozos sueltos: aquí se acumulan hasta el
/// prompt `>`. Un comando sin respuesta o un canal caído a mitad de la sesión es
/// [ObdConnectionLostException]. No admite comandos simultáneos: `LiveDiagnosticSession` los turna.
class Elm327ObdLink implements ObdLink {
  static const _initCommands = ['ATE0', 'ATL0', 'ATS0', 'ATH0', 'ATSP0'];
  static const _resetTimeout = Duration(seconds: 5);
  static const _searchTimeout = Duration(seconds: 15);
  static const _vinTimeout = Duration(seconds: 5);
  static const _clearTimeout = Duration(seconds: 5);
  static const _prompt = '>';

  final ObdTransport Function(ObdAdapterKind kind) transportFor;
  final DateTime Function() now;
  final Duration commandTimeout;

  ObdTransport? _transport;
  StreamSubscription<String>? _subscription;
  ObdAdapter? _lastAdapter;
  bool _open = false;
  final _response = StringBuffer();
  Completer<String>? _pending;

  Elm327ObdLink({
    required this.transportFor,
    this.now = DateTime.now,
    this.commandTimeout = const Duration(seconds: 3),
  });

  @override
  bool get isConnected => _open;

  @override
  Future<ObdConnectionInfo> connect(ObdAdapter adapter) async {
    await close();
    _lastAdapter = adapter;
    final transport = transportFor(adapter.kind);
    _transport = transport;
    // Se escucha antes de abrir, para no perder nada de lo que llegue al conectar.
    _subscription = transport.incoming.listen(
      _onChunk,
      onError: (Object _) => _onClosed(),
      onDone: _onClosed,
    );
    try {
      await transport.connect(adapter.address);
      _open = true;
      await _command('ATZ', _resetTimeout);
      for (final command in _initCommands) {
        await _command(command);
      }
      // Con ATSP0 el primer pedido busca el protocolo: puede tardar varios segundos.
      final probe = await _command('0100', _searchTimeout);
      if (ObdResponseParser.isNoResponse(probe) ||
          ObdResponseParser.data(probe, '4100') == null) {
        throw const ObdNoResponseException();
      }
      final protocol = ObdResponseParser.protocol(await _command('ATDPN'));
      return ObdConnectionInfo(protocol: protocol, vin: await _readVin());
    } on ObdConnectionLostException {
      await close();
      throw const ObdAdapterUnreachableException();
    } on Exception {
      await close();
      rethrow;
    }
  }

  /// Opcional: varias ECU anteriores a CAN no lo informan o tardan demasiado.
  Future<String?> _readVin() async {
    try {
      return ObdResponseParser.vin(await _command('0902', _vinTimeout));
    } on ObdConnectionLostException {
      return null;
    }
  }

  @override
  Future<ObdConnectionInfo> reconnect() async {
    final adapter = _lastAdapter;
    if (adapter == null) throw const ObdNotConnectedException();
    return connect(adapter);
  }

  /// `NO DATA` en el modo 03 = sin códigos (US17 E2); otro error = la ECU no contestó.
  @override
  Future<List<Dtc>> readDtcs() {
    return _query(() async {
      final raw = await _command('03');
      if (ObdResponseParser.isNoData(raw)) return const <Dtc>[];
      if (ObdResponseParser.isNoResponse(raw)) {
        throw const ObdNoResponseException();
      }
      return ObdResponseParser.dtcs(raw);
    });
  }

  @override
  Future<FreezeFrame?> readFreezeFrame() {
    return _query(() async {
      final dtc = ObdResponseParser.freezeFrameDtc(await _command('0202'));
      if (dtc == null) return null;
      final rpm = ObdResponseParser.freezeFrameData(
        await _command('020C00'),
        '0C',
      );
      final temp = ObdResponseParser.freezeFrameData(
        await _command('020500'),
        '05',
      )?.firstOrNull;
      final speed = ObdResponseParser.freezeFrameData(
        await _command('020D00'),
        '0D',
      )?.firstOrNull;
      return FreezeFrame(
        dtc: dtc,
        engineTempCelsius: temp == null ? null : temp - 40.0,
        engineRpm: rpm != null && rpm.length >= 2
            ? (rpm[0] * 256 + rpm[1]) ~/ 4
            : null,
        speedKmh: speed,
      );
    });
  }

  /// La ECU confirma el borrado con `44`.
  @override
  Future<void> clearDtcs() {
    return _query(() async {
      final raw = await _command('04', _clearTimeout);
      if (ObdResponseParser.data(raw, '44') == null) {
        throw const ObdNoResponseException();
      }
    });
  }

  /// Un PID sin soporte (`NO DATA`) queda en `null`; la muestra sin temperatura no se envía (H23).
  @override
  Future<TelemetrySample> readSample() {
    return _query(() async {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        now().millisecondsSinceEpoch,
        isUtc: true,
      );
      return TelemetrySample(
        timestamp: timestamp,
        engineTempCelsius: ObdResponseParser.coolantTemp(
          await _command('0105'),
        ),
        engineRpm: ObdResponseParser.engineRpm(await _command('010C')),
        speedKmh: ObdResponseParser.speed(await _command('010D')),
        batteryVoltage: ObdResponseParser.voltage(await _command('ATRV')),
        fuelPercentage: ObdResponseParser.fuelLevel(await _command('012F')),
        intakePressureKpa: ObdResponseParser.intakePressure(
          await _command('010B'),
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    _onClosed();
    final subscription = _subscription;
    final transport = _transport;
    _subscription = null;
    _transport = null;
    await subscription?.cancel();
    try {
      await transport?.disconnect();
    } on Exception {
      // Ya se da por cerrado: un fallo al soltar el canal no cambia nada.
    }
  }

  Future<T> _query<T>(Future<T> Function() block) async {
    if (!_open) throw const ObdNotConnectedException();
    try {
      return await block();
    } on ObdConnectionLostException {
      await close();
      rethrow;
    }
  }

  Future<String> _command(String command, [Duration? timeout]) async {
    final transport = _transport;
    if (!_open || transport == null) throw const ObdConnectionLostException();
    final limit = timeout ?? commandTimeout;
    _response.clear(); // Restos de un comando anterior.
    final pending = Completer<String>();
    _pending = pending;
    // Si el canal se cae mientras se escribe, nadie está esperando todavía esta respuesta.
    pending.future.ignore();
    try {
      await transport.send(command).timeout(limit);
      return await pending.future.timeout(limit);
    } on TimeoutException {
      throw const ObdConnectionLostException();
    } finally {
      if (identical(_pending, pending)) _pending = null;
    }
  }

  void _onChunk(String chunk) {
    final pending = _pending;
    if (pending == null) return; // Llega tarde: su comando ya venció.
    _response.write(chunk);
    final text = _response.toString();
    final end = text.indexOf(_prompt);
    if (end < 0) return;
    _pending = null;
    pending.complete(text.substring(0, end));
  }

  void _onClosed() {
    _open = false;
    final pending = _pending;
    _pending = null;
    pending?.completeError(const ObdConnectionLostException());
  }
}
