import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Estado visual del cronómetro de labor efectiva. Nunca depende solo del color.
enum ChronometerVisualState { idle, running, paused, suspended }

/// Cronómetro de labor efectiva en fosa sobre [SurfaceTier.elevated] con marcas geométricas de
/// precisión y [AtelierChip] con baliza en vivo cuando está en marcha. Cifra única en Display
/// (cifras tabulares Satoshi Black) sin saltos horizontales ni animaciones distractoras.
class AtelierChronometer extends StatelessWidget {
  final String elapsedText;
  final String statusLabel;
  final ChronometerVisualState visualState;
  final String? caption;
  final bool loading;

  const AtelierChronometer({
    super.key,
    required this.elapsedText,
    required this.statusLabel,
    required this.visualState,
    this.caption,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final isRunning = visualState == ChronometerVisualState.running;
    final (chipKind, icon) = switch (visualState) {
      ChronometerVisualState.running => (
        ChipKind.info,
        Icons.play_circle_outlined,
      ),
      ChronometerVisualState.paused => (
        ChipKind.warn,
        Icons.pause_circle_outlined,
      ),
      ChronometerVisualState.suspended => (
        ChipKind.bad,
        Icons.warning_amber_outlined,
      ),
      ChronometerVisualState.idle => (ChipKind.idle, Icons.schedule_outlined),
    };
    final dialColor = isRunning
        ? colors.primaryText.withValues(alpha: 0.14)
        : colors.inkSecondary.withValues(alpha: 0.10);
    final captionText = caption;
    final semanticsLabel =
        '$statusLabel, $elapsedText${captionText == null ? '' : ', $captionText'}';

    return SizedBox(
      width: double.infinity,
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: heroShape,
        child: Semantics(
          container: true,
          label: semanticsLabel,
          excludeSemantics: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _DialPainter(dialColor)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Bone(
                          loading: loading,
                          widthFraction: 0.4,
                          child: AtelierChip(
                            text: statusLabel,
                            kind: chipKind,
                            icon: icon,
                            live: isRunning && !loading,
                          ),
                        ),
                        if (captionText != null &&
                            captionText.trim().isNotEmpty)
                          Flexible(
                            child: Bone(
                              loading: loading,
                              widthFraction: 0.35,
                              child: Text(
                                captionText,
                                style: context.text.bodyMedium?.copyWith(
                                  color: colors.inkSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Bone(
                      loading: loading,
                      widthFraction: 0.65,
                      child: Text(
                        elapsedText,
                        maxLines: 1,
                        style: context.text.displaySmall?.copyWith(
                          color: switch (visualState) {
                            ChronometerVisualState.running =>
                              colors.primaryText,
                            ChronometerVisualState.suspended => colors.bad,
                            _ => scheme.onSurface,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arco de esfera con 13 marcas (cada tercera, mayor) anclado abajo a la derecha de la tarjeta.
class _DialPainter extends CustomPainter {
  final Color color;

  const _DialPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.height * 0.85;
    final center = Offset(size.width * 0.92, size.height * 0.82);
    const startDeg = 185.0;
    const sweepDeg = 95.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startDeg * math.pi / 180,
      sweepDeg * math.pi / 180,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25
        ..strokeCap = StrokeCap.round,
    );

    const tickSteps = 12;
    for (var i = 0; i <= tickSteps; i++) {
      final angle = (startDeg + (sweepDeg / tickSteps) * i) * math.pi / 180;
      final isMajor = i % 3 == 0;
      final innerRadius = radius - (isMajor ? 8 : 4);
      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        Paint()
          ..color = color
          ..strokeWidth = isMajor ? 1.5 : 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_DialPainter old) => old.color != color;
}
