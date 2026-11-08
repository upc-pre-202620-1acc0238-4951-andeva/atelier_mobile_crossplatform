import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// US38: caja de la sede de la sesión. [date] es un día de Lima (`BusinessTime`).
class GetDailyCashSummaryUseCase {
  final CashierRepository repository;

  const GetDailyCashSummaryUseCase({required this.repository});

  Future<DailyCashSummary> execute(String date) =>
      repository.getDailyCashSummary(date);
}
