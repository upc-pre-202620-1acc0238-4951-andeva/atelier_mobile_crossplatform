import 'package:decimal/decimal.dart';

/// `number` del JSON a `Decimal` por su texto: `num.toString` da el valor más corto, sin ruido de `double`.
Decimal? decimalFromJson(Object? value) {
  return value == null ? null : Decimal.parse(value.toString());
}
