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
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/justification_review.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_labels.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// "Equipo": raíz de pestaña para quien audita la asistencia de la sede. Dice cuántos están en turno, lista a
/// cada colaborador del día y reúne los descargos que esperan decisión. Quien además marca su propia asistencia
/// tiene una segunda pestaña, "Mi asistencia".
///
/// Con Atrás (abierta desde otra pantalla) lleva barra con flecha; como raíz de pestaña, la cabecera de
/// destinos principales.
class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  late final AdminAttendanceViewModel viewModel = getIt<AdminAttendanceViewModel>();
  int _resolvedCount = 0;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_confirmDecision);
  }

  /// La decisión se confirma en la mano además de en la fila.
  void _confirmDecision() {
    final count = viewModel.state.resolved.length;
    if (count > _resolvedCount) rememberAtelierHaptics().confirm();
    _resolvedCount = count;
  }

  @override
  void dispose() {
    viewModel.removeListener(_confirmDecision);
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route) => AppNavigator.push(context, route);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return JustificationReviewHost(
      listenable: viewModel,
      reviewing: () => viewModel.state.reviewing,
      onDismiss: viewModel.onDismissJustification,
      sheetBuilder: (context, item) {
        final state = viewModel.state;
        final record = state.recordFor(item);
        return JustificationSheet(
          item: item,
          who: record == null
              ? null
              : collaboratorLabel(AppLocalizations.of(context), record, state.session),
          canApprove: state.canApproveJustifications,
          isOnline: state.isOnline,
          isSubmitting: state.isSubmittingReview,
          error: state.reviewError,
          onReview: viewModel.onReviewJustification,
        );
      },
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => AdminAttendanceContent(
          state: viewModel.state,
          onBack: canPop ? () => Navigator.of(context).maybePop() : null,
          onOpenNotifications: () => _open(AppRoute.notifications),
          onOpenSync: () => _open(AppRoute.pendingOperations),
          onOpenProfile: () => _open(AppRoute.profile),
          onTabChange: viewModel.onTabChange,
          onRefresh: viewModel.refresh,
          onOpenJustification: viewModel.onOpenJustification,
          // "Mi asistencia" embebida: la pantalla de la feature `attendance` sin barra superior.
          myAttendanceBuilder: (context) =>
              AppNavigator.build(context, AppRoute.attendanceDetail, true),
        ),
      ),
    );
  }
}

class AdminAttendanceContent extends StatelessWidget {
  final AdminAttendanceUiState state;
  final VoidCallback? onBack;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSync;
  final VoidCallback? onOpenProfile;
  final ValueChanged<TeamTab> onTabChange;
  final Future<void> Function() onRefresh;
  final ValueChanged<TeamAttendance> onOpenJustification;
  final WidgetBuilder? myAttendanceBuilder;

  const AdminAttendanceContent({
    super.key,
    required this.state,
    this.onBack,
    this.onOpenNotifications,
    this.onOpenSync,
    this.onOpenProfile,
    required this.onTabChange,
    required this.onRefresh,
    required this.onOpenJustification,
    this.myAttendanceBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final back = onBack;
    return Scaffold(
      body: Column(
        children: [
          if (back != null)
            AtelierTopBar(title: strings.teamTitle, onBack: back)
          else
            AtelierMainTopBar(
              title: strings.teamTitle,
              onOpenNotifications: onOpenNotifications,
              onOpenSync: onOpenSync,
              onOpenProfile: onOpenProfile,
            ),
          Expanded(child: _body(context, strings)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations strings) {
    if (!state.canAuditAll && !state.canClockIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.topCenter,
          child: AtelierNoPermissionState(text: strings.teamNoPermission),
        ),
      );
    }
    if (state.tab == TeamTab.mine || !state.canAuditAll) {
      return Column(
        children: [
          if (state.hasTabs) _TeamTabs(selected: state.tab, onTabChange: onTabChange),
          Expanded(child: myAttendanceBuilder?.call(context) ?? const SizedBox.shrink()),
        ],
      );
    }
    return _TeamList(
      state: state,
      onTabChange: onTabChange,
      onRefresh: onRefresh,
      onOpenJustification: onOpenJustification,
    );
  }
}

class _TeamTabs extends StatelessWidget {
  final TeamTab selected;
  final ValueChanged<TeamTab> onTabChange;

  const _TeamTabs({required this.selected, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AtelierSegmentedControl<TeamTab>(
        options: TeamTab.values,
        selected: selected,
        onSelect: onTabChange,
        label: (tab) => tab == TeamTab.team ? strings.teamTabTeam : strings.teamTabMine,
      ),
    );
  }
}

class _TeamList extends StatelessWidget {
  final AdminAttendanceUiState state;
  final ValueChanged<TeamTab> onTabChange;
  final Future<void> Function() onRefresh;
  final ValueChanged<TeamAttendance> onOpenJustification;

  const _TeamList({
    required this.state,
    required this.onTabChange,
    required this.onRefresh,
    required this.onOpenJustification,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: DelayedLoading(
        loading: state.showSkeleton,
        builder: (context, showSkeleton) => _list(context, showSkeleton),
      ),
    );
  }

  Widget _list(BuildContext context, bool showSkeleton) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    final children = <Widget>[
      _TeamPanel(state: state, loading: showSkeleton),
      AtelierRefreshBar(visible: state.isRefreshing && state.hasLoaded),
      if (state.hasTabs) _TeamTabs(selected: state.tab, onTabChange: onTabChange),
      if (!state.isOnline)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: AtelierBanner(
            message: strings.teamOffline,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          ),
        ),
      if (error != null && state.records.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
        ),
      ..._decisions(strings),
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: AtelierSectionHeader(
          title: strings.teamToday,
          count: state.hasLoaded ? state.records.length : null,
        ),
      ),
      ..._records(context, strings, showSkeleton, error),
    ];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24 + FloatingBarInset.of(context)),
      children: children,
    );
  }

  List<Widget> _records(
    BuildContext context,
    AppLocalizations strings,
    bool showSkeleton,
    Object? error,
  ) {
    if (showSkeleton) {
      return [
        for (var i = 0; i < 4; i++)
          const AtelierListRow(title: 'Colaborador', subtitle: 'Entrada', loading: true),
      ];
    }
    if (state.showSkeleton) return const [];
    const padding = EdgeInsets.symmetric(horizontal: 16);
    if (state.records.isEmpty && error != null && !state.isOnline) {
      return [Padding(padding: padding, child: AtelierOfflineState(onRetry: onRefresh))];
    }
    if (state.records.isEmpty && error != null) {
      return [
        Padding(
          padding: padding,
          child: AtelierErrorState(message: state.error!.asString(strings), onRetry: onRefresh),
        ),
      ];
    }
    if (state.records.isEmpty) {
      return [Padding(padding: padding, child: AtelierEmptyState(text: strings.teamEmpty))];
    }
    return [
      for (final record in state.records)
        _AttendanceRow(record: record, session: state.session),
    ];
  }

  /// Descargos por revisar. Sin nada pendiente (y sin consulta parcial), la sección no existe.
  List<Widget> _decisions(AppLocalizations strings) {
    if (state.justifications.isEmpty && state.failedJustificationDays == 0) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: AtelierSectionHeader(
          title: strings.todayDecisions,
          count: state.justifications.where((j) => !state.resolved.containsKey(j.id)).length,
        ),
      ),
      for (final item in state.justifications)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Builder(
            builder: (context) {
              final record = state.recordFor(item);
              final label = record == null
                  ? null
                  : collaboratorLabel(strings, record, state.session);
              return AtelierDecisionRow(
                title: justificationTitle(strings, item.status),
                subtitle: whoAndWhen(strings, item, label),
                resolved: switch (state.resolved[item.id]) {
                  true => strings.todayJustificationApproved,
                  false => strings.todayJustificationRejected,
                  null => null,
                },
                onClick: () => onOpenJustification(item),
              );
            },
          ),
        ),
      if (state.failedJustificationDays > 0)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AtelierBanner(
            message: strings.todayJustificationsPartial(state.failedJustificationDays),
            icon: Icons.info_outline,
            kind: BannerKind.wait,
          ),
        ),
    ];
  }
}

class _TeamPanel extends StatelessWidget {
  final AdminAttendanceUiState state;
  final bool loading;

  const _TeamPanel({required this.state, required this.loading});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final date = formatLimaDayShortOfDate(state.today);
    final branch = state.branchName;
    return AtelierReportPanel(
      context: branch == null ? date : strings.todayContext(branch, date),
      legend: strings.teamLegend(state.onShiftCount, state.records.length),
      caption: strings.teamCaption,
      loading: loading,
      figures: [
        PanelFigure(value: state.onTimeCount.toString(), label: strings.teamFigureOnTime),
        PanelFigure(value: state.lateCount.toString(), label: strings.teamFigureLate),
        PanelFigure(value: state.absentCount.toString(), label: strings.teamFigureAbsent),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final TeamAttendance record;
  final Session? session;

  const _AttendanceRow({required this.record, required this.session});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final clockIn = record.clockIn;
    final clockOut = record.clockOut;
    final status = record.status;
    final String subtitle;
    if (status == AttendanceStatus.absent || clockIn == null) {
      subtitle = strings.teamNoClockIn;
    } else if (clockOut != null) {
      subtitle = strings.teamClockRange(formatLimaTime(clockIn), formatLimaTime(clockOut));
    } else {
      subtitle = strings.teamClockInOpen(formatLimaTime(clockIn));
    }
    return AtelierListRow(
      title: collaboratorLabel(strings, record, session),
      subtitle: subtitle,
      trailing: status == null
          ? null
          : AtelierChip(
              text: attendanceStatusLabel(strings, status),
              kind: attendanceStatusChipKind(status),
            ),
    );
  }
}
