import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// US42 E1/E2 (`invoicing:fiscal_config:manage`). Serie que no corresponde al tipo: `serie`;
/// correlativo negativo: `initialCorrelative`; serie repetida: 409 con su `message`.
class ConfigureSeriesUseCase {
  final CashierRepository repository;

  const ConfigureSeriesUseCase({required this.repository});

  Future<FiscalSeries> execute(
    VoucherType type,
    String serie, {
    int? initialCorrelative,
  }) {
    return repository.configureSeries(type, serie, initialCorrelative);
  }
}
