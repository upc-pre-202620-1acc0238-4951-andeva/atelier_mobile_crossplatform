import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/elm327_obd_link.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_obd_transport.dart';

const _adapter = ObdAdapter(
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
      commandTimeout: const Duration(milliseconds: 30),
    );
  });

  test(
    'en un protocolo anterior a CAN lee los pares sin byte de cantidad',
    () async {
      transport.responses['ATDPN'] = 'A4\r\r>';
      await link.connect(_adapter);
      transport.responses['03'] = '43 01 33 01 34 00\r\r>';

      expect((await link.readDtcs()).map((dtc) => dtc.code), [
        'P0133',
        'P0134',
      ]);
    },
  );

  test('en CAN respeta la cantidad de códigos', () async {
    await link.connect(_adapter);
    transport.responses['03'] = '4301013300\r\r>';

    expect((await link.readDtcs()).map((dtc) => dtc.code), ['P0133']);
  });

  test('al reconectar vuelve a leer el protocolo', () async {
    transport.responses['ATDPN'] = 'A4\r\r>';
    await link.connect(_adapter);
    transport.responses['ATDPN'] = 'A6\r\r>';
    await link.reconnect();
    transport.responses['03'] = '4301013300\r\r>';

    expect((await link.readDtcs()).map((dtc) => dtc.code), ['P0133']);
  });

  test('el cuadro congelado pide el cuadro 00 del modo 02', () async {
    await link.connect(_adapter);

    await link.readFreezeFrame();

    expect(transport.commands, contains('020200'));
    expect(transport.commands, isNot(contains('0202')));
  });
}
