import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> codes(String raw, {bool? isCanProtocol}) {
  return ObdResponseParser.dtcs(
    raw,
    isCanProtocol: isCanProtocol,
  ).map((dtc) => dtc.code).toList();
}

void main() {
  group('isCanProtocol (ATDPN)', () {
    test('6 a C son CAN, con o sin la A de automático', () {
      for (final raw in ['6', 'A6', '7', 'A9', 'AA', 'B', 'AB', 'C', 'AC']) {
        expect(
          ObdResponseParser.isCanProtocol('$raw\r\r>'),
          isTrue,
          reason: raw,
        );
      }
    });

    test('1 a 5 son protocolos anteriores a CAN', () {
      for (final raw in ['1', 'A1', '3', 'A4', '5', 'A5']) {
        expect(
          ObdResponseParser.isCanProtocol('$raw\r\r>'),
          isFalse,
          reason: raw,
        );
      }
    });

    test('sin protocolo o desconocido da null', () {
      expect(ObdResponseParser.isCanProtocol(''), isNull);
      expect(ObdResponseParser.isCanProtocol('A\r>'), isNull);
      expect(ObdResponseParser.isCanProtocol('A0\r>'), isNull);
      expect(ObdResponseParser.isCanProtocol('NO DATA\r>'), isNull);
    });
  });

  group('dtcs según el protocolo', () {
    test(
      'en CAN el primer byte es la cantidad aunque la trama tenga largo par',
      () {
        const raw = '4301013300';
        expect(codes(raw), ['P0101', 'P3300']);
        expect(codes(raw, isCanProtocol: true), ['P0133']);
      },
    );

    test('en protocolos anteriores no hay byte de cantidad aunque el largo sea impar', () {
      const raw = '43 01 33 01 34 00';
      expect(codes(raw), ['P3301']);
      expect(codes(raw, isCanProtocol: false), ['P0133', 'P0134']);
    });

    test('sin protocolo conocido se infiere de la trama, como antes', () {
      expect(codes('43 02 01 33 81 34'), ['P0133', 'B0134']);
      expect(codes('43 01 33 00 00 00 00'), ['P0133']);
    });
  });
}
