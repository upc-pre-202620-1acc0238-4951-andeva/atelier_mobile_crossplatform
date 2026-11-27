import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_view_model.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Cuántas alertas de cada tipo se listan antes de mandar a su pantalla.
const _alertsPreview = 5;

/// Bandeja: arriba lo que pide atención (cola sin sincronizar, descargos, órdenes sin iniciar) y debajo los
/// avisos push de la sesión. Cada fila lleva a su destino. Lo no leído lleva el chip "Nuevo", no solo énfasis.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with WidgetsBindingObserver {
  late final NotificationsViewModel viewModel = getIt<NotificationsViewModel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Al volver de los ajustes del sistema se relee el permiso.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) viewModel.refreshNotificationsEnabled();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => NotificationsContent(
        state: viewModel.state,
        onEnableNotifications: viewModel.enableNotifications,
        onBack: () => Navigator.of(context).maybePop(),
        onRefresh: viewModel.refresh,
        onMarkAllRead: viewModel.onMarkAllRead,
        onOpenPushRecord: viewModel.onOpenPushRecord,
        onOpenOrder: (id) => _open(AppRoute.workOrderDetail, id),
        onOpenAttendanceReview: () => _open(AppRoute.adminAttendance),
        onOpenStockAlerts: () => _open(AppRoute.stockAlerts),
        onOpenSyncQueue: () => _open(AppRoute.pendingOperations),
      ),
    );
  }
}

class NotificationsContent extends StatelessWidget {
  final NotificationsUiState state;
  final VoidCallback onEnableNotifications;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onMarkAllRead;
  final ValueChanged<NotificationRecord> onOpenPushRecord;
  final ValueChanged<String> onOpenOrder;
  final VoidCallback onOpenAttendanceReview;
  final VoidCallback onOpenStockAlerts;
  final VoidCallback onOpenSyncQueue;

  const NotificationsContent({
    super.key,
    required this.state,
    required this.onEnableNotifications,
    required this.onBack,
    required this.onRefresh,
    required this.onMarkAllRead,
    required this.onOpenPushRecord,
    required this.onOpenOrder,
    required this.onOpenAttendanceReview,
    required this.onOpenStockAlerts,
    required this.onOpenSyncQueue,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final noCache = state.isLoading && state.pushHistory.isEmpty && state.totalActiveAlerts == 0;
    final children = <Widget>[
      if (!state.notificationsEnabled)
        _SurfaceCard(
          topPadding: 16,
          spacing: 12,
          children: [
            AtelierBanner(
              title: strings.notificationsDisabledTitle,
              message: strings.notificationsDisabledBody,
              icon: Icons.notifications_outlined,
              kind: BannerKind.wait,
            ),
            AtelierButton(
              text: strings.notificationsEnableBtn,
              onClick: onEnableNotifications,
              style: AtelierButtonStyle.tonal,
            ),
          ],
        ),
      if (state.totalActiveAlerts > 0) _AttentionSummary(count: state.totalActiveAlerts),
      ..._attention(context, strings),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 4, top: 8),
        child: AtelierSectionHeader(
          title: strings.notifSectionReceived,
          action: state.unreadPushCount > 0
              ? AtelierButton(
                  text: strings.notificationsMarkAllRead,
                  onClick: onMarkAllRead,
                  style: AtelierButtonStyle.text,
                )
              : null,
        ),
      ),
      if (noCache)
        for (var i = 0; i < 3; i++)
          const AtelierListRow(title: 'Aviso', subtitle: 'Detalle del aviso', loading: true)
      else if (state.pushHistory.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AtelierEmptyState(text: strings.notifEmpty),
        )
      else
        for (final record in state.pushHistory)
          _PushRecordRow(record: record, onClick: () => onOpenPushRecord(record)),
    ];
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.notifTitle, onBack: onBack),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "Piden tu atención": cada tipo con su conteo y su destino. Sin nada pendiente, la sección no existe.
  List<Widget> _attention(BuildContext context, AppLocalizations strings) {
    if (state.totalActiveAlerts == 0) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: AtelierSectionHeader(
          title: strings.notifSectionAttention,
          count: state.totalActiveAlerts,
        ),
      ),
      if (state.pendingSyncCount > 0)
        AtelierListRow(
          title: strings.notifSyncPending(state.pendingSyncCount),
          subtitle: strings.notifSyncPendingBody,
          onClick: onOpenSyncQueue,
          trailing: AtelierChip(text: strings.syncOpPending, kind: ChipKind.idle),
        ),
      for (final alert in state.stockAlerts.take(_alertsPreview))
        AtelierListRow(
          title: alert.name,
          subtitle: strings.notificationsStockDeficitLine(
            alert.sku,
            alert.currentStock.formatQuantity(),
            alert.minimumStock.formatQuantity(),
          ),
          onClick: onOpenStockAlerts,
          trailing: AtelierChip(text: strings.notificationsLowStockChip, kind: ChipKind.warn),
        ),
      for (final item in state.pendingJustifications)
        AtelierListRow(
          title: collaboratorLabel(strings, item, state.session),
          subtitle: _reasonOrNull(item.justificationReason),
          onClick: onOpenAttendanceReview,
          trailing: AtelierChip(text: strings.notificationsJustificationChip, kind: ChipKind.wait),
        ),
      for (final order in state.draftOrdersWaitingApproval.take(_alertsPreview))
        AtelierListRow(
          title: order.customerName ?? orderNumberLabel(strings, order),
          subtitle: strings.todayDecisionDraft,
          plate: order.plate,
          onClick: () => onOpenOrder(order.id.value),
          trailing: AtelierChip(text: strings.notifDraftChip, kind: ChipKind.wait),
        ),
    ];
  }

  String? _reasonOrNull(String? reason) =>
      reason != null && reason.trim().isNotEmpty ? reason : null;
}

class _SurfaceCard extends StatelessWidget {
  final double topPadding;
  final double spacing;
  final List<Widget> children;

  const _SurfaceCard({required this.topPadding, required this.spacing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: topPadding),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing,
          children: children,
        ),
      ),
    );
  }
}

class _AttentionSummary extends StatelessWidget {
  final int count;

  const _AttentionSummary({required this.count});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return _SurfaceCard(
      topPadding: 16,
      spacing: 6,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                AtelierLiveBeacon(color: colors.warnMark),
                Text(
                  strings.notifSummaryTitle,
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              ],
            ),
            AtelierChip(text: count.toString(), kind: ChipKind.wait),
          ],
        ),
        Text(
          strings.notifSummaryBody,
          style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
        ),
      ],
    );
  }
}

class _PushRecordRow extends StatelessWidget {
  final NotificationRecord record;
  final VoidCallback onClick;

  const _PushRecordRow({required this.record, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final subtitle = [
      record.body,
      formatLimaTime(record.receivedAt),
    ].where((part) => part.trim().isNotEmpty).join(' · ');
    return AtelierListRow(
      title: record.title ?? pushDefaultTitle(strings, record.destination),
      subtitle: subtitle,
      onClick: onClick,
      trailing: record.read ? null : AtelierChip(text: strings.notifUnread, kind: ChipKind.info),
    );
  }
}

/// Título cuando el push no trajo uno: lo que dice el destino.
String pushDefaultTitle(AppLocalizations strings, PushDestination? destination) {
  return switch (destination) {
    TaskDetailDestination() => strings.pushDefaultTitleTaskDetail,
    TaskSuspensionReviewDestination() => strings.pushDefaultTitleTaskSuspensionReview,
    TaskProductsDestination() => strings.pushDefaultTitleTaskProducts,
    WorkOrderDetailDestination() => strings.pushDefaultTitleWorkOrderDetail,
    LowStockAlertsDestination() => strings.pushDefaultTitleLowStock,
    CollaboratorAttendanceDestination() => strings.pushDefaultTitleCollaboratorAttendance,
    MyAttendanceDestination() => strings.pushDefaultTitleMyAttendance,
    ClockInDestination() => strings.pushDefaultTitleClockIn,
    null => strings.notifTitle,
  };
}
