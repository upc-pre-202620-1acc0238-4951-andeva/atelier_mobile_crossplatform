import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Baliza de estado en vivo: punto sólido con halo pulsante.
/// Se detiene automáticamente cuando "quitar animaciones" del sistema está activo o [pulsing] es falso.
class AtelierLiveBeacon extends StatefulWidget {
  final Color color;

  /// Diámetro del punto; el lienzo mide el doble para el halo.
  final double size;
  final bool pulsing;

  const AtelierLiveBeacon({
    super.key,
    required this.color,
    this.size = 8,
    this.pulsing = true,
  });

  @override
  State<AtelierLiveBeacon> createState() => _AtelierLiveBeaconState();
}

class _AtelierLiveBeaconState extends State<AtelierLiveBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: easeOutQuint,
  );

  bool _shouldPulse = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AtelierLiveBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    _shouldPulse = widget.pulsing && !rememberReducedMotion(context);
    if (_shouldPulse) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: widget.size * 2,
        child: CustomPaint(
          painter: _BeaconPainter(
            color: widget.color,
            dotSize: widget.size,
            pulsing: _shouldPulse,
            progress: _progress,
          ),
        ),
      ),
    );
  }
}

class _BeaconPainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final bool pulsing;
  final Animation<double> progress;

  _BeaconPainter({
    required this.color,
    required this.dotSize,
    required this.pulsing,
    required this.progress,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final coreRadius = math.min(dotSize / 2, size.shortestSide / 2);
    final center = Offset(size.width / 2, size.height / 2);

    if (pulsing) {
      final t = progress.value;
      canvas.drawCircle(
        center,
        coreRadius + coreRadius * t,
        Paint()..color = color.withValues(alpha: (1 - t) * 0.45),
      );
    } else {
      canvas.drawCircle(
        center,
        coreRadius * 1.45,
        Paint()..color = color.withValues(alpha: 0.20),
      );
    }
    canvas.drawCircle(center, coreRadius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BeaconPainter old) =>
      old.color != color || old.dotSize != dotSize || old.pulsing != pulsing;
}

/// Barra métrica fina con extremos redondeados, relleno degradado suave, animación por resorte
/// críticamente amortiguado ([AtelierSprings.criticallyDamped]) y marca de umbral opcional.
class AtelierMetricBar extends StatefulWidget {
  /// Entre 0 y 1; fuera de rango se recorta.
  final double progress;
  final Color color;

  /// Por defecto `context.atelier.surfaceRecessed`.
  final Color? trackColor;
  final double height;

  /// Posición de la marca de umbral (0 a 1); `null` no la dibuja.
  final double? markerAt;

  const AtelierMetricBar({
    super.key,
    required this.progress,
    required this.color,
    this.trackColor,
    this.height = 6,
    this.markerAt,
  });

  @override
  State<AtelierMetricBar> createState() => _AtelierMetricBarState();
}

class _AtelierMetricBarState extends State<AtelierMetricBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: _target,
  );

  double get _target => widget.progress.clamp(0.0, 1.0);

  @override
  void didUpdateWidget(AtelierMetricBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress == widget.progress) return;
    if (rememberReducedMotion(context)) {
      _controller.value = _target;
    } else {
      _controller.animateWith(
        SpringSimulation(
          AtelierSprings.criticallyDamped(),
          _controller.value,
          _target,
          _controller.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    return ExcludeSemantics(
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: CustomPaint(
          painter: _MetricBarPainter(
            animation: _controller,
            color: widget.color,
            trackColor: widget.trackColor ?? colors.surfaceRecessed,
            markerColor: colors.inkSecondary.withValues(alpha: 0.75),
            markerAt: widget.markerAt,
          ),
        ),
      ),
    );
  }
}

class _MetricBarPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final Color trackColor;
  final Color markerColor;
  final double? markerAt;

  _MetricBarPainter({
    required this.animation,
    required this.color,
    required this.trackColor,
    required this.markerColor,
    required this.markerAt,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = trackColor,
    );

    // El resorte no rebota, pero se recorta por seguridad.
    final value = animation.value.clamp(0.0, 1.0);
    if (value > 0) {
      final fillWidth = math.min(
        math.max(size.width * value, size.height),
        size.width,
      );
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(fillRect, radius),
        Paint()
          ..shader = LinearGradient(
            colors: [color.withValues(alpha: 0.85), color],
          ).createShader(fillRect),
      );
    }

    final marker = markerAt;
    if (marker != null) {
      final x = (size.width * marker.clamp(0.0, 1.0))
          .clamp(1.0, math.max(1.0, size.width - 1))
          .toDouble();
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = markerColor
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MetricBarPainter old) =>
      old.color != color ||
      old.trackColor != trackColor ||
      old.markerColor != markerColor ||
      old.markerAt != markerAt;
}
