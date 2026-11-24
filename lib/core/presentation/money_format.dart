import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// Importe con dos decimales y su símbolo: `S/ 1,250.00` o `US$ 40.00`. Es el importe neto, sin IGV.
extension MoneyFormat on Money {
  String format() => '${_currencySymbol(currency)} ${amount.formatAmount()}';
}

String _currencySymbol(String currency) =>
    currency == Money.usd ? 'US\$' : 'S/';

extension DecimalFormat on Decimal {
  /// Dos decimales (redondeo hacia arriba en el 5, como `String.format` de Java) y miles con coma.
  String formatAmount() {
    final fixed = round(scale: 2).toStringAsFixed(2);
    final negative = fixed.startsWith('-');
    final unsigned = negative ? fixed.substring(1) : fixed;
    final dot = unsigned.indexOf('.');
    final integer = unsigned.substring(0, dot);
    final fraction = unsigned.substring(dot);
    final grouped = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      if (i > 0 && (integer.length - i) % 3 == 0) grouped.write(',');
      grouped.write(integer[i]);
    }
    return '${negative ? '-' : ''}$grouped$fraction';
  }

  /// Cantidad sin ceros sobrantes: `2`, `1.5`.
  String formatQuantity() {
    final text = toStringAsFixed(scale);
    if (!text.contains('.')) return text;
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
