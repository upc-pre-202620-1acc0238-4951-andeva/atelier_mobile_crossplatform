import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';

/// Caja del día de la sede: lo cobrado por medio de pago. Solo en línea y sin caché: no hay Drift para este
/// reporte. Los días son de Lima (`yyyy-MM-dd`).
class DailyCashUiState {
  final String today;
  final String date;
  final DailyCashSummary? summary;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canRead;

  const DailyCashUiState({
    required this.today,
    required this.date,
    this.summary,
    this.isLoading = true,
    this.isOnline = true,
    this.error,
    this.canRead = false,
  });

  bool get isToday => date == today;
  bool get canGoNext => date.compareTo(today) < 0;

  DailyCashUiState copyWith({
    String? date,
    DailyCashSummary? summary,
    bool clearSummary = false,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canRead,
  }) {
    return DailyCashUiState(
      today: today,
      date: date ?? this.date,
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : (error ?? this.error),
      canRead: canRead ?? this.canRead,
    );
  }
}
