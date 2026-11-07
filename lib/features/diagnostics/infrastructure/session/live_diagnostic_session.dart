import 'dart:async';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry_thresholds.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_foreground_controller.dart';
import 'package:uuid/uuid.dart';

/// Sesión de diagnóstico en bahía (06 §6, "US16–US19 — OBD-II en foso"):
/// - muestrea cada 2 s (04 §4) y guarda en `telemetry_readings` lo que se puede enviar;
/// - cada 200 lecturas arma un `TELEMETRY_BATCH`; al iniciar y al cerrar, también el resto (así salen las
///   lecturas de una sesión que se cortó sin cerrarse);
/// - ante una caída de señal reintenta [maxReconnectAttempts] veces y, si no vuelve, queda en
///   [ObdLinkState.lost].
///
/// Vive en el motor de la UI, donde están registrados los plugins de Bluetooth. El ELM327 es un solo canal
/// serie: el muestreo y los escaneos se turnan con [_locked].
class LiveDiagnosticSession implements DiagnosticSession {
  static const sampleIntervalDefault = Duration(seconds: 2);
  static const maxReconnectAttempts = 3;

  final ObdLink link;
  final DiagnosticsRepository repository;
  final LocationProvider locationProvider;
  final ObdForegroundController foreground;
  final Duration sampleInterval;

  final _changes = StreamController<LiveTelemetry>.broadcast();
  LiveTelemetry _state = const LiveTelemetry();
  String? _sessionId;
  Future<void> _tail = Future.value();

  /// Dart no cancela un `Future`: el bucle termina cuando cambia la generación.
  int _generation = 0;
  Future<void>? _streaming;
  Completer<void>? _wake;

  /// Se toma una vez por sesión y es opcional: sin permiso o sin señal las lecturas van sin ella.
  DeviceLocation? _location;

  LiveDiagnosticSession({
    required this.link,
    required this.repository,
    required this.locationProvider,
    required this.foreground,
    this.sampleInterval = sampleIntervalDefault,
  });

  @override
  LiveTelemetry get state => _state;

  @override
  Stream<LiveTelemetry> watchState() {
    return Stream.multi((controller) {
      controller.add(_state);
      final subscription = _changes.stream.listen(controller.add);
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  String? get sessionId => _sessionId;

  @override
  Future<ObdConnectionInfo> connect(ObdAdapter adapter) async {
    await stopStreaming();
    _emit(const LiveTelemetry(state: ObdLinkState.connecting));
    try {
      final info = await _locked(() => link.connect(adapter));
      _sessionId = const Uuid().v4();
      _emit(const LiveTelemetry(state: ObdLinkState.connected));
      return info;
    } on Exception {
      _sessionId = null;
      _emit(const LiveTelemetry());
      rethrow;
    }
  }

  @override
  Future<void> startStreaming(String vehicleId) async {
    if (!link.isConnected) throw const ObdNotConnectedException();
    await stopStreaming();
    await repository.purgeConfirmedReadings();
    await repository.enqueueUnbatchedReadings(onlyFull: false);
    await foreground.start();
    _emit(LiveTelemetry(state: ObdLinkState.streaming, vehicleId: vehicleId));
    final generation = ++_generation;
    unawaited(_fetchLocation());
    _streaming = _stream(vehicleId, generation);
  }

  /// Puede tardar 30 s (y pedir el permiso): no debe retrasar la primera muestra.
  Future<void> _fetchLocation() async {
    final session = _sessionId;
    try {
      final location = await locationProvider.currentLocation();
      if (_sessionId == session) _location = location;
    } on Exception catch (e) {
      log('Lecturas sin ubicación: $e', name: 'LiveDiagnosticSession');
    }
  }

  Future<void> _stream(String vehicleId, int generation) async {
    while (generation == _generation) {
      try {
        final sample = await _locked(link.readSample);
        final coordinates = _location;
        await repository.saveReading(
          vehicleId,
          sample,
          latitude: coordinates?.latitude,
          longitude: coordinates?.longitude,
        );
        await repository.enqueueUnbatchedReadings(onlyFull: true);
        _emit(
          _state.copyWith(
            state: ObdLinkState.streaming,
            sample: sample,
            warnings: TelemetryThresholds.warningsFor(sample),
          ),
        );
      } on Exception catch (e) {
        if (e is ObdConnectionLostException || !link.isConnected) {
          if (!await _recover(generation)) {
            await _lose();
            return;
          }
        } else {
          log('Muestra descartada: $e', name: 'LiveDiagnosticSession');
        }
      }
      await _pause(generation);
    }
  }

  Future<bool> _recover(int generation) async {
    for (var attempt = 0; attempt < maxReconnectAttempts; attempt++) {
      if (generation != _generation) return true; // Lo detuvieron: el bucle sale solo.
      _emit(_state.copyWith(state: ObdLinkState.reconnecting));
      try {
        await _locked(link.reconnect);
        _emit(_state.copyWith(state: ObdLinkState.streaming));
        return true;
      } on Exception catch (e) {
        log('Reconexión fallida: $e', name: 'LiveDiagnosticSession');
      }
      await _pause(generation);
    }
    return generation != _generation;
  }

  /// Sin señal: lo capturado queda en Drift y sale por la cola.
  Future<void> _lose() async {
    try {
      await repository.enqueueUnbatchedReadings(onlyFull: false);
    } finally {
      await foreground.stop();
      _emit(_state.copyWith(state: ObdLinkState.lost));
    }
  }

  @override
  Future<void> stopStreaming() async {
    final streaming = _streaming;
    if (streaming == null) return;
    _streaming = null;
    _generation++;
    final wake = _wake;
    if (wake != null && !wake.isCompleted) wake.complete();
    await streaming;
    try {
      await repository.enqueueUnbatchedReadings(onlyFull: false);
    } finally {
      await foreground.stop();
      if (link.isConnected) {
        _emit(_state.copyWith(state: ObdLinkState.connected));
      } else if (_state.state != ObdLinkState.lost) {
        _emit(_state.copyWith(state: ObdLinkState.disconnected));
      }
    }
  }

  @override
  Future<void> disconnect() async {
    await stopStreaming();
    await _locked(link.close);
    _sessionId = null;
    _location = null;
    _emit(const LiveTelemetry());
  }

  @override
  TelemetrySnapshot? freeze() {
    final vehicleId = _state.vehicleId;
    final sample = _state.sample;
    if (vehicleId == null || sample == null) return null;
    return TelemetrySnapshot(
      vehicleId: vehicleId,
      sample: sample,
      warnings: _state.warnings,
    );
  }

  @override
  Future<T> withLink<T>(Future<T> Function(ObdLink link) block) async {
    if (!link.isConnected) throw const ObdNotConnectedException();
    return _locked(() => block(link));
  }

  /// Corre [block] cuando termine lo anterior, sin importar si falló.
  Future<T> _locked<T>(Future<T> Function() block) {
    final result = _tail.then((_) => block());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  /// Como `delay`, pero `stopStreaming` la corta, también si lo detuvo antes de empezar a esperar.
  Future<void> _pause(int generation) async {
    if (generation != _generation) return;
    final wake = Completer<void>();
    _wake = wake;
    final timer = Timer(sampleInterval, () {
      if (!wake.isCompleted) wake.complete();
    });
    await wake.future;
    timer.cancel();
  }

  void _emit(LiveTelemetry state) {
    _state = state;
    _changes.add(state);
  }
}
