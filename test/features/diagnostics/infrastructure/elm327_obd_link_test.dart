import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/elm327_obd_link.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_obd_transport.dart';

const adapter = ObdAdapter(
  name: 'ELM327',
  address: 'AA:BB:CC:11:22:33',
  kind: ObdAdapterKind.classic,
);

void main() {
  late FakeObdTransport transport;
  late Elm327ObdLink link;

  setUp(() {
    transport = FakeObdTransport();
    link = Elm327ObdLink(
      transportFor: (_) => transport,
      now: () => DateTime.utc(2026, 10, 24, 14, 0, 0, 123, 456),
      commandTimeout: const Duration(milliseconds: 30),
    );
  });

  test('inicializa el ELM327 y lee protocolo y VIN', () async {
    final info = await link.connect(adapter);

    expect(info.protocol, 'ISO 15765-4 CAN (11 bit, 500 kbaud)');
    expect(info.vin, '1G1JC5444R7252367');
    expect(transport.commands, [
      'ATZ',
      'ATE0',
      'ATL0',
      'ATS0',
      'ATH0',
      'ATSP0',
      '0100',
      'ATDPN',
      '0902',
    ]);
    expect(link.isConnected, isTrue);
  });

  test('elige el transporte según el tipo del adaptador', () async {
    final kinds = <ObdAdapterKind>[];
    final routed = Elm327ObdLink(
      transportFor: (kind) {
        kinds.add(kind);
        return transport;
      },
    );

    await routed.connect(
      const ObdAdapter(name: 'BLE', address: 'x', kind: ObdAdapterKind.ble),
    );

    expect(kinds, [ObdAdapterKind.ble]);
  });

  test('sin respuesta de la ECU falla y cierra el canal', () async {
    transport.responses['0100'] = 'SEARCHING...\rUNABLE TO CONNECT\r\r>';

    await expectLater(
      link.connect(adapter),
      throwsA(isA<ObdNoResponseException>()),
    );
    expect(link.isConnected, isFalse);
    expect(transport.disconnects, greaterThan(0));
  });

  test('el adaptador que no contesta es inalcanzable y el VIN es opcional', () async {
    transport.failOn = 'ATZ';
    await expectLater(
      link.connect(adapter),
      throwsA(isA<ObdAdapterUnreachableException>()),
    );

    transport.failOn = '0902';
    final info = await link.connect(adapter);
    expect(info.vin, isNull);
    expect(link.isConnected, isTrue);
  });

  test('los errores de Bluetooth al abrir suben tal cual', () async {
    transport.connectError = const BluetoothDisabledException();

    await expectLater(
      link.connect(adapter),
      throwsA(isA<BluetoothDisabledException>()),
    );
    expect(link.isConnected, isFalse);
  });

  test('lee y borra códigos', () async {
    await link.connect(adapter);

    expect(await link.readDtcs(), isEmpty);
    transport.responses['03'] = '43020300 0133\r\r>';
    expect((await link.readDtcs()).map((dtc) => dtc.code), ['P0300', 'P0133']);

    transport.responses['04'] = '44\r\r>';
    await link.clearDtcs();
    transport.responses['04'] = 'UNABLE TO CONNECT\r\r>';
    await expectLater(
      link.clearDtcs(),
      throwsA(isA<ObdNoResponseException>()),
    );
  });

  test('cuadro congelado del código que encendió el testigo', () async {
    await link.connect(adapter);
    expect(await link.readFreezeFrame(), isNull);

    transport.responses['0202'] = '4202000300\r>';
    transport.responses['020500'] = '4205007B\r>';
    transport.responses['020C00'] = '420C001AF8\r>';
    final frame = (await link.readFreezeFrame())!;
    expect(frame.dtc?.code, 'P0300');
    expect(frame.engineTempCelsius, 83.0);
    expect(frame.engineRpm, 1726);
    expect(frame.speedKmh, isNull);
  });

  test('muestra con PID sin soporte y hora truncada a milisegundos', () async {
    await link.connect(adapter);
    transport.responses['0105'] = '41057B\r>';
    transport.responses['010C'] = '410C1AF8\r>';
    transport.responses['ATRV'] = '13.9V\r>';

    final sample = await link.readSample();
    expect(sample.timestamp, DateTime.utc(2026, 10, 24, 14, 0, 0, 123));
    expect(sample.engineTempCelsius, 83.0);
    expect(sample.engineRpm, 1726);
    expect(sample.batteryVoltage, 13.9);
    expect(sample.speedKmh, isNull);
    expect(sample.fuelPercentage, isNull);
  });

  test('una caída del canal es conexión perdida y se puede reconectar', () async {
    await expectLater(
      link.readSample(),
      throwsA(isA<ObdNotConnectedException>()),
    );
    await expectLater(
      link.reconnect(),
      throwsA(isA<ObdNotConnectedException>()),
    );

    await link.connect(adapter);
    transport.failOn = '0105';
    await expectLater(
      link.readSample(),
      throwsA(isA<ObdConnectionLostException>()),
    );
    expect(link.isConnected, isFalse);

    transport.failOn = null;
    await link.reconnect();
    expect(link.isConnected, isTrue);
  });

  group('respuestas por un stream', () {
    test('una respuesta partida en varios trozos se une', () async {
      transport.chunkSize = 3;

      final info = await link.connect(adapter);

      expect(info.vin, '1G1JC5444R7252367');
    });

    test('el prompt puede llegar solo, en otro trozo', () async {
      transport.responses['0105'] = '41057B\r';
      await link.connect(adapter);
      transport.silentOn = '0105';

      final temp = link.readSample();
      await Future<void>.delayed(Duration.zero);
      transport.emit('41057B\r');
      await Future<void>.delayed(Duration.zero);
      transport.emit('>');
      transport.silentOn = null;

      expect((await temp).engineTempCelsius, 83.0);
    });

    test('un trozo tardío de un comando vencido no contamina el siguiente', () async {
      await link.connect(adapter);
      transport.emit('410D99\r>'); // Sin comando en curso: se ignora.
      transport.responses['03'] = 'NO DATA\r\r>';

      expect(await link.readDtcs(), isEmpty);
    });

    test('un comando sin respuesta vence y da conexión perdida', () async {
      await link.connect(adapter);
      transport.silentOn = '03';

      await expectLater(
        link.readDtcs(),
        throwsA(isA<ObdConnectionLostException>()),
      );
      expect(link.isConnected, isFalse);
    });

    test('el canal cae con un comando en curso', () async {
      await link.connect(adapter);
      transport.silentOn = '03';

      final read = link.readDtcs();
      await Future<void>.delayed(Duration.zero);
      await transport.drop();

      await expectLater(read, throwsA(isA<ObdConnectionLostException>()));
      expect(link.isConnected, isFalse);
    });

    test('el canal cae con error y sin comando en curso', () async {
      await link.connect(adapter);

      await transport.drop(withError: true);
      await Future<void>.delayed(Duration.zero);

      expect(link.isConnected, isFalse);
      await expectLater(
        link.readDtcs(),
        throwsA(isA<ObdNotConnectedException>()),
      );
    });

    test('tras reconectar cada trozo llega una sola vez', () async {
      await link.connect(adapter);
      await link.reconnect();
      transport.responses['010D'] = '410D32\r>';
      // Con dos suscripciones el primer trozo se escribiría doble y el byte leído sería 0x41.
      transport.chunkSize = 4;

      final sample = await link.readSample();

      expect(sample.speedKmh, 50);
      expect(transport.connects, 2);
    });
  });
}
