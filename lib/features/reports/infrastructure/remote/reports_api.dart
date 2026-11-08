import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:decimal/decimal.dart';

/// `CashFlowSummaryResource` (docs/api/invoicing.md).
class CashFlowSummaryDto {
  final Decimal? totalIncome;
  final Decimal? totalExpenses;
  final Decimal? accountsReceivable;
  final Decimal? netCashFlow;
  final String? currency;
  final List<CashFlowMovementDto> movements;

  const CashFlowSummaryDto({
    this.totalIncome,
    this.totalExpenses,
    this.accountsReceivable,
    this.netCashFlow,
    this.currency,
    this.movements = const [],
  });

  factory CashFlowSummaryDto.fromJson(Map<String, dynamic> json) {
    return CashFlowSummaryDto(
      totalIncome: decimalFromJson(json['totalIncome']),
      totalExpenses: decimalFromJson(json['totalExpenses']),
      accountsReceivable: decimalFromJson(json['accountsReceivable']),
      netCashFlow: decimalFromJson(json['netCashFlow']),
      currency: json['currency'] as String?,
      movements: [
        for (final movement in (json['movements'] as List?) ?? const [])
          CashFlowMovementDto.fromJson(movement as Map<String, dynamic>),
      ],
    );
  }
}

/// `CashFlowMovementResource`.
class CashFlowMovementDto {
  final String? transactionId;
  final String? movementDate;
  final String? type;
  final String? category;
  final String? concept;
  final String? referenceNumber;
  final Decimal? amount;
  final Decimal? runningBalance;

  const CashFlowMovementDto({
    this.transactionId,
    this.movementDate,
    this.type,
    this.category,
    this.concept,
    this.referenceNumber,
    this.amount,
    this.runningBalance,
  });

  factory CashFlowMovementDto.fromJson(Map<String, dynamic> json) {
    return CashFlowMovementDto(
      transactionId: json['transactionId'] as String?,
      movementDate: json['movementDate'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      concept: json['concept'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      amount: decimalFromJson(json['amount']),
      runningBalance: decimalFromJson(json['runningBalance']),
    );
  }
}

/// Flujo de caja (invoicing) y PDF de flota (iot). Las fechas son días de Lima; H30: sin sede.
class ReportsApi {
  final ApiClient client;

  const ReportsApi({required this.client});

  Future<CashFlowSummaryDto> getCashFlow(String from, String to) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/invoicing/financial-reports/cash-flow',
      query: {'from': from, 'to': to},
    );
    return CashFlowSummaryDto.fromJson(json);
  }

  Future<ApiFile> getCashFlowPdf(String from, String to) {
    return client.getBytes(
      '/api/v1/invoicing/financial-reports/cash-flow/pdf',
      query: {'from': from, 'to': to},
    );
  }

  Future<ApiFile> getFleetHealthPdf(String customerId) {
    return client.getBytes(
      '/api/v1/iot/health-reports/fleet/pdf',
      query: {'customerId': customerId},
    );
  }
}
