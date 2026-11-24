import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// Ease-out exponencial del diseño: `cubic-bezier(0.23, 1, 0.32, 1)`.
const easeOutQuint = Cubic(0.23, 1, 0.32, 1);

/// Ease-out expo de la barra flotante: `cubic-bezier(0.16, 1, 0.3, 1)`, el mismo de quina-webapp.
const easeOutExpo = Cubic(0.16, 1, 0.3, 1);

/// Resortes del sistema (apple-design + DESIGN.md): amortiguación crítica por defecto, rebote solo en
/// gestos con impulso. Rigideces equivalentes a las de Compose (masa 1).
abstract final class AtelierSprings {
  static const double _stiffnessMedium = 1500;
  static const double _stiffnessMediumLow = 400;

  static SpringDescription criticallyDamped() =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: _stiffnessMediumLow, ratio: 1);

  static SpringDescription snappy() =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: _stiffnessMedium, ratio: 1);

  /// Resorte rápido sin rebote para el indicador del dock y segmented control.
  static SpringDescription dock() =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: 750, ratio: 1);

  static SpringDescription flick() =>
      SpringDescription.withDampingRatio(mass: 1, stiffness: _stiffnessMediumLow, ratio: 0.8);
}

/// Háptica armonizada en el mismo cuadro visual (solo momentos de compromiso: confirmar, error, marcación).
class AtelierHaptics {
  const AtelierHaptics();

  void confirm() => HapticFeedback.mediumImpact();
  void reject() => HapticFeedback.heavyImpact();
  void toggle() => HapticFeedback.selectionClick();
  void longPress() => HapticFeedback.heavyImpact();
}

/// Equivalente a `rememberAtelierHaptics()`: no tiene estado, basta una instancia constante.
AtelierHaptics rememberAtelierHaptics() => const AtelierHaptics();

/// "Quitar animaciones" del sistema: reactivo en vivo (MediaQuery se reconstruye al cambiar el ajuste).
bool rememberReducedMotion(BuildContext context) => MediaQuery.disableAnimationsOf(context);

/// Entrada escalonada de la pantalla: sube 8 dp y aparece en 240 ms; cada [index] se retrasa 50 ms.
/// Solo para pantallas ocasionales (acceso, alta): lo que se abre decenas de veces al día no se anima.
class Rise extends StatefulWidget {
  final int index;
  final Widget child;

  const Rise({super.key, this.index = 0, required this.child});

  @override
  State<Rise> createState() => _RiseState();
}

class _RiseState extends State<Rise> with SingleTickerProviderStateMixin {
  static const _durationMs = 240;
  static const _offset = 8.0;

  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delayMs = widget.index * 50;
    final totalMs = delayMs + _durationMs;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: totalMs));
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayMs / totalMs, 1, curve: easeOutQuint),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (rememberReducedMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final value = _progress.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, (1 - value) * _offset), child: child),
        );
      },
    );
  }
}

/// Al presionar el control se encoge a [pressed] (97 % por defecto, 120 ms).
/// El estado de presión lo aporta el control ([isPressed]), p. ej. desde `InkWell.onHighlightChanged`.
class PressScale extends StatelessWidget {
  final bool isPressed;
  final double pressed;
  final Widget child;

  const PressScale({super.key, required this.isPressed, this.pressed = 0.97, required this.child});

  @override
  Widget build(BuildContext context) {
    if (rememberReducedMotion(context)) return child;
    return AnimatedScale(
      scale: isPressed ? pressed : 1,
      duration: const Duration(milliseconds: 120),
      curve: easeOutQuint,
      child: child,
    );
  }
}

/// Al presionar el control se encoge a [pressed] usando un resorte críticamente amortiguado,
/// manteniendo continuidad e interrumpibilidad si el usuario suelta o vuelve a tocar a mitad del gesto.
class SpringPressScale extends StatefulWidget {
  final bool isPressed;
  final double pressed;
  final Widget child;

  const SpringPressScale({super.key, required this.isPressed, this.pressed = 0.97, required this.child});

  @override
  State<SpringPressScale> createState() => _SpringPressScaleState();
}

class _SpringPressScaleState extends State<SpringPressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: widget.isPressed ? widget.pressed : 1);
  }

  @override
  void didUpdateWidget(SpringPressScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPressed != widget.isPressed || oldWidget.pressed != widget.pressed) {
      final target = widget.isPressed ? widget.pressed : 1.0;
      _controller.animateWith(
        SpringSimulation(AtelierSprings.snappy(), _controller.value, target, _controller.velocity),
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
    if (rememberReducedMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => Transform.scale(scale: _controller.value, child: child),
    );
  }
}
