import 'package:decimal/decimal.dart';

/// `Decimal`, no `double`, para no perder céntimos; Drift lo guarda como texto (06 §5).
class Money {
  static const pen = 'PEN';
  static const usd = 'USD';

  final Decimal amount;
  final String currency;

  Money({required this.amount, required this.currency}) {
    if (amount < Decimal.zero) {
      throw ArgumentError('Amount must be greater than or equal to 0');
    }
    if (currency != pen && currency != usd) {
      throw ArgumentError('Currency must be PEN or USD');
    }
  }

  factory Money.of(String amount, String currency) {
    return Money(amount: Decimal.parse(amount), currency: currency);
  }
}
