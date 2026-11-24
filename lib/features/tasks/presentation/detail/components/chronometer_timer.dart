import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chronometer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/labor_time.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/task_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

/// `HH:MM:SS` con horas sin tope.
String formatElapsed(int totalSeconds) {
  final seconds = totalSeconds < 0 ? 0 : totalSeconds;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(seconds ~/ 3600)}:${two((seconds % 3600) ~/ 60)}:${two(seconds % 60)}';
}

const unknownElapsed = '--:--:--';

/// Texto del cronómetro y si el tiempo de una tarea pausada se desconoce (D1).
class TimerDisplay {
  final String text;
  final bool unknown;

  const TimerDisplay(this.text, {required this.unknown});
}

/// Qué mostrar según el estado de la tarea. En marcha, cuenta desde `startedAt`. En pausa, el valor guardado al
/// pausar ([pausedElapsedSeconds]); sin él (la pausa se hizo en otro dispositivo) no se inventa un número: el backend
/// no envía la hora de la pausa y `now − startedAt` incluiría el tiempo pausado (D1).
TimerDisplay timerDisplay({
  required DateTime? startedAt,
  required int totalPausedSeconds,
  required bool running,
  required bool paused,
  required int? pausedElapsedSeconds,
  required DateTime now,
}) {
  if (running && startedAt != null) {
    return TimerDisplay(
      formatElapsed(LaborTime.effectiveSeconds(startedAt, totalPausedSeconds, now)),
      unknown: false,
    );
  }
  if (paused && pausedElapsedSeconds != null) {
    return TimerDisplay(formatElapsed(pausedElapsedSeconds), unknown: false);
  }
  if (paused) return const TimerDisplay(unknownElapsed, unknown: true);
  return TimerDisplay(formatElapsed(0), unknown: false);
}

/// Cronómetro de la labor efectiva (US27 E1) sobre [AtelierChronometer] con cifras tabulares.
/// Cuenta cada segundo mientras [running]; en pausa muestra el tiempo guardado al pausar y el total de pausas.
class ChronometerTimer extends StatefulWidget {
  final DateTime? startedAt;
  final int totalPausedSeconds;
  final bool running;
  final bool paused;
  final int? pausedElapsedSeconds;
  final TaskStatus? status;
  final HoldReason? holdReason;
  final bool suspended;
  final Decimal? estimatedHours;
  final bool loading;
  final DateTime Function() nowProvider;

  const ChronometerTimer({
    super.key,
    required this.startedAt,
    required this.totalPausedSeconds,
    required this.running,
    required this.paused,
    required this.pausedElapsedSeconds,
    this.status,
    this.holdReason,
    this.suspended = false,
    this.estimatedHours,
    this.loading = false,
    this.nowProvider = DateTime.now,
  });

  @override
  State<ChronometerTimer> createState() => _ChronometerTimerState();
}

class _ChronometerTimerState extends State<ChronometerTimer> {
  late DateTime _now = widget.nowProvider();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(ChronometerTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) {
      _now = widget.nowProvider();
      _syncTicker();
    }
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (widget.running) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = widget.nowProvider());
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final display = timerDisplay(
      startedAt: widget.startedAt,
      totalPausedSeconds: widget.totalPausedSeconds,
      running: widget.running,
      paused: widget.paused,
      pausedElapsedSeconds: widget.pausedElapsedSeconds,
      now: _now,
    );
    final visualState = widget.suspended
        ? ChronometerVisualState.suspended
        : widget.running
        ? ChronometerVisualState.running
        : widget.paused
        ? ChronometerVisualState.paused
        : ChronometerVisualState.idle;
    final statusLabel = taskStatusLabel(strings, widget.status, widget.holdReason);
    final estimated = widget.estimatedHours;
    final String? caption = widget.totalPausedSeconds > 0
        ? strings.taskTimerPausedTotal(formatElapsed(widget.totalPausedSeconds))
        : estimated != null
        ? strings.tasksSeg2TimerEstimated(estimated.formatQuantity())
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        AtelierChronometer(
          elapsedText: display.text,
          statusLabel: statusLabel,
          visualState: visualState,
          caption: caption,
          loading: widget.loading,
        ),
        if (display.unknown)
          Text(
            strings.taskTimerUnknownHint,
            style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
          ),
      ],
    );
  }
}
