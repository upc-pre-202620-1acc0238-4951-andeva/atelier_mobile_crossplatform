import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// US42: series de la sede de la sesión.
class GetBranchSeriesUseCase {
  final CashierRepository repository;

  const GetBranchSeriesUseCase({required this.repository});

  Future<List<FiscalSeries>> execute() => repository.getBranchSeries();
}
