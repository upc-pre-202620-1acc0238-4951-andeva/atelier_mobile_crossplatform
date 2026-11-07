import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> codes(String raw) {
  return ObdResponseParser.dtcs(raw).map((dtc) => dtc.code).toList();
}

void main() {
  test('modo 03 sin CAN trae tres pares por línea y rellena con ceros', () {
    expect(codes('43 01 33 00 00 00 00\r\r>'), ['P0133']);
    expect(codes('43013303004035\r'), ['P0133', 'P0300', 'C0035']);
  });

  test('modo 03 en CAN antepone la cantidad de códigos', () {
    expect(codes('43 02 01 33 81 34'), ['P0133', 'B0134']);
    expect(codes('4300'), isEmpty);
  });

  test('modo 03 en varias tramas CAN se une y respeta la cantidad', () {
    const raw = '00A\r0:430401330134\r1:01350136000000\r\r>';
    expect(codes(raw), ['P0133', 'P0134', 'P0135', 'P0136']);
  });

  test('decodifica las cuatro familias SAE', () {
    expect(ObdResponseParser.decodeDtc(0x03, 0x00).code, 'P0300');
    expect(ObdResponseParser.decodeDtc(0x40, 0x35).code, 'C0035');
    expect(ObdResponseParser.decodeDtc(0x92, 0x34).code, 'B1234');
    expect(ObdResponseParser.decodeDtc(0xC1, 0x00).code, 'U0100');
    expect(ObdResponseParser.decodeDtc(0x2A, 0x0F).code, 'P2A0F');
  });

  test('PIDs del modo 01', () {
    expect(ObdResponseParser.coolantTemp('41 05 7B'), 83.0);
    expect(ObdResponseParser.engineRpm('410C1AF8'), 1726);
    expect(ObdResponseParser.speed('SEARCHING...\r410D32\r'), 50);
    expect(ObdResponseParser.fuelLevel('412FFF'), closeTo(100.0, 0.001));
    expect(ObdResponseParser.intakePressure('410B65'), 101);
    expect(ObdResponseParser.voltage('12.6V\r\r>'), 12.6);
    expect(ObdResponseParser.coolantTemp('NO DATA'), isNull);
    expect(ObdResponseParser.engineRpm('410C1A'), isNull);
  });

  test('VIN en varias tramas CAN', () {
    const raw = '014\r0:490201314731\r1:4A433534343452\r2:37323532333637\r>';
    expect(ObdResponseParser.vin(raw), '1G1JC5444R7252367');
    expect(ObdResponseParser.vin('NO DATA'), isNull);
  });

  test('VIN sin CAN llega en cinco líneas con secuencia', () {
    final raw = [
      '49020100000031',
      '49020247314A43',
      '49020335343434',
      '49020452373235',
      '49020532333637',
    ].join('\r');
    expect(ObdResponseParser.vin(raw), '1G1JC5444R7252367');
  });

  test('protocolo y respuestas sin la ECU', () {
    expect(
      ObdResponseParser.protocol('A6\r>'),
      'ISO 15765-4 CAN (11 bit, 500 kbaud)',
    );
    expect(ObdResponseParser.protocol('3'), 'ISO 9141-2');
    expect(
      ObdResponseParser.isNoResponse('SEARCHING...\rUNABLE TO CONNECT\r>'),
      isTrue,
    );
    expect(ObdResponseParser.isNoResponse('BUS INIT: ...ERROR'), isTrue);
    expect(ObdResponseParser.isNoResponse('?'), isTrue);
    expect(ObdResponseParser.isNoResponse(''), isTrue);
    expect(
      ObdResponseParser.isNoResponse('SEARCHING...\r41 00 BE 3E B8 11'),
      isFalse,
    );
    expect(ObdResponseParser.isNoData('NO DATA\r>'), isTrue);
    expect(ObdResponseParser.isOk('OK\r>'), isTrue);
  });

  test('cuadro congelado del modo 02', () {
    expect(ObdResponseParser.freezeFrameDtc('42 02 00 03 00')?.code, 'P0300');
    expect(ObdResponseParser.freezeFrameDtc('4202000000'), isNull);
    expect(ObdResponseParser.freezeFrameData('4205007B', '05'), [0x7B]);
  });
}
