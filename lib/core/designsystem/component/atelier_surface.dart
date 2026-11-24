import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Planos de profundidad del sistema visual «Precisión Automotriz».
///
/// - [recessed]: pozo hundido para pistas, contenedores de métricas y barras de progreso.
/// - [card]: plano base de lectura sobre el lienzo, con borde especular vertical y sombra ambiental sutil.
/// - [elevated]: plano elevado para cápsulas activas y tarjetas destacadas.
/// - [floating]: plano superior para barras flotantes y menús despegados del contenido.
/// - [heroNavy]: cabecera o tarjeta protagonista con degradado direccional `#031A6B → #08349C → #0071EB` y arco de luz.
/// - [decisionAmber]: superficie ámbar refinada reservada exclusivamente para decisiones humanas pendientes.
enum SurfaceTier { recessed, card, elevated, floating, heroNavy, decisionAmber }

/// Contenedor físico multi-plano de Atelier con iluminación especular, sombra ambiental teñida
/// y respuesta táctil con resorte críticamente amortiguado cuando [onClick] no es nulo.
class AtelierSurface extends StatefulWidget {
  final SurfaceTier tier;
  final ShapeBorder shape;
  final VoidCallback? onClick;
  final bool enabled;
  final EdgeInsetsGeometry contentPadding;
  final Widget child;

  const AtelierSurface({
    super.key,
    this.tier = SurfaceTier.card,
    this.shape = cardLargeShape,
    this.onClick,
    this.enabled = true,
    this.contentPadding = EdgeInsets.zero,
    required this.child,
  });

  @override
  State<AtelierSurface> createState() => _AtelierSurfaceState();
}

class _AtelierSurfaceState extends State<AtelierSurface> {
  bool _pressed = false;

  double get _elevation => switch (widget.tier) {
        SurfaceTier.recessed => 0,
        SurfaceTier.card => 3,
        SurfaceTier.elevated => 8,
        SurfaceTier.floating => 14,
        SurfaceTier.heroNavy => 12,
        SurfaceTier.decisionAmber => 4,
      };

  /// Aproximación de `Modifier.shadow(ambientColor, spotColor)` de Compose con dos sombras teñidas.
  List<BoxShadow> _shadows(AtelierColors colors) {
    final e = _elevation;
    if (e <= 0) return const [];
    return [
      BoxShadow(color: colors.shadowAmbient, blurRadius: e * 1.4, offset: Offset(0, e * 0.25)),
      BoxShadow(color: colors.shadowSpot, blurRadius: e * 1.1, offset: Offset(0, e * 0.55), spreadRadius: -e * 0.15),
    ];
  }

  AtelierBorderSpec _border(AtelierColors colors) {
    return switch (widget.tier) {
      SurfaceTier.recessed => AtelierBorderSpec(color: colors.outlineSoft.withValues(alpha: colors.isDark ? 0.55 : 0.70)),
      SurfaceTier.card || SurfaceTier.elevated || SurfaceTier.floating => AtelierBorderSpec(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.specularTop, colors.specularBottom],
          ),
        ),
      SurfaceTier.heroNavy => AtelierBorderSpec(color: atelierBlueSoft.withValues(alpha: 0.28)),
      SurfaceTier.decisionAmber => AtelierBorderSpec(color: colors.decisionBorder),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final tier = widget.tier;
    final clickable = widget.onClick != null;
    final shape = widget.shape;

    final Color? baseColor = switch (tier) {
      SurfaceTier.recessed => colors.surfaceRecessed,
      SurfaceTier.card => colors.card,
      SurfaceTier.elevated => colors.surfaceElevated,
      SurfaceTier.floating => colors.surfaceFloating,
      SurfaceTier.heroNavy => null,
      SurfaceTier.decisionAmber => colors.decisionSurface,
    };
    final Gradient? baseGradient = tier == SurfaceTier.heroNavy
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.heroStart, colors.heroMid, colors.heroEnd],
          )
        : null;

    final contentColor = tier == SurfaceTier.heroNavy ? colors.onPanel : scheme.onSurface;

    Widget inner = Stack(
      fit: StackFit.passthrough,
      children: [
        if (tier == SurfaceTier.decisionAmber)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.decisionWash, Colors.transparent],
                ),
              ),
            ),
          ),
        if (tier == SurfaceTier.heroNavy)
          const Positioned.fill(child: CustomPaint(painter: _HeroArcPainter())),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: clickable && widget.enabled ? widget.onClick : null,
            onHighlightChanged: clickable && widget.enabled ? (v) => setState(() => _pressed = v) : null,
            customBorder: shape,
            child: Padding(padding: widget.contentPadding, child: widget.child),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: AtelierBorderPainter(shape: shape, spec: _border(colors))),
          ),
        ),
      ],
    );

    inner = DefaultTextStyle.merge(
      style: TextStyle(color: contentColor),
      child: IconTheme.merge(data: IconThemeData(color: contentColor), child: inner),
    );

    Widget surface = DecoratedBox(
      decoration: ShapeDecoration(
        shape: shape,
        color: baseColor,
        gradient: baseGradient,
        shadows: _shadows(colors),
      ),
      child: ClipPath(clipper: ShapeBorderClipper(shape: shape), child: inner),
    );

    if (clickable && widget.enabled) {
      surface = SpringPressScale(isPressed: _pressed, child: surface);
    }
    if (!widget.enabled) {
      surface = Opacity(opacity: 0.38, child: surface);
    }
    if (clickable) {
      surface = Semantics(button: true, enabled: widget.enabled, container: true, child: surface);
    }
    return surface;
  }
}

class AtelierBorderSpec {
  final Color? color;
  final Gradient? gradient;

  const AtelierBorderSpec({this.color, this.gradient});
}

/// Borde de 1 dp dentro de la forma (como `Modifier.border` de Compose): se traza el contorno con 2 dp
/// y se recorta a la forma, de modo que solo se ve la mitad interior.
class AtelierBorderPainter extends CustomPainter {
  final ShapeBorder shape;
  final AtelierBorderSpec spec;

  const AtelierBorderPainter({required this.shape, required this.spec});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = shape.getOuterPath(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    if (spec.gradient != null) {
      paint.shader = spec.gradient!.createShader(rect);
    } else {
      paint.color = spec.color!;
    }
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(AtelierBorderPainter old) => old.shape != shape || old.spec.color != spec.color || old.spec.gradient != spec.gradient;
}

/// Arco de luz del héroe: disco tenue y aro concéntrico, anclados arriba a la derecha.
class _HeroArcPainter extends CustomPainter {
  const _HeroArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final tint = atelierBlueSoft.withValues(alpha: 0.08);
    final radius = (size.width > size.height ? size.width : size.height) * 0.62;
    final center = Offset(size.width * 0.92, size.height * 0.12);
    canvas.drawCircle(center, radius, Paint()..color = tint);
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()
        ..color = tint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_HeroArcPainter old) => false;
}
