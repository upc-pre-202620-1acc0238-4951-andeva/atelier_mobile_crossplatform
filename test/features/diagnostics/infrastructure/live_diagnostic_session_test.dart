import 'dart:async';

import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_foreground_controller.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/session/live_diagnostic_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const adapter = ObdAdapter(
  name: 'ELM327',
  address: 'AA',
  kind: ObdAdapterKind.classic,
);

/// Vehículo simulado: con [lost] el canal se cae; [reconnects] dice si vuelve.
class FakeObdLink implements ObdLink {
  bool connected = false;
  Exception? connectError;
  bool lost = false;
  bool reconnects = false;
  int reconnectAttempts = 0;
  int sampleCount = 0;
  bool busy = false;
  int overlaps = 0;

  @override
  bool get isConnected => connected;

  @override
  Future<ObdConnectionInfo> connect(ObdAdapter adapter) async {
    final error = connectError;
    if (error != null) throw error;
    connected = true;
    return const ObdConnectionInfo(protocol: 'CAN', vin: '1G1JC5444R7252367');
  }

  @override
  Future<ObdConnectionInfo> reconnect() async {
    reconnectAttempts++;
    if (!reconnects) throw const ObdNoResponseException();
    connected = true;
    lost = false;
    return const ObdConnectionInfo();
  }

  @override
  Future<List<Dtc>> readDtcs() async => const [];

  @override
  Future<FreezeFrame?> readFreezeFrame() async => null;

  @override
  Future<void> clearDtcs() async {}

  @override
  Future<TelemetrySample> readSample() async {
    if (busy) overlaps++;
    busy = true;
    await Future<void>.delayed(Duration.zero);
    busy = false;
    if (lost) {
      connected = false;
      throw const ObdConnectionLostException();
    }
    sampleCount++;
    return TelemetrySample(
      timestamp: DateTime.utc(2026).add(Duration(seconds: sampleCount * 2)),
      engineTempCelsius: 110,
      engineRpm: 800,
      speedKmh: 0,
      batteryVoltage: 13.9,
      fuelPercentage: 50,
      intakePressureKpa: 35,
    );
  }

  @override
  Future<void> close() async => connected = false;
}

class MockRepository extends Mock implements DiagnosticsRepository {}

class MockForeground extends Mock implements ObdForegroundController {}

class FixedLocation implements LocationProvider {
  final Future<DeviceLocation> Function() fetch;

  FixedLocation(this.fetch);

  @override
  Future<DeviceLocation> currentLocation() => fetch();
}

const lima = DeviceLocation(
  latitude: -12.0464,
  longitude: -77.0428,
  accuracyMeters: 10,
  isMock: false,
);

Future<void> until(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) fail('No se cumplió a tiempo');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}

void main() {
  late FakeObdLink link;
  late MockRepository repository;
  late MockForeground foreground;

  setUpAll(() {
    registerFallbackValue(TelemetrySample(timestamp: DateTime.utc(2026)));
  });

  setUp(() {
    link = FakeObdLink();
    repository = MockRepository();
    foreground = MockForeground();
    when(() => foreground.start()).thenAnswer((_) async {});
    when(() => foreground.stop()).thenAnswer((_) async {});
    when(
      () => repository.saveReading(
        any(),
        any(),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => repository.enqueueUnbatchedReadings(
        onlyFull: any(named: 'onlyFull'),
      ),
    ).thenAnswer((_) async => 0);
    when(() => repository.purgeConfirmedReadings()).thenAnswer((_) async {});
  });

  LiveDiagnosticSession session({LocationProvider? location}) {
    return LiveDiagnosticSession(
      link: link,
      repository: repository,
      locationProvider: location ?? FixedLocation(() async => lima),
      foreground: foreground,
      sampleInterval: const Duration(milliseconds: 1),
    );
  }

  test('conectar abre una sesión con su id', () async {
    final subject = session();
    expect(subject.sessionId, isNull);

    await subject.connect(adapter);

    expect(subject.state.state, ObdLinkState.connected);
    expect(subject.sessionId, isNotNull);
  });

  test('sin respuesta de la ECU la sesión queda desconectada', () async {
    link.connectError = const ObdNoResponseException();
    final subject = session();

    await expectLater(
      subject.connect(adapter),
      throwsA(isA<ObdNoResponseException>()),
    );
    expect(subject.state.state, ObdLinkState.disconnected);
    await expectLater(
      subject.startStreaming('v1'),
      throwsA(isA<ObdNotConnectedException>()),
    );
    await expectLater(
      subject.withLink((_) async => 1),
      throwsA(isA<ObdNotConnectedException>()),
    );
  });

  test('el muestreo guarda, arma lotes completos y avisa por umbral', () async {
    final subject = session();
    await subject.connect(adapter);

    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 3);
    await subject.stopStreaming();

    final samples = link.sampleCount;
    verify(
      () => repository.saveReading(
        'v1',
        any(),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
      ),
    ).called(samples);
    verify(
      () => repository.enqueueUnbatchedReadings(onlyFull: true),
    ).called(samples);
    // Al iniciar y al cerrar.
    verify(
      () => repository.enqueueUnbatchedReadings(onlyFull: false),
    ).called(2);
    verify(() => repository.purgeConfirmedReadings()).called(1);
    verify(() => foreground.start()).called(1);
    verify(() => foreground.stop()).called(1);
    expect(subject.state.warnings, {TelemetryWarning.coolantOverheat});
    expect(subject.state.state, ObdLinkState.connected);
    expect(subject.freeze()?.vehicleId, 'v1');
  });

  test('la ubicación no retrasa la primera muestra y se usa al llegar', () async {
    final location = Completer<DeviceLocation>();
    final subject = session(location: FixedLocation(() => location.future));
    await subject.connect(adapter);

    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 1);
    verify(
      () => repository.saveReading('v1', any()),
    ).called(greaterThanOrEqualTo(1));

    location.complete(lima);
    await until(() => link.sampleCount >= 4);
    await subject.stopStreaming();

    verify(
      () => repository.saveReading(
        'v1',
        any(),
        latitude: lima.latitude,
        longitude: lima.longitude,
      ),
    ).called(greaterThanOrEqualTo(1));
  });

  test('sin ubicación las lecturas se guardan igual', () async {
    final subject = session(
      location: FixedLocation(() async => throw Exception('sin permiso')),
    );
    await subject.connect(adapter);

    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 2);
    await subject.stopStreaming();

    verify(
      () => repository.saveReading('v1', any()),
    ).called(greaterThanOrEqualTo(2));
  });

  test('una ubicación que llega tras desconectar se ignora', () async {
    final location = Completer<DeviceLocation>();
    var calls = 0;
    final subject = session(
      location: FixedLocation(() {
        calls++;
        return calls == 1 ? location.future : Completer<DeviceLocation>().future;
      }),
    );
    await subject.connect(adapter);
    await subject.startStreaming('v1');
    await subject.disconnect();

    location.complete(lima);
    await Future<void>.delayed(Duration.zero);
    clearInteractions(repository);
    await subject.connect(adapter);
    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 1);
    await subject.stopStreaming();

    verifyNever(
      () => repository.saveReading(
        'v1',
        any(),
        latitude: lima.latitude,
        longitude: lima.longitude,
      ),
    );
  });

  test('una caída de señal se recupera si el adaptador vuelve', () async {
    final subject = session();
    await subject.connect(adapter);
    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 1);

    link.reconnects = true;
    link.lost = true;
    await until(() => link.reconnectAttempts >= 1 && !link.lost);
    await until(() => subject.state.state == ObdLinkState.streaming);

    expect(link.reconnectAttempts, 1);
    await subject.stopStreaming();
  });

  test('si no vuelve tras 3 intentos queda perdida y encola lo capturado', () async {
    final subject = session();
    await subject.connect(adapter);
    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 1);

    link.lost = true;
    await until(() => subject.state.state == ObdLinkState.lost);

    expect(
      link.reconnectAttempts,
      LiveDiagnosticSession.maxReconnectAttempts,
    );
    verify(
      () => repository.enqueueUnbatchedReadings(onlyFull: false),
    ).called(2);
    verify(() => foreground.stop()).called(1);
  });

  test('desconectar cierra el canal y olvida la sesión', () async {
    final subject = session();
    await subject.connect(adapter);

    await subject.disconnect();

    expect(subject.sessionId, isNull);
    expect(subject.state.state, ObdLinkState.disconnected);
    expect(link.connected, isFalse);
    expect(subject.freeze(), isNull);
  });

  test('el muestreo y los escaneos se turnan el canal', () async {
    final subject = session();
    await subject.connect(adapter);
    await subject.startStreaming('v1');

    for (var i = 0; i < 5; i++) {
      final value = await subject.withLink((linked) async {
        await linked.readSample();
        return i;
      });
      expect(value, i);
    }
    await subject.stopStreaming();

    expect(link.overlaps, 0);
  });

  test('un fallo dentro de withLink no bloquea el canal', () async {
    final subject = session();
    await subject.connect(adapter);

    await expectLater(
      subject.withLink<int>((_) async => throw StateError('falló')),
      throwsStateError,
    );

    expect(await subject.withLink((_) async => 7), 7);
  });

  test('watchState repite el estado actual al suscribirse', () async {
    final subject = session();
    await subject.connect(adapter);

    final first = await subject.watchState().first;

    expect(first.state, ObdLinkState.connected);
  });

  test('detener corta la espera entre muestras', () async {
    final subject = LiveDiagnosticSession(
      link: link,
      repository: repository,
      locationProvider: FixedLocation(() async => lima),
      foreground: foreground,
      sampleInterval: const Duration(hours: 1),
    );
    await subject.connect(adapter);
    await subject.startStreaming('v1');
    await until(() => link.sampleCount >= 1);

    await subject.stopStreaming().timeout(const Duration(seconds: 5));

    expect(link.sampleCount, 1);
  });

  test('detener en plena lectura no entra a la espera', () async {
    final subject = LiveDiagnosticSession(
      link: link,
      repository: repository,
      locationProvider: FixedLocation(() async => lima),
      foreground: foreground,
      sampleInterval: const Duration(hours: 1),
    );
    await subject.connect(adapter);
    await subject.startStreaming('v1');

    // La lectura sigue en curso: el bucle aún no llegó a la pausa.
    await subject.stopStreaming().timeout(const Duration(seconds: 5));

    expect(subject.state.state, ObdLinkState.connected);
  });
}
