import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Estado de la bandeja de alertas de stock mínimo (US34).
class StockAlertsUiState {
  final List<StockAlert> alerts;
  final bool isLoading;
  final bool isOnline;
  final bool canRead;
  final UiText? error;

  const StockAlertsUiState({
    this.alerts = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.canRead = true,
    this.error,
  });

  StockAlertsUiState copyWith({
    List<StockAlert>? alerts,
    bool? isLoading,
    bool? isOnline,
    bool? canRead,
    UiText? error,
    bool clearError = false,
  }) {
    return StockAlertsUiState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      canRead: canRead ?? this.canRead,
      error: clearError ? null : error ?? this.error,
    );
  }
}
