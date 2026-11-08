import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';

/// US42: activa o desactiva una serie.
class SetSeriesActiveUseCase {
  final CashierRepository repository;

  const SetSeriesActiveUseCase({required this.repository});

  Future<void> execute(String id, bool active) =>
      repository.setSeriesActive(id, active);
}
