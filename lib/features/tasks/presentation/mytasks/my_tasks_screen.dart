import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/task_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US26: bandeja de tareas asignadas en bahía.
/// Usa `AtelierMainTopBar` en raíz de pestaña o `AtelierTopBar` cuando se llega con pila atrás.
class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  late final MyTasksViewModel viewModel = getIt<MyTasksViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  @override
  Widget build(BuildContext context) {
    // En la raíz de una pestaña la barra flotante deja un hueco: no hay "atrás".
    final isTabRoot = FloatingBarInset.of(context) > 0;
    final canPop = !isTabRoot && Navigator.of(context).canPop();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => MyTasksContent(
        state: viewModel.state,
        onBack: canPop ? () => Navigator.of(context).maybePop() : null,
        onRefresh: viewModel.refresh,
        onFilterChange: viewModel.onFilterChange,
        onOpenTask: (task) => _open(
          AppRoute.taskDetail,
          TaskDetailArgs(workOrderId: task.workOrderId, taskId: task.id.value),
        ),
        onOpenNotifications: () => _open(AppRoute.notifications),
        onOpenSync: () => _open(AppRoute.pendingOperations),
        onOpenProfile: () => _open(AppRoute.profile),
      ),
    );
  }
}

class MyTasksContent extends StatelessWidget {
  final MyTasksUiState state;
  final VoidCallback? onBack;
  final Future<void> Function() onRefresh;
  final ValueChanged<TaskFilter> onFilterChange;
  final ValueChanged<Task> onOpenTask;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSync;
  final VoidCallback? onOpenProfile;

  const MyTasksContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onFilterChange,
    required this.onOpenTask,
    this.onOpenNotifications,
    this.onOpenSync,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = state.isWorkshopScope ? strings.tasksWorkshopTitle : strings.tasksTitle;
    final back = onBack;
    return Scaffold(
      body: Column(
        children: [
          if (back != null)
            AtelierTopBar(title: title, onBack: back)
          else
            AtelierMainTopBar(
              title: title,
              onOpenNotifications: onOpenNotifications,
              unreadNotificationsCount: state.unreadNotificationsCount,
              onOpenSync: onOpenSync,
              pendingSyncCount: state.pendingSyncCount,
              onOpenProfile: onOpenProfile,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: DelayedLoading(
                loading: state.showSkeleton,
                builder: (context, showSkeleton) => FloatingBarPadding(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    children: _items(context, strings, showSkeleton),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _padded(Widget child, {EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16)}) =>
      Padding(padding: padding, child: child);

  List<Widget> _items(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    if (!state.canRead) {
      return [_padded(AtelierNoPermissionState(text: strings.tasksNoPermission))];
    }
    final visible = state.visibleTasks;
    final error = state.error;
    return [
      _SummaryPanel(state: state, loading: showSkeleton, onFilterChange: onFilterChange),
      AtelierRefreshBar(visible: state.isRefreshing && state.tasks.isNotEmpty),
      _FilterRow(state: state, onFilterChange: onFilterChange),
      if (state.showingCache && state.tasks.isNotEmpty)
        _padded(
          AtelierBanner(
            message: error?.asString(strings) ?? strings.tasksCacheNotice,
            icon: Icons.wifi_off_outlined,
            kind: BannerKind.wait,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      if (showSkeleton)
        for (var i = 0; i < 5; i++)
          const AtelierListRow(
            title: 'Cambio de pastillas de freno',
            subtitle: 'Bahía B-2 · OT #1042 · 1.5 h estimadas',
            plate: 'ABC123',
            loading: true,
          )
      else if (state.showSkeleton)
        const SizedBox.shrink()
      else if (state.tasks.isEmpty && error != null && !state.isOnline)
        _padded(AtelierOfflineState(onRetry: onRefresh))
      else if (state.tasks.isEmpty && error != null)
        _padded(AtelierErrorState(message: error.asString(strings), onRetry: onRefresh))
      else if (state.tasks.isEmpty)
        _padded(
          AtelierEmptyState(
            text: state.isWorkshopScope ? strings.tasksWorkshopEmpty : strings.tasksEmpty,
            actionLabel: strings.tasksRefresh,
            onAction: onRefresh,
          ),
        )
      else if (visible.isEmpty)
        _padded(
          AtelierEmptyState(
            text: strings.tasksSeg2EmptyFiltered,
            actionLabel: strings.catalogClearFilters,
            onAction: () => onFilterChange(TaskFilter.all),
          ),
        )
      else
        for (final task in visible)
          _TaskRow(key: ValueKey(task.id.value), task: task, onClick: () => onOpenTask(task)),
    ];
  }
}

class _SummaryPanel extends StatelessWidget {
  final MyTasksUiState state;
  final bool loading;
  final ValueChanged<TaskFilter> onFilterChange;

  const _SummaryPanel({required this.state, required this.loading, required this.onFilterChange});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final count = state.tasks.length;
    return AtelierReportPanel(
      context: state.tenantName.trim().isEmpty ? strings.tasksSeg2PanelContext : state.tenantName,
      legend: loading ? '4 tareas' : strings.tasksSeg2LegendCount(count),
      caption: state.isWorkshopScope ? strings.tasksWorkshopPanelCaption : strings.tasksSeg2PanelCaption,
      figures: [
        PanelFigure(
          value: state.pendingCount.toString(),
          label: strings.tasksSeg2FigurePending,
          onClick: () => onFilterChange(TaskFilter.assigned),
        ),
        PanelFigure(
          value: state.inProgressCount.toString(),
          label: strings.tasksSeg2FigureInProgress,
          onClick: () => onFilterChange(TaskFilter.inProgress),
        ),
        PanelFigure(
          value: state.pausedCount.toString(),
          label: strings.tasksSeg2FigurePaused,
          onClick: () => onFilterChange(TaskFilter.paused),
        ),
      ],
      loading: loading,
    );
  }
}

class _FilterRow extends StatelessWidget {
  final MyTasksUiState state;
  final ValueChanged<TaskFilter> onFilterChange;

  const _FilterRow({required this.state, required this.onFilterChange});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: AtelierSegmentedControl<TaskFilter>(
        options: TaskFilter.values,
        selected: state.selectedFilter,
        onSelect: onFilterChange,
        label: (filter) => switch (filter) {
          TaskFilter.all => strings.ordersFilterAll,
          TaskFilter.inProgress => strings.taskStatusInProgress,
          TaskFilter.paused => strings.taskStatusOnHold,
          TaskFilter.assigned => strings.tasksSeg2FilterAssigned,
          TaskFilter.suspended => strings.tasksSeg2FilterSuspended,
        },
        badge: (filter) => switch (filter) {
          TaskFilter.all => 0,
          TaskFilter.inProgress => state.inProgressCount,
          TaskFilter.paused => state.mechanicPausedCount,
          TaskFilter.assigned => state.pendingCount,
          TaskFilter.suspended => state.suspendedCount,
        },
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final VoidCallback onClick;

  const _TaskRow({super.key, required this.task, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final estimated = task.estimatedHours;
    final bay = task.bayName;
    final number = task.workOrderNumber;
    final meta = [
      if (bay != null) strings.taskCardBay(bay),
      if (number != null) strings.taskCardWorkOrder(number),
      if (estimated != null) strings.taskCardEstimated(estimated.formatQuantity()),
    ].join(' · ');

    final String chipLabel;
    final ChipKind chipKind;
    if (task.hasPendingSuspension) {
      chipLabel = strings.taskSuspensionPending;
      chipKind = ChipKind.wait;
    } else {
      chipLabel = taskStatusLabel(strings, task.status, task.holdReason);
      chipKind = taskStatusChipKind(task.status, task.holdReason);
    }

    final serviceName = task.serviceName;
    return AtelierListRow(
      title: serviceName ?? task.description,
      subtitle: meta.isNotEmpty ? meta : (serviceName != null ? task.description : null),
      plate: task.plate,
      leading: task.plate == null
          ? Text(
              strings.tasksSeg2MetaNoPlate,
              style: context.text.labelLarge?.copyWith(color: context.scheme.onSurfaceVariant),
            )
          : null,
      onClick: onClick,
      trailing: AtelierChip(text: chipLabel, kind: chipKind),
    );
  }
}
