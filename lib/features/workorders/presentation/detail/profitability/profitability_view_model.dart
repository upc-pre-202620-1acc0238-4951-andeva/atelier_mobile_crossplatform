import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_profitability_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:flutter/foundation.dart';

/// Estado de la tarjeta de rentabilidad (US35 E2).
class ProfitabilityUiState {
  final Profitability? profitability;
  final bool isLoading;
  final UiText? error;

  const ProfitabilityUiState({
    this.profitability,
    this.isLoading = false,
    this.error,
  });
}

/// Rentabilidad de una orden: ingresos de repuestos contra su costo de ventas FIFO. Se calcula a pedido y en
/// línea (`GET /work-orders/{id}/profitability`); no hay caché de este dato. Es un ViewModel aparte para no
/// engordar el de la ficha de la orden.
class ProfitabilityViewModel extends ChangeNotifier {
  final String workOrderId;
  final GetProfitabilityUseCase getProfitability;

  ProfitabilityViewModel({
    required this.workOrderId,
    required this.getProfitability,
  });

  ProfitabilityUiState _state = const ProfitabilityUiState();
  ProfitabilityUiState get state => _state;
  bool _disposed = false;

  Future<void> load() async {
    if (_state.isLoading) return;
    _update(
      ProfitabilityUiState(
        profitability: _state.profitability,
        isLoading: true,
      ),
    );
    try {
      final result = await getProfitability.execute(WorkOrderId(workOrderId));
      _update(ProfitabilityUiState(profitability: result));
    } on Object catch (e) {
      _update(
        ProfitabilityUiState(
          profitability: _state.profitability,
          error: toUiText(e),
        ),
      );
    }
  }

  void _update(ProfitabilityUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
