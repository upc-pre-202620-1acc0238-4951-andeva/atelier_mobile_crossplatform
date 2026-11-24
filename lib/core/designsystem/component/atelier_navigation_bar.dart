import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Destino de [AtelierNavigationBar]. [badge] > 0 dibuja un contador sobre el ícono.
/// El ícono es un [IconData] de Material o, para los cuatro propios de Android, un [AtelierVectorIcon].
class AtelierNavItem {
  final String label;
  final IconData? icon;
  final AtelierVectorIcon? vectorIcon;
  final int badge;

  const AtelierNavItem({required this.label, this.icon, this.vectorIcon, this.badge = 0})
    : assert((icon == null) != (vectorIcon == null), 'Indica icon o vectorIcon, no ambos');
}

/// Botón circular separado de la píldora: la acción más importante de la pantalla (p. ej. "Recibir vehículo").
class AtelierBarAction {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onClick;

  const AtelierBarAction({
    required this.label,
    required this.description,
    required this.icon,
    required this.onClick,
  });
}

/// Alto que la barra flotante tapa del contenido (píldora, márgenes e inset del sistema). Lo publica
/// `AppNavHost`; vale 0 cuando la barra no está a la vista. Las raíces de pestaña lo suman al final de su
/// contenido con [FloatingBarPadding] para que la última fila pueda subir por encima de la píldora.
///
/// Equivalente a `LocalFloatingBarInset`: `FloatingBarInset.of(context)`.
class FloatingBarInset extends InheritedWidget {
  final double value;

  const FloatingBarInset({super.key, this.value = 0, required super.child});

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FloatingBarInset>()?.value ?? 0;

  @override
  bool updateShouldNotify(FloatingBarInset oldWidget) => value != oldWidget.value;
}

/// Equivalente a `Modifier.floatingBarPadding()`: deja libre al final el alto de la barra flotante.
class FloatingBarPadding extends StatelessWidget {
  final Widget child;

  const FloatingBarPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.only(bottom: FloatingBarInset.of(context)), child: child);
}

extension FloatingBarPaddingWidget on Widget {
  Widget floatingBarPadding() => FloatingBarPadding(child: this);
}

const double _barHeight = 64;
const double _barMargin = 12;
const double _barPadding = 6;

/// La escala de fuente del sistema se detiene aquí dentro: a 1,3 cuatro etiquetas no caben en 360 dp.
const double _barMaxFontScale = 1.15;

/// Dock flotante de precisión (DESIGN.md → Navigation): cápsula [SurfaceTier.floating] de 64 dp con 3 a 5
/// destinos, indicador animado con [AtelierSprings.dock] y orbe de acción esculpido separado a la derecha.
/// [selectedIndex] < 0 apaga el indicador.
class AtelierNavigationBar extends StatelessWidget {
  final List<AtelierNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final AtelierBarAction? action;

  const AtelierNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final media = MediaQuery.of(context);
    final action = this.action;
    return MediaQuery(
      data: media.copyWith(textScaler: media.textScaler.clamp(maxScaleFactor: _barMaxFontScale)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: _barMargin, right: _barMargin, bottom: _barMargin),
          child: Row(
            spacing: _barMargin,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _Pill(items: items, selectedIndex: selectedIndex, onSelect: onSelect),
              ),
              if (action != null) _ActionButton(action: action),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final List<AtelierNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _Pill({required this.items, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _barHeight,
      child: AtelierSurface(
        tier: SurfaceTier.floating,
        shape: floatingBarShape,
        contentPadding: const EdgeInsets.all(_barPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / math.max(items.length, 1);
            return SizedBox.expand(
              child: Stack(
                children: [
                  _DockIndicator(slot: slot, selectedIndex: selectedIndex),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var index = 0; index < items.length; index++)
                        Expanded(
                          child: _Slot(
                            item: items[index],
                            selected: index == selectedIndex,
                            onClick: () => onSelect(index),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Cápsula activa que se desliza entre destinos con [AtelierSprings.dock] (sin rebote).
class _DockIndicator extends StatefulWidget {
  final double slot;
  final int selectedIndex;

  const _DockIndicator({required this.slot, required this.selectedIndex});

  @override
  State<_DockIndicator> createState() => _DockIndicatorState();
}

class _DockIndicatorState extends State<_DockIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double get _target => math.max(widget.selectedIndex, 0).toDouble();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: _target);
  }

  @override
  void didUpdateWidget(_DockIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      if (rememberReducedMotion(context)) {
        _controller.value = _target;
      } else {
        _controller.animateWith(SpringSimulation(AtelierSprings.dock(), _controller.value, _target, _controller.velocity));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Positioned(
        left: widget.slot * _controller.value,
        width: widget.slot,
        top: 0,
        bottom: 0,
        child: Opacity(
          opacity: widget.selectedIndex < 0 ? 0 : 1,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: scheme.primaryContainer,
              shape: StadiumBorder(side: BorderSide(color: scheme.primary.withValues(alpha: 0.22))),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slot extends StatefulWidget {
  final AtelierNavItem item;
  final bool selected;
  final VoidCallback onClick;

  const _Slot({required this.item, required this.selected, required this.onClick});

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final item = widget.item;
    final selected = widget.selected;
    final tint = selected ? scheme.onPrimaryContainer : context.atelier.inkSecondary;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: widget.onClick,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onClick,
        child: SpringPressScale(
          isPressed: _pressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: item.badge > 0,
                backgroundColor: scheme.error,
                textColor: scheme.onError,
                label: Text((item.badge > 99 ? 99 : item.badge).toString()),
                child: SpringPressScale(
                  isPressed: selected,
                  pressed: 1.08,
                  child: item.icon != null
                      ? Icon(item.icon, size: 22, color: tint)
                      : AtelierIcon(item.vectorIcon!, size: 22, color: tint),
                ),
              ),
              Text(
                item.label,
                style: context.text.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: tint,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final AtelierBarAction action;

  const _ActionButton({required this.action});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final action = widget.action;
    return Semantics(
      button: true,
      label: action.description,
      excludeSemantics: true,
      onTap: action.onClick,
      child: SpringPressScale(
        isPressed: _pressed,
        child: SizedBox(
          width: _barHeight,
          height: _barHeight,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.heroStart, colors.heroEnd],
              ),
              shape: StadiumBorder(side: BorderSide(color: atelierBlueSoft.withValues(alpha: 0.45))),
            ),
            child: Material(
              type: MaterialType.transparency,
              shape: const StadiumBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                customBorder: const StadiumBorder(),
                splashColor: Colors.white.withValues(alpha: 0.24),
                highlightColor: Colors.white.withValues(alpha: 0.12),
                onTap: action.onClick,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(action.icon, size: 24, color: Colors.white),
                    Text(
                      action.label,
                      style: context.text.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
