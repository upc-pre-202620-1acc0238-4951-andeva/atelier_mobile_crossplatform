import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_actions.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Dock de acción elevado en el tercio inferior para los controles primarios de fosa (Iniciar / Reanudar y
/// Pausar), con baliza en vivo cuando la labor está corriendo y objetivos táctiles ≥ 56 dp. El botón "Terminar
/// tarea" (US30) no se construye en el móvil.
class TaskPitActionDock extends StatelessWidget {
  final TaskDetailUiState state;
  final TaskDetailActions actions;

  const TaskPitActionDock({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final showStart = state.canTrackTime && (state.status == TaskStatus.assigned || state.isPausedByMechanic);
    final showPause = state.canTrackTime && state.status == TaskStatus.inProgress;
    if (!showStart && !showPause) return const SizedBox.shrink();

    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final haptics = rememberAtelierHaptics();
    final isRunning = state.status == TaskStatus.inProgress;
    final statusText = isRunning
        ? strings.pitDockRunning
        : state.isPausedByMechanic
        ? strings.pitDockPaused
        : strings.pitDockReady;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: AtelierSurface(
          tier: SurfaceTier.floating,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                spacing: 8,
                children: [
                  if (isRunning) AtelierLiveBeacon(color: colors.info, pulsing: true),
                  Text(
                    statusText,
                    style: context.text.labelLarge?.copyWith(
                      color: isRunning ? colors.primaryText : colors.inkSecondary,
                    ),
                  ),
                ],
              ),
              if (!state.isOnline) const AtelierRequiresConnection(),
              if (showStart)
                AtelierButton(
                  text: state.isPausedByMechanic ? strings.taskResume : strings.taskStart,
                  onClick: () {
                    haptics.confirm();
                    actions.onStart();
                  },
                  minHeight: 56,
                  enabled: state.canStart && state.isOnline,
                  loading: state.busyAction == TaskAction.start,
                  icon: Icons.play_arrow_outlined,
                )
              else
                AtelierButton(
                  text: strings.taskPause,
                  onClick: () {
                    haptics.toggle();
                    actions.onPauseClick();
                  },
                  style: AtelierButtonStyle.tonal,
                  minHeight: 56,
                  enabled: state.canPause && state.isOnline,
                  loading: state.busyAction == TaskAction.pause,
                  icon: Icons.pause_outlined,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
