import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_dtos.dart';

/// Comprobantes, cobros y series de docs/api/invoicing.md. Un 2xx sin cuerpo devuelve `null`: quien
/// llama decide si eso es "no se sabe" (H28).
class CashierApi {
  static const _base = '/api/v1/invoicing';

  final ApiClient client;

  const CashierApi({required this.client});

  /// `null` si el backend respondió 2xx sin cuerpo.
  Future<ElectronicVoucherDto?> issueVoucher(
    IssueVoucherRequestDto body,
  ) async {
    final json = await client.post('$_base/vouchers', body: body.toJson());
    return json == null
        ? null
        : ElectronicVoucherDto.fromJson(json as Map<String, dynamic>);
  }

  Future<ElectronicVoucherDto> getVoucher(String id) async {
    final Map<String, dynamic> json = await client.get('$_base/vouchers/$id');
    return ElectronicVoucherDto.fromJson(json);
  }

  Future<List<ElectronicVoucherDto>> getWorkOrderVouchers(
    String workOrderId,
  ) async {
    final List list = await client.get(
      '$_base/vouchers/work-order/$workOrderId',
    );
    return list
        .map((e) => ElectronicVoucherDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `null` si el backend respondió 2xx sin cuerpo.
  Future<VoucherPaymentDto?> registerPayment(
    RegisterPaymentRequestDto body,
  ) async {
    final json = await client.post('$_base/payments', body: body.toJson());
    return json == null
        ? null
        : VoucherPaymentDto.fromJson(json as Map<String, dynamic>);
  }

  Future<List<VoucherPaymentDto>> getVoucherPayments(String voucherId) async {
    final List list = await client.get('$_base/payments/voucher/$voucherId');
    return list
        .map((e) => VoucherPaymentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DailyReconciliationDto> getDaily(String branchId, String date) async {
    final Map<String, dynamic> json = await client.get(
      '$_base/payments/branch/$branchId/daily',
      query: {'date': date},
    );
    return DailyReconciliationDto.fromJson(json);
  }

  Future<List<SeriesConfigurationDto>> getBranchSeries(String branchId) async {
    final List list = await client.get(
      '$_base/series-configurations/branch/$branchId',
    );
    return list
        .map((e) => SeriesConfigurationDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SeriesConfigurationDto> configureSeries(
    ConfigureSeriesRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/series-configurations',
      body: body.toJson(),
    );
    return SeriesConfigurationDto.fromJson(json);
  }

  /// Responde 200 con cuerpo vacío.
  Future<void> setSeriesActive(String id, bool active) async {
    await client.put(
      '$_base/series-configurations/$id/status',
      body: {'active': active},
    );
  }
}
