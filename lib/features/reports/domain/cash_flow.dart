import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// Un dato del reporte no es válido; [field] dice cuál (`period`, `customerId`).
class InvalidReportInputException implements Exception {
  final String field;

  const InvalidReportInputException(this.field);

  @override
  String toString() => 'InvalidReportInputException: $field';
}

/// Rango de días de Lima (`yyyy-MM-dd`), ambos incluidos. Lanza `period` si [from] es posterior a [to].
class ReportPeriod {
  final String from;
  final String to;

  ReportPeriod(this.from, this.to) {
    if (from.compareTo(to) > 0) {
      throw const InvalidReportInputException('period');
    }
  }

  /// Del 1 al último día del mes ([month] de 1 a 12).
  factory ReportPeriod.month(int year, int month) {
    final first = DateTime.utc(year, month);
    final last = DateTime.utc(year, month + 1, 0);
    return ReportPeriod(_date(first), _date(last));
  }

  factory ReportPeriod.year(int year) {
    return ReportPeriod('${_pad(year, 4)}-01-01', '${_pad(year, 4)}-12-31');
  }

  /// Mes en curso según el día de Lima.
  factory ReportPeriod.currentMonth(BusinessTime time) {
    final today = DateTime.parse(time.today());
    return ReportPeriod.month(today.year, today.month);
  }

  static String _date(DateTime day) =>
      '${_pad(day.year, 4)}-${_pad(day.month, 2)}-${_pad(day.day, 2)}';

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');
}

/// Movimiento del flujo de caja. [amount] y [runningBalance] pueden ser negativos.
class CashFlowMovement {
  final String transactionId;
  final DateTime movementDate;
  final String type;
  final String category;
  final String concept;
  final String referenceNumber;
  final Decimal amount;
  final Decimal runningBalance;

  const CashFlowMovement({
    required this.transactionId,
    required this.movementDate,
    required this.type,
    required this.category,
    required this.concept,
    required this.referenceNumber,
    required this.amount,
    required this.runningBalance,
  });
}

/// Flujo de caja del taller completo, todas las sedes (H30). H31: [accountsReceivable] y
/// [totalExpenses] llegan siempre en 0 y [currency] siempre dice `PEN` aunque se sumen USD: no
/// mostrarlos como cifras reales. [netCashFlow] puede ser negativo.
class CashFlowSummary {
  final Money totalIncome;
  final Money totalExpenses;
  final Money accountsReceivable;
  final Decimal netCashFlow;
  final String currency;
  final List<CashFlowMovement> movements;

  const CashFlowSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.accountsReceivable,
    required this.netCashFlow,
    required this.currency,
    required this.movements,
  });
}
