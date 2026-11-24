import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/work_order_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Filtros rápidos en barra: Todas, Por cobrar (COMPLETED), En curso y Borrador.
const List<WorkOrderStatus?> _filterOptions = [
  null,
  WorkOrderStatus.completed,
  WorkOrderStatus.inProgress,
  WorkOrderStatus.draft,
];

String _filterSegmentLabel(AppLocalizations strings, WorkOrderStatus? status) => switch (status) {
  null => strings.ordersFilterAll,
  WorkOrderStatus.completed => strings.ordersFilterToCollect,
  _ => workOrderStatusLabel(strings, status),
};

/// Raíz de la pestaña "Órdenes": las órdenes sin cerrar de la sede, con filtro por estado y búsqueda por
/// placa. "Recibir vehículo" vive en el botón de acción de la barra flotante, no aquí.
class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  late final WorkOrdersViewModel viewModel = getIt<WorkOrdersViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => WorkOrdersContent(
        state: viewModel.state,
        onRefresh: viewModel.refresh,
        onOpenOrder: (id) => _open(AppRoute.workOrderDetail, id),
        onOpenNotifications: () => _open(AppRoute.notifications),
        onOpenSync: () => _open(AppRoute.pendingOperations),
        onStatusFilterChange: viewModel.onStatusFilterChange,
        onQueryChange: viewModel.onQueryChange,
      ),
    );
  }
}

class WorkOrdersContent extends StatelessWidget {
  final WorkOrdersUiState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onOpenOrder;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSync;
  final ValueChanged<WorkOrderStatus?> onStatusFilterChange;
  final ValueChanged<String> onQueryChange;

  /// Hora de referencia de "Actualizado hace N min" (se inyecta en las pruebas).
  final DateTime Function() now;

  const WorkOrdersContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onOpenOrder,
    required this.onOpenNotifications,
    required this.onOpenSync,
    required this.onStatusFilterChange,
    required this.onQueryChange,
    this.now = DateTime.now,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AtelierMainTopBar(
            title: strings.ordersListTitle,
            onOpenNotifications: onOpenNotifications,
            unreadNotificationsCount: state.unreadNotificationsCount,
            onOpenSync: onOpenSync,
            pendingSyncCount: state.pendingSyncCount,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: DelayedLoading(
                loading: state.showSkeleton && state.canRead,
                builder: (context, showSkeleton) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  children: _children(context, strings, showSkeleton),
                ),
              ),
            ),
          ),
        ],
      ).floatingBarPadding(),
    );
  }

  List<Widget> _children(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final error = state.error;
    final visible = state.visibleOrders;
    final refreshedAt = state.lastRefreshedAt;
    const horizontal = EdgeInsets.symmetric(horizontal: 16);
    return [
      AtelierRefreshBar(visible: state.isRefreshing && state.orders.isNotEmpty),
      if (!state.canRead)
        Padding(
          padding: horizontal,
          child: AtelierNoPermissionState(text: strings.ordersNoPermission),
        )
      else ...[
        _Filters(
          state: state,
          onStatusFilterChange: onStatusFilterChange,
          onQueryChange: onQueryChange,
        ),
        if (state.showingCache && state.orders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AtelierBanner(
              message: state.isOnline
                  ? error?.asString(strings) ?? strings.ordersCacheNotice
                  : strings.ordersCacheNotice,
              icon: Icons.info_outline,
              kind: BannerKind.info,
            ),
          ),
        if (refreshedAt != null) _UpdatedLine(refreshedAt: refreshedAt, now: now),
        if (showSkeleton)
          for (var i = 0; i < 6; i++)
            const AtelierListRow(title: 'Orden', subtitle: 'Cliente', plate: 'ABC123', loading: true)
        else if (state.showSkeleton)
          const SizedBox.shrink()
        else if (state.orders.isEmpty && error != null && !state.isOnline)
          Padding(padding: horizontal, child: AtelierOfflineState(onRetry: onRefresh))
        else if (state.orders.isEmpty && error != null)
          Padding(
            padding: horizontal,
            child: AtelierErrorState(message: error.asString(strings), onRetry: onRefresh),
          )
        else if (state.orders.isEmpty)
          Padding(
            padding: horizontal,
            child: AtelierEmptyState(text: strings.ordersEmpty),
          )
        else if (visible.isEmpty)
          Padding(
            padding: horizontal,
            child: AtelierEmptyState(text: strings.ordersEmptyFiltered),
          )
        else
          for (final order in visible)
            _OrderRow(order: order, onClick: () => onOpenOrder(order.id.value)),
      ],
    ];
  }
}

class _Filters extends StatelessWidget {
  final WorkOrdersUiState state;
  final ValueChanged<WorkOrderStatus?> onStatusFilterChange;
  final ValueChanged<String> onQueryChange;

  const _Filters({
    required this.state,
    required this.onStatusFilterChange,
    required this.onQueryChange,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          AtelierTextField(
            label: strings.ordersSearchLabel,
            value: state.query,
            onValueChange: onQueryChange,
            leadingIcon: Icons.search_outlined,
            trailing: state.query.isNotEmpty
                ? IconButton(
                    onPressed: () => onQueryChange(''),
                    tooltip: strings.ordersSearchClear,
                    icon: const Icon(Icons.clear_outlined),
                  )
                : null,
          ),
          AtelierSegmentedControl<WorkOrderStatus?>(
            options: _filterOptions,
            selected: state.statusFilter,
            onSelect: onStatusFilterChange,
            label: (status) => _filterSegmentLabel(strings, status),
            badge: (status) =>
                status == null ? 0 : state.orders.where((order) => order.status == status).length,
          ),
        ],
      ),
    );
  }
}

class _UpdatedLine extends StatelessWidget {
  final DateTime refreshedAt;
  final DateTime Function() now;

  const _UpdatedLine({required this.refreshedAt, required this.now});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final minutes = now().difference(refreshedAt).inMinutes.clamp(0, 1 << 30);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        minutes == 0 ? strings.ordersUpdatedNow : strings.ordersUpdatedAgo(minutes),
        style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onClick;

  const _OrderRow({required this.order, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final internalNumber = order.internalNumber;
    final number = internalNumber != null
        ? strings.ordersOrderNumber(internalNumber)
        : strings.ordersNoNumber;
    final customerName = order.customerName;
    final subtitle = [
      if (customerName != null) number,
      ?order.bayName,
    ].join(' · ');
    return AtelierListRow(
      title: customerName ?? number,
      subtitle: subtitle.isEmpty ? null : subtitle,
      plate: order.plate,
      onClick: onClick,
      trailing: AtelierChip(
        text: workOrderStatusLabel(strings, order.status),
        kind: workOrderStatusChipKind(order.status),
      ),
    );
  }
}
