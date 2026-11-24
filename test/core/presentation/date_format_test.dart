import 'package:atelier_mobile_crossplatform/core/presentation/date_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTime.formatLimaDate', () {
    test('convierte el instante UTC a la fecha de Lima', () {
      expect(DateTime.utc(2026, 3, 5, 15).formatLimaDate(), '05/03/2026');
    });

    test('antes de las 05:00 UTC sigue en el día anterior de Lima', () {
      expect(DateTime.utc(2026, 3, 5, 4, 59).formatLimaDate(), '04/03/2026');
      expect(DateTime.utc(2026, 3, 5, 5).formatLimaDate(), '05/03/2026');
    });

    test('cruza el cambio de año', () {
      expect(DateTime.utc(2026, 1, 1, 2).formatLimaDate(), '31/12/2025');
    });

    test('un DateTime local equivale al mismo instante', () {
      final instant = DateTime.utc(2026, 7, 20, 3);
      expect(instant.toLocal().formatLimaDate(), '19/07/2026');
    });
  });
}
