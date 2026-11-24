import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.format', () {
    test('soles con miles y dos decimales', () {
      expect(Money.of('1234.5', Money.pen).format(), 'S/ 1,234.50');
      expect(Money.of('1250', Money.pen).format(), 'S/ 1,250.00');
      expect(Money.of('1234567.891', Money.pen).format(), 'S/ 1,234,567.89');
    });

    test('dólares con prefijo US\$', () {
      expect(Money.of('40', Money.usd).format(), 'US\$ 40.00');
    });

    test('sin miles por debajo de 1000 y cero', () {
      expect(Money.of('999.99', Money.pen).format(), 'S/ 999.99');
      expect(Money.of('0', Money.pen).format(), 'S/ 0.00');
    });

    test('redondea hacia arriba en el cinco', () {
      expect(Money.of('0.005', Money.pen).format(), 'S/ 0.01');
      expect(Money.of('2.675', Money.pen).format(), 'S/ 2.68');
    });
  });

  group('Decimal.formatQuantity', () {
    test('quita ceros sobrantes', () {
      expect(Decimal.parse('2').formatQuantity(), '2');
      expect(Decimal.parse('2.00').formatQuantity(), '2');
      expect(Decimal.parse('1.50').formatQuantity(), '1.5');
      expect(Decimal.parse('10.0').formatQuantity(), '10');
      expect(Decimal.parse('100').formatQuantity(), '100');
      expect(Decimal.parse('0.25').formatQuantity(), '0.25');
    });
  });
}
