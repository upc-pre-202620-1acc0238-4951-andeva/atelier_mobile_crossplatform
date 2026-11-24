import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pantalla de asistencia personal, geocerca GPS, turno semanal (US09) e historial con descargos (US10).
/// Con [embedded] va dentro de la pestaña "Mi asistencia" de `AdminAttendanceScreen`, sin barra superior.
class AttendanceScreen extends StatefulWidget {
  final bool embedded;

  const AttendanceScreen({super.key, this.embedded = false});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late final AttendanceViewModel viewModel = getIt<AttendanceViewModel>();
  final ValueNotifier<bool> _confirmClockOut = ValueNotifier(false);
  Object? _lastNotice;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_haptics);
    viewModel.previewLocationIfGranted();
  }

  void _haptics() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) {
      rememberAtelierHaptics().confirm();
    }
    if (state.error != null && !identical(state.error, _lastError)) {
      rememberAtelierHaptics().reject();
    }
    _lastNotice = state.notice;
    _lastError = state.error;
  }

  @override
  void dispose() {
    viewModel.removeListener(_haptics);
    _confirmClockOut.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateSheetHost<bool>(
      listenable: _confirmClockOut,
      value: () => _confirmClockOut.value ? true : null,
      onDismiss: () => _confirmClockOut.value = false,
      sheetBuilder: (context, _) => ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => ClockOutSheet(
          isSubmitting: viewModel.state.isSubmitting,
          onConfirm: () {
            _confirmClockOut.value = false;
            viewModel.clockOut();
          },
          onCancel: () => _confirmClockOut.value = false,
        ),
      ),
      child: StateSheetHost<Attendance>(
        listenable: viewModel,
        value: () => viewModel.state.justificationFor,
        onDismiss: viewModel.cancelJustification,
        sheetBuilder: (context, target) => JustificationSendSheet(
          target: target,
          state: viewModel.state,
          onChange: viewModel.onJustificationChange,
          onSubmit: viewModel.submitJustification,
        ),
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => AttendanceContent(
            state: viewModel.state,
            onBack: widget.embedded ? null : () => Navigator.of(context).maybePop(),
            onRefresh: viewModel.refresh,
            onLocate: viewModel.previewLocation,
            onClockIn: viewModel.clockIn,
            onRequestClockOut: () => _confirmClockOut.value = true,
            onRequestJustification: viewModel.requestJustification,
          ),
        ),
      ),
    );
  }
}

class AttendanceContent extends StatelessWidget {
  final AttendanceUiState state;
  final VoidCallback? onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback onLocate;
  final VoidCallback onClockIn;
  final VoidCallback onRequestClockOut;
  final ValueChanged<Attendance> onRequestJustification;

  const AttendanceContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRefresh,
    required this.onLocate,
    required this.onClockIn,
    required this.onRequestClockOut,
    required this.onRequestJustification,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final back = onBack;
    final skeletonLoading = state.isRefreshing && state.schedule == null && state.history.isEmpty;
    return Scaffold(
      body: Column(
        children: [
          if (back != null)
            AtelierTopBar(
              title: strings.attendanceTitle,
              onBack: back,
              actions: [
                IconButton(
                  onPressed: state.isRefreshing ? null : onRefresh,
                  tooltip: strings.baysRefresh,
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
          Expanded(
            child: DelayedLoading(
              loading: skeletonLoading,
              builder: (context, showSkeleton) => Column(
                children: [
                  AtelierRefreshBar(visible: state.isRefreshing && !showSkeleton),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: onRefresh,
                      child: _list(context, strings, showSkeleton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final session = state.session;
    final canClockInPerm = session?.has(Permission.attendanceClockIn) ?? false;
    final canClockOutPerm = session?.has(Permission.attendanceClockOut) ?? false;
    final canJustifyPerm = session?.has(Permission.justificationsCreate) ?? false;
    final notice = state.notice;
    final error = state.error;
    final warning = state.locationWarning;
    final schedule = state.schedule;
    const side = EdgeInsets.symmetric(horizontal: 16);
    final items = <Widget>[
      if (notice != null)
        Padding(
          padding: side,
          child: AtelierBanner(
            message: notice.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        ),
      if (error != null)
        Padding(
          padding: side,
          child: AtelierBanner(
            message: error.asString(strings),
            icon: Icons.error_outline,
            kind: BannerKind.bad,
          ),
        ),
      if (warning != null)
        Padding(
          padding: side,
          child: AtelierBanner(
            message: warning.asString(strings),
            icon: Icons.warning_amber_outlined,
            kind: BannerKind.wait,
          ),
        ),
      _ShiftAndGeofenceCard(
        state: state,
        loading: showSkeleton,
        canClockInPerm: canClockInPerm,
        canClockOutPerm: canClockOutPerm,
        onLocate: onLocate,
        onClockIn: onClockIn,
        onRequestClockOut: onRequestClockOut,
      ),
      Padding(
        padding: side,
        child: AtelierSectionHeader(title: strings.attendanceScheduleSection),
      ),
      if (showSkeleton)
        Padding(
          padding: side,
          child: AtelierGroupedCard(
            children: [
              for (var i = 0; i < 3; i++)
                AtelierListRow(
                  title: 'Lunes',
                  subtitle: '08:00 - 17:00',
                  loading: true,
                  showDivider: i < 2,
                ),
            ],
          ),
        )
      else if (schedule == null)
        Padding(
          padding: side,
          child: AtelierEmptyState(text: strings.attendanceNoBranchAssigned),
        )
      else
        Padding(padding: side, child: _WeeklyScheduleCard(schedule: schedule)),
      Padding(
        padding: side,
        child: AtelierSectionHeader(
          title: strings.attendanceHistorySection,
          count: state.history.isEmpty ? null : state.history.length,
        ),
      ),
      if (showSkeleton)
        for (var i = 0; i < 3; i++)
          const AtelierListRow(
            title: 'Lun 16 Nov · 08:04',
            subtitle: '8h 00m trabajados',
            loading: true,
          )
      else if (state.history.isEmpty)
        Padding(
          padding: side,
          child: AtelierEmptyState(text: strings.attendanceHistoryEmpty),
        )
      else
        for (final item in state.history)
          _AttendanceHistoryRow(
            attendance: item,
            canJustify: canJustifyPerm,
            onRequestJustification: () => onRequestJustification(item),
          ),
      if (onBack == null) SizedBox(height: FloatingBarInset.of(context)),
    ];
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) => items[index],
    );
  }
}

/// Hoja de confirmación de salida.
class ClockOutSheet extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ClockOutSheet({
    super.key,
    required this.isSubmitting,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.attendanceClockOutSheetTitle,
      actions: [
        AtelierButton(
          text: strings.attendanceClockOutConfirm,
          onClick: onConfirm,
          loading: isSubmitting,
          icon: Icons.logout_outlined,
        ),
        AtelierButton(
          text: strings.proposalsCancel,
          onClick: onCancel,
          style: AtelierButtonStyle.outlined,
          enabled: !isSubmitting,
        ),
      ],
      content: [
        Text(
          strings.attendanceClockOutSheetBody,
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
      ],
    );
  }
}

/// Hoja para escribir el descargo de una tardanza o ausencia.
class JustificationSendSheet extends StatelessWidget {
  final Attendance target;
  final AttendanceUiState state;
  final ValueChanged<String> onChange;
  final VoidCallback onSubmit;

  const JustificationSendSheet({
    super.key,
    required this.target,
    required this.state,
    required this.onChange,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.attendanceJustificationSheetTitle,
      actions: [
        AtelierButton(
          text: strings.attendanceJustificationSend,
          onClick: onSubmit,
          enabled: state.justification.trim().isNotEmpty && !state.isSubmitting,
          loading: state.isSubmitting,
          icon: Icons.edit_note_outlined,
        ),
      ],
      content: [
        Text(
          formatLimaDayTime(target.clockIn),
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        AtelierTextField(
          label: strings.attendanceJustificationFieldLabel,
          value: state.justification,
          onValueChange: onChange,
          placeholder: strings.attendanceJustificationFieldHint,
          enabled: !state.isSubmitting,
        ),
        Text(
          '${state.justification.length} / 500',
          style: context.text.labelMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
      ],
    );
  }
}

(String, ChipKind, IconData) _badgeFor(AppLocalizations strings, TodayAttendance today) {
  return switch (today) {
    ClockedIn() => (strings.floorHubShiftActive, ChipKind.ok, Icons.check_circle_outline),
    ClockInQueued() || ClockOutQueued() => (
      strings.floorHubShiftPending,
      ChipKind.idle,
      Icons.sync_outlined,
    ),
    Completed() => (strings.floorHubShiftClosed, ChipKind.info, Icons.schedule_outlined),
    NotClockedIn() => (strings.floorHubShiftIdle, ChipKind.warn, Icons.schedule_outlined),
  };
}

class _ShiftAndGeofenceCard extends StatelessWidget {
  final AttendanceUiState state;
  final bool loading;
  final bool canClockInPerm;
  final bool canClockOutPerm;
  final VoidCallback onLocate;
  final VoidCallback onClockIn;
  final VoidCallback onRequestClockOut;

  const _ShiftAndGeofenceCard({
    required this.state,
    required this.loading,
    required this.canClockInPerm,
    required this.canClockOutPerm,
    required this.onLocate,
    required this.onClockIn,
    required this.onRequestClockOut,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final branch = state.schedule?.branch;
    final shift = state.schedule?.shift;
    final location = state.deviceLocation;
    final geofence = branch != null && location != null ? Geofence.check(branch, location) : null;
    final (badgeText, badgeKind, badgeIcon) = _badgeFor(strings, state.today);

    final (geoText, geoKind) = geofence == null
        ? (strings.attendanceGeofencePending, ChipKind.idle)
        : geofence.isMock
        ? (strings.attendanceGeofenceMock, ChipKind.bad)
        : geofence.isInside
        ? (strings.attendanceGeofenceInside(geofence.distanceMeters.toInt()), ChipKind.ok)
        : (
            strings.attendanceGeofenceOutside(
              geofence.distanceMeters.toInt(),
              branch?.geofenceRadiusMeters.toInt() ?? 0,
            ),
            ChipKind.bad,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: heroShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Bone(
                        loading: loading,
                        widthFraction: 0.6,
                        child: Text(
                          branch?.name ?? strings.dashboardSelectBranchPrompt,
                          style: context.text.titleLarge?.copyWith(color: context.scheme.onSurface),
                        ),
                      ),
                      if (shift != null)
                        Bone(
                          loading: loading,
                          widthFraction: 0.75,
                          child: Text(
                            '${shift.name} · ${hourMinute(shift.startTime)} – ${hourMinute(shift.endTime)}',
                            style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    if (state.today is ClockedIn && !loading)
                      AtelierLiveBeacon(color: colors.okMark),
                    Bone(
                      loading: loading,
                      widthFraction: 0.3,
                      child: AtelierChip(text: badgeText, kind: badgeKind, icon: badgeIcon),
                    ),
                  ],
                ),
              ],
            ),
            _GeofenceRadarIndicator(
              geofence: geofence,
              radiusMeters: branch?.geofenceRadiusMeters,
              isLocating: state.isLocating,
              loading: loading,
              geoText: geoText,
              geoKind: geoKind,
              onLocate: onLocate,
            ),
            // Acciones principales en tamaño cómodo para fosa (56 dp).
            if (canClockInPerm && state.today is NotClockedIn)
              AtelierButton(
                text: strings.floorHubClockInCta,
                onClick: onClockIn,
                enabled: state.canClockIn,
                loading: state.isSubmitting,
                icon: Icons.login_outlined,
                minHeight: 56,
              )
            else if (canClockOutPerm && state.canClockOut)
              AtelierButton(
                text: strings.floorHubClockOutCta,
                onClick: onRequestClockOut,
                style: AtelierButtonStyle.outlined,
                enabled: state.canClockOut,
                loading: state.isSubmitting,
                icon: Icons.logout_outlined,
                minHeight: 56,
              )
            else if (state.today is ClockOutQueued)
              AtelierBanner(
                message: strings.attendanceClockOutQueued,
                icon: Icons.info_outline,
                kind: BannerKind.info,
              ),
          ],
        ),
      ),
    );
  }
}

/// Indicador geométrico radial de geocerca GPS: anillos concéntricos calibrados al radio permitido de sede,
/// vector de posición proporcional (`distanceMeters / geofenceRadiusMeters`) y baliza central, respetando
/// "quitar animaciones".
class _GeofenceRadarIndicator extends StatefulWidget {
  final GeofenceCheck? geofence;
  final double? radiusMeters;
  final bool isLocating;
  final bool loading;
  final String geoText;
  final ChipKind geoKind;
  final VoidCallback onLocate;

  const _GeofenceRadarIndicator({
    required this.geofence,
    required this.radiusMeters,
    required this.isLocating,
    required this.loading,
    required this.geoText,
    required this.geoKind,
    required this.onLocate,
  });

  @override
  State<_GeofenceRadarIndicator> createState() => _GeofenceRadarIndicatorState();
}

class _GeofenceRadarIndicatorState extends State<_GeofenceRadarIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSweep();
  }

  @override
  void didUpdateWidget(_GeofenceRadarIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  void _syncSweep() {
    final animate = widget.isLocating && !rememberReducedMotion(context);
    if (animate && !_sweep.isAnimating) {
      _sweep.repeat();
    } else if (!animate && _sweep.isAnimating) {
      _sweep.stop();
      _sweep.value = 0;
    }
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  double get _rawRatio {
    final geofence = widget.geofence;
    final radius = widget.radiusMeters;
    if (geofence == null) return 0;
    if (radius != null && radius > 0) return geofence.distanceMeters / radius;
    return geofence.isInside ? 0.40 : 1.25;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final geofence = widget.geofence;
    final radius = widget.radiusMeters;
    final reducedMotion = rememberReducedMotion(context);
    final statusColor = widget.isLocating
        ? atelierBlueSoft
        : geofence == null
        ? colors.inkSecondary
        : (geofence.isMock || !geofence.isInside)
        ? colors.badMark
        : colors.okMark;
    final target = _rawRatio.clamp(0.0, 1.35);
    return Row(
      spacing: 16,
      children: [
        SizedBox.square(
          dimension: 88,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: target),
                  duration: reducedMotion ? Duration.zero : const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  builder: (context, ratio, _) => AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) => CustomPaint(
                      painter: _RadarPainter(
                        outline: colors.outlineSoft,
                        statusColor: statusColor,
                        isMock: geofence?.isMock ?? false,
                        showDot: geofence != null && !widget.loading,
                        ratio: ratio,
                        locating: widget.isLocating && !reducedMotion,
                        sweep: Curves.easeOutQuint.transform(_sweep.value),
                      ),
                    ),
                  ),
                ),
              ),
              AtelierLiveBeacon(
                color: statusColor,
                size: 7,
                pulsing: widget.isLocating || (geofence != null && geofence.isInside && !geofence.isMock),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              AtelierChip(
                text: widget.isLocating ? strings.pitGeofenceLocating : widget.geoText,
                kind: widget.isLocating ? ChipKind.info : widget.geoKind,
                icon: Icons.gps_fixed_outlined,
              ),
              if (radius != null)
                Text(
                  strings.attendanceGeofenceRadius(radius.toInt()),
                  style: context.text.bodySmall?.copyWith(color: colors.inkSecondary),
                ),
              if (geofence != null && radius != null && radius > 0 && !widget.loading)
                AtelierMetricBar(
                  progress: (geofence.distanceMeters / radius).clamp(0.0, 1.0),
                  color: statusColor,
                  markerAt: 1,
                ),
              AtelierButton(
                text: strings.attendanceRetryLocation,
                onClick: widget.onLocate,
                style: AtelierButtonStyle.text,
                loading: widget.isLocating,
                icon: Icons.my_location_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Color outline;
  final Color statusColor;
  final bool isMock;
  final bool showDot;
  final double ratio;
  final bool locating;
  final double sweep;

  const _RadarPainter({
    required this.outline,
    required this.statusColor,
    required this.isMock,
    required this.showDot,
    required this.ratio,
    required this.locating,
    required this.sweep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2 - 4;
    final geofenceRadius = outerRadius * 0.72;
    final line = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Ejes de referencia ortogonales de instrumento.
    canvas.drawLine(
      Offset(center.dx - outerRadius, center.dy),
      Offset(center.dx + outerRadius, center.dy),
      line,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - outerRadius),
      Offset(center.dx, center.dy + outerRadius),
      line,
    );
    // Anillos concéntricos de escala (50 % interno y límite exterior).
    canvas.drawCircle(center, outerRadius, line);
    canvas.drawCircle(center, geofenceRadius * 0.5, line);

    // Anillo del radio permitido de sede.
    canvas.drawCircle(
      center,
      geofenceRadius,
      Paint()..color = statusColor.withValues(alpha: 0.08),
    );
    final boundary = Paint()
      ..color = statusColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    if (isMock) {
      _dashedCircle(canvas, center, geofenceRadius, boundary, dash: 6, gap: 4);
    } else {
      canvas.drawCircle(center, geofenceRadius, boundary);
    }

    if (locating) {
      canvas.drawCircle(
        center,
        geofenceRadius * sweep,
        Paint()
          ..color = atelierBlueSoft.withValues(alpha: (1 - sweep) * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Punto de posición proporcional a distanceMeters / geofenceRadiusMeters.
    if (showDot) {
      final double dotDistance;
      if (ratio <= 1) {
        dotDistance = geofenceRadius * ratio;
      } else {
        final overflow = ((ratio - 1) / 0.35).clamp(0.0, 1.0);
        final minOutside = geofenceRadius + 4;
        final maxOutside = outerRadius - 3;
        dotDistance = minOutside + (maxOutside - minOutside) * overflow;
      }
      final bearing = -38 * math.pi / 180;
      final dot = Offset(
        center.dx + dotDistance * math.cos(bearing),
        center.dy + dotDistance * math.sin(bearing),
      );
      canvas.drawLine(
        center,
        dot,
        Paint()
          ..color = statusColor.withValues(alpha: 0.55)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(dot, 8, Paint()..color = statusColor.withValues(alpha: 0.24));
      canvas.drawCircle(dot, 4, Paint()..color = statusColor);
    }
  }

  void _dashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    final circumference = 2 * math.pi * radius;
    final step = (dash + gap) / circumference * 2 * math.pi;
    final sweepAngle = dash / circumference * 2 * math.pi;
    for (var angle = 0.0; angle < 2 * math.pi; angle += step) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), angle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.outline != outline ||
      old.statusColor != statusColor ||
      old.isMock != isMock ||
      old.showDot != showDot ||
      old.ratio != ratio ||
      old.locating != locating ||
      old.sweep != sweep;
}

class _WeeklyScheduleCard extends StatelessWidget {
  final WeeklySchedule schedule;

  const _WeeklyScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final shift = schedule.shift;
    final days = schedule.days;
    final hours = '${hourMinute(shift.startTime)} – ${hourMinute(shift.endTime)}';
    return AtelierGroupedCard(
      children: [
        AtelierGroupedRow(
          title: shift.name,
          subtitle: strings.attendanceScheduleTolerance(shift.gracePeriodMinutes),
          icon: Icons.schedule_outlined,
          showChevron: false,
          showDivider: true,
        ),
        for (var index = 0; index < days.length; index++)
          AtelierListRow(
            title: _dayName(strings, days[index].day),
            subtitle: days[index].isWorkDay ? hours : null,
            showDivider: index < days.length - 1,
            trailing: AtelierChip(
              text: days[index].isWorkDay
                  ? strings.attendanceScheduleWorkday
                  : strings.attendanceScheduleRestday,
              kind: days[index].isWorkDay ? ChipKind.info : ChipKind.idle,
            ),
          ),
      ],
    );
  }

  String _dayName(AppLocalizations strings, WeekDay day) {
    return switch (day) {
      WeekDay.monday => strings.dayMonday,
      WeekDay.tuesday => strings.dayTuesday,
      WeekDay.wednesday => strings.dayWednesday,
      WeekDay.thursday => strings.dayThursday,
      WeekDay.friday => strings.dayFriday,
      WeekDay.saturday => strings.daySaturday,
      WeekDay.sunday => strings.daySunday,
    };
  }
}

class _AttendanceHistoryRow extends StatelessWidget {
  final Attendance attendance;
  final bool canJustify;
  final VoidCallback onRequestJustification;

  const _AttendanceHistoryRow({
    required this.attendance,
    required this.canJustify,
    required this.onRequestJustification,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final clockOut = attendance.clockOut;
    final worked = attendance.workedMinutes;
    final overtime = attendance.overtimeMinutes;
    final workedPart = worked == null
        ? null
        : strings.attendanceWorkedSummary(worked ~/ 60, worked % 60) +
              (overtime != null && overtime > 0 ? strings.attendanceOvertimeSummary(overtime) : '');
    final justification = switch (attendance.justificationStatus) {
      JustificationStatus.pending => strings.attendanceHistoryJustificationPending,
      JustificationStatus.approved => strings.attendanceHistoryJustificationApproved,
      JustificationStatus.rejected => strings.attendanceHistoryJustificationRejected,
      null => null,
    };
    final subtitle = [
      if (clockOut != null) strings.attendanceHistoryExit(formatLimaTime(clockOut)),
      ?workedPart,
      ?justification,
    ].join(' · ');

    final (chipLabel, chipKind) = switch (attendance.status) {
      AttendanceStatus.onTime => (strings.attendanceHistoryStatusOnTime, ChipKind.ok),
      AttendanceStatus.late => (strings.attendanceHistoryStatusLate, ChipKind.warn),
      AttendanceStatus.absent => (strings.attendanceHistoryStatusAbsent, ChipKind.bad),
      AttendanceStatus.excused => (strings.attendanceHistoryStatusExcused, ChipKind.info),
      null => (strings.attendanceHistoryStatusRegistered, ChipKind.idle),
    };
    final needsJustification =
        canJustify &&
        (attendance.status == AttendanceStatus.late || attendance.status == AttendanceStatus.absent) &&
        attendance.justificationStatus == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtelierListRow(
          title: formatLimaDayTime(attendance.clockIn),
          subtitle: subtitle.isEmpty ? null : subtitle,
          showDivider: !needsJustification,
          trailing: AtelierChip(text: chipLabel, kind: chipKind),
        ),
        if (needsJustification)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: AtelierButton(
                text: strings.attendanceJustificationSend,
                onClick: onRequestJustification,
                style: AtelierButtonStyle.tonal,
                icon: Icons.edit_note_outlined,
              ),
            ),
          ),
      ],
    );
  }
}
