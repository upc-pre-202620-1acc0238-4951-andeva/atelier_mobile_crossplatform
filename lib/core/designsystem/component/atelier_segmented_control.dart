import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

const _segmentCapsuleRadius = plateRadius;

/// Control segmentado sobre pista hundida ([SurfaceTier.recessed]) con cápsula activa elevada que se
/// desliza con resorte sin rebote ([AtelierSprings.dock]). Se adapta automáticamente a escala de fuente
/// grande (>= 1.15x) o más de 3 opciones pasando a un carril horizontal desplazable sin recortar texto.
class AtelierSegmentedControl<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelect;
  final String Function(T option) label;
  final int Function(T option)? badge;

  const AtelierSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.label,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final fontScale = MediaQuery.textScalerOf(context).scale(1);
    final selectedIndex = math.max(options.indexOf(selected), 0);
    final useScrollableLayout = options.length > 3 || fontScale >= 1.15;

    final items = [
      for (var index = 0; index < options.length; index++)
        _SegmentSpec(
          text: label(options[index]),
          badgeCount: badge?.call(options[index]) ?? 0,
          isSelected: index == selectedIndex,
          onClick: () => onSelect(options[index]),
        ),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: AtelierSurface(
        tier: SurfaceTier.recessed,
        shape: controlShape,
        contentPadding: const EdgeInsets.all(4),
        child: useScrollableLayout
            ? _ScrollableSegments(items: items, selectedIndex: selectedIndex)
            : _FixedSegments(items: items, selectedIndex: selectedIndex),
      ),
    );
  }
}

class _SegmentSpec {
  final String text;
  final int badgeCount;
  final bool isSelected;
  final VoidCallback onClick;

  const _SegmentSpec({
    required this.text,
    required this.badgeCount,
    required this.isSelected,
    required this.onClick,
  });
}

/// Pista de ancho fijo: las opciones se reparten el ancho y la cápsula se desliza con resorte.
class _FixedSegments extends StatefulWidget {
  final List<_SegmentSpec> items;
  final int selectedIndex;

  const _FixedSegments({required this.items, required this.selectedIndex});

  @override
  State<_FixedSegments> createState() => _FixedSegmentsState();
}

class _FixedSegmentsState extends State<_FixedSegments> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: widget.selectedIndex.toDouble());
  }

  @override
  void didUpdateWidget(_FixedSegments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final target = widget.selectedIndex.toDouble();
      if (rememberReducedMotion(context)) {
        _controller.value = target;
      } else {
        _controller.animateWith(SpringSimulation(AtelierSprings.dock(), _controller.value, target, _controller.velocity));
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
    final count = widget.items.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / count;
        return IntrinsicHeight(
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => Positioned(
                  left: segmentWidth * _controller.value,
                  width: segmentWidth,
                  top: 0,
                  bottom: 0,
                  child: const _SegmentCapsule(),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in widget.items)
                    Expanded(child: _SegmentOptionItem(spec: item, allowEllipsis: true)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Carril horizontal desplazable: la cápsula toma la posición y el ancho de la opción activa y la opción
/// activa se centra en el viewport.
class _ScrollableSegments extends StatefulWidget {
  final List<_SegmentSpec> items;
  final int selectedIndex;

  const _ScrollableSegments({required this.items, required this.selectedIndex});

  @override
  State<_ScrollableSegments> createState() => _ScrollableSegmentsState();
}

class _ScrollableSegmentsState extends State<_ScrollableSegments> with TickerProviderStateMixin {
  final _scroll = ScrollController();
  final _stackKey = GlobalKey();
  late List<GlobalKey> _itemKeys = _newKeys();
  late final AnimationController _x = AnimationController.unbounded(vsync: this);
  late final AnimationController _w = AnimationController.unbounded(vsync: this);
  bool _initialized = false;
  double? _targetX;
  double? _targetW;
  int? _syncedIndex;

  List<GlobalKey> _newKeys() => List.generate(widget.items.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(_ScrollableSegments oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys = _newKeys();
      _targetX = null;
      _targetW = null;
    }
  }

  @override
  void dispose() {
    _x.dispose();
    _w.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _syncIndicator() {
    if (!mounted) return;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final itemBox = _itemKeys[widget.selectedIndex].currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || itemBox == null || !stackBox.hasSize || !itemBox.hasSize) return;

    final x = itemBox.localToGlobal(Offset.zero, ancestor: stackBox).dx;
    final w = itemBox.size.width;
    final selectionChanged = _syncedIndex != widget.selectedIndex;
    final moved = _targetX == null || (x - _targetX!).abs() > 0.5 || (w - _targetW!).abs() > 0.5;
    if (!moved && !selectionChanged) return;
    _targetX = x;
    _targetW = w;
    _syncedIndex = widget.selectedIndex;

    final reduced = rememberReducedMotion(context);
    if (!_initialized || reduced) {
      _x.value = x;
      _w.value = w;
      _initialized = true;
    } else {
      _x.animateWith(SpringSimulation(AtelierSprings.dock(), _x.value, x, _x.velocity));
      _w.animateWith(SpringSimulation(AtelierSprings.dock(), _w.value, w, _w.velocity));
    }

    if (_scroll.hasClients) {
      final position = _scroll.position;
      final viewportCenter = position.viewportDimension / 2;
      if (viewportCenter > 0) {
        final scrollTarget = (x + w / 2 - viewportCenter).clamp(0.0, position.maxScrollExtent);
        if (reduced) {
          _scroll.jumpTo(scrollTarget);
        } else {
          _scroll.animateTo(scrollTarget, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncIndicator());
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      child: Stack(
        key: _stackKey,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_x, _w]),
            builder: (context, _) {
              if (_w.value <= 0) return const SizedBox.shrink();
              return Positioned(
                left: _x.value,
                width: _w.value,
                top: 0,
                bottom: 0,
                child: const _SegmentCapsule(),
              );
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              for (var index = 0; index < widget.items.length; index++)
                KeyedSubtree(
                  key: _itemKeys[index],
                  child: _SegmentOptionItem(spec: widget.items[index], allowEllipsis: false),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Cápsula activa: plano elevado con borde especular vertical de 1 dp.
class _SegmentCapsule extends StatelessWidget {
  const _SegmentCapsule();

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.surfaceElevated, borderRadius: _segmentCapsuleRadius),
      child: CustomPaint(
        painter: _SpecularBorderPainter(top: colors.specularTop, bottom: colors.specularBottom),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Borde de 1 dp dentro de la forma, en degradado vertical (como `Modifier.border(Brush)` de Compose).
class _SpecularBorderPainter extends CustomPainter {
  final Color top;
  final Color bottom;

  const _SpecularBorderPainter({required this.top, required this.bottom});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = _segmentCapsuleRadius.toRRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom])
          .createShader(rect);
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_SpecularBorderPainter old) => old.top != top || old.bottom != bottom;
}

class _SegmentOptionItem extends StatefulWidget {
  final _SegmentSpec spec;
  final bool allowEllipsis;

  const _SegmentOptionItem({required this.spec, required this.allowEllipsis});

  @override
  State<_SegmentOptionItem> createState() => _SegmentOptionItemState();
}

class _SegmentOptionItemState extends State<_SegmentOptionItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final text = context.text;
    final spec = widget.spec;
    final isSelected = spec.isSelected;

    Widget label(Color? color) => Text(
          spec.text,
          style: text.labelLarge?.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
          maxLines: 1,
          softWrap: false,
          overflow: widget.allowEllipsis ? TextOverflow.ellipsis : TextOverflow.visible,
        );

    return Semantics(
      button: true,
      selected: isSelected,
      onTap: spec.onClick,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: spec.onClick,
        child: SpringPressScale(
          isPressed: _pressed,
          pressed: 0.97,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: isSelected ? scheme.onSurface : colors.inkSecondary),
                duration: const Duration(milliseconds: 120),
                curve: easeOutQuint,
                builder: (context, color, _) => Row(
                  mainAxisSize: widget.allowEllipsis ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6,
                  children: [
                    if (widget.allowEllipsis) Flexible(child: label(color)) else label(color),
                    if (spec.badgeCount > 0)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: plateRadius,
                          color: isSelected
                              ? colors.infoContainer
                              : colors.outlineSoft.withValues(alpha: colors.isDark ? 0.75 : 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            spec.badgeCount.toString(),
                            style: text.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? colors.primaryText : colors.inkSecondary,
                            ),
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
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
