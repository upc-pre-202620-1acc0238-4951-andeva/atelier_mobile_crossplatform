import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';

/// Bandeja: lo que pide atención (cola sin sincronizar, descargos, órdenes sin iniciar) y los avisos push de la
/// sesión. Sin alertas de stock: son la historia US34, fuera de esta versión.
class NotificationsUiState {
  final List<NotificationRecord> pushHistory;
  final List<TeamAttendance> pendingJustifications;
  final List<WorkOrder> draftOrdersWaitingApproval;
  final Session? session;
  final int pendingSyncCount;
  final bool isLoading;

  /// El teléfono deja mostrar notificaciones. Optimista hasta la primera lectura.
  final bool notificationsEnabled;
  final UiText? error;

  const NotificationsUiState({
    this.pushHistory = const [],
    this.pendingJustifications = const [],
    this.draftOrdersWaitingApproval = const [],
    this.session,
    this.pendingSyncCount = 0,
    this.isLoading = true,
    this.notificationsEnabled = true,
    this.error,
  });

  int get unreadPushCount => pushHistory.where((r) => !r.read).length;

  int get totalActiveAlerts =>
      pendingJustifications.length +
      draftOrdersWaitingApproval.length +
      (pendingSyncCount > 0 ? 1 : 0);

  NotificationsUiState copyWith({
    List<NotificationRecord>? pushHistory,
    List<TeamAttendance>? pendingJustifications,
    List<WorkOrder>? draftOrdersWaitingApproval,
    Session? session,
    int? pendingSyncCount,
    bool? isLoading,
    bool? notificationsEnabled,
    UiText? error,
    bool clearError = false,
  }) {
    return NotificationsUiState(
      pushHistory: pushHistory ?? this.pushHistory,
      pendingJustifications: pendingJustifications ?? this.pendingJustifications,
      draftOrdersWaitingApproval: draftOrdersWaitingApproval ?? this.draftOrdersWaitingApproval,
      session: session ?? this.session,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      isLoading: isLoading ?? this.isLoading,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      error: clearError ? null : error ?? this.error,
    );
  }
}
