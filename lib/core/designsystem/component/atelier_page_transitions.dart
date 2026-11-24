import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:flutter/material.dart';

/// Transición entre pantallas de `AppNavHost` (Android): eje compartido hacia un detalle. La pantalla
/// entra con un fundido de 200 ms y un desplazamiento de 1/12 del ancho en 240 ms ([easeOutQuint]); la
/// anterior se desvanece en 90 ms. Al volver, la que sale se desvanece (120 ms) y se desliza 1/12 hacia
/// el lado de entrada en 200 ms, y la de debajo reaparece desde el lado contrario.
///
/// Con "quitar animaciones" del sistema no anima. Solo Android: en iOS se conserva el gesto de Cupertino.
class AtelierPageTransitionsBuilder extends PageTransitionsBuilder {
  const AtelierPageTransitionsBuilder();

  static const _enterMs = 240;
  static const _fadeInMs = 200;
  static const _exitMs = 200;
  static const _fadeOutMs = 120;
  static const _underFadeOutMs = 90;
  static const _shift = 1 / 12;

  @override
  Duration get transitionDuration => const Duration(milliseconds: _enterMs);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: _exitMs);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (rememberReducedMotion(context)) return child;

    // La pantalla que entra (y sale al hacer Atrás): fundido y desplazamiento comparten un controlador.
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, _fadeInMs / _enterMs, curve: easeOutQuint),
      reverseCurve: const Interval(1 - _fadeOutMs / _exitMs, 1, curve: Curves.fastOutSlowIn),
    );
    final slide = CurvedAnimation(parent: animation, curve: easeOutQuint, reverseCurve: easeOutQuint);
    final entering = FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(_shift, 0), end: Offset.zero).animate(slide),
        child: child,
      ),
    );

    // La pantalla de debajo: se desvanece rápido al apilar otra y reaparece desde el otro lado al volver.
    return AnimatedBuilder(
      animation: secondaryAnimation,
      child: entering,
      builder: (context, child) {
        final value = secondaryAnimation.value;
        if (value == 0) return child!;
        final popping = secondaryAnimation.status == AnimationStatus.reverse;
        if (!popping) {
          final opacity = (1 - value / (_underFadeOutMs / _enterMs)).clamp(0.0, 1.0);
          return Opacity(opacity: opacity, child: child);
        }
        final eased = easeOutQuint.transform(value);
        return Opacity(
          opacity: 1 - eased,
          child: FractionalTranslation(translation: Offset(-_shift * eased, 0), child: child),
        );
      },
    );
  }
}
