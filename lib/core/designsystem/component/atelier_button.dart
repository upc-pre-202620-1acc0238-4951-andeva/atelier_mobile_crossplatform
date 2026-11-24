import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/icon/atelier_icons.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// [filled] es la acción principal: una por pantalla. [onPanel] va sobre el panel azul.
/// [destructive] es contorno y etiqueta en tinta de error; [destructiveFilled] solo en la confirmación final.
enum AtelierButtonStyle { filled, tonal, outlined, text, onPanel, destructive, destructiveFilled }

/// Botón dimensional esculpido de 12 dp de radio y altura táctil ambiental ([AtelierMinTouchTarget]:
/// 48 dp estándar, 56 dp en piso/fosa). Responde al tocar con resorte críticamente amortiguado ([SpringPressScale]).
///
/// Con [loading] conserva su ancho, muestra progreso junto a la etiqueta y no responde.
/// Deshabilitado baja a 38 % de opacidad: quien lo usa debe mostrar el motivo cerca.
class AtelierButton extends StatefulWidget {
  final String text;
  final VoidCallback onClick;
  final AtelierButtonStyle style;
  final bool enabled;
  final bool loading;
  final IconData? icon;

  /// Ícono vectorial propio (p. ej. `bluetooth_searching`); [icon] manda si ambos vienen.
  final AtelierVectorIcon? vectorIcon;

  /// Por defecto, la densidad táctil ambiental ([AtelierMinTouchTarget.of]).
  final double? minHeight;

  const AtelierButton({
    super.key,
    required this.text,
    required this.onClick,
    this.style = AtelierButtonStyle.filled,
    this.enabled = true,
    this.loading = false,
    this.icon,
    this.vectorIcon,
    this.minHeight,
  });

  @override
  State<AtelierButton> createState() => _AtelierButtonState();
}

class _AtelierButtonState extends State<AtelierButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final style = widget.style;
    final interactive = widget.enabled && !widget.loading;
    final minHeight = widget.minHeight ?? AtelierMinTouchTarget.of(context);

    final Color content = switch (style) {
      AtelierButtonStyle.filled => Colors.white,
      AtelierButtonStyle.tonal => scheme.onPrimaryContainer,
      AtelierButtonStyle.onPanel => atelierBlueDark,
      AtelierButtonStyle.destructiveFilled => Colors.white,
      AtelierButtonStyle.destructive => atelier.bad,
      AtelierButtonStyle.outlined => scheme.onSurface,
      AtelierButtonStyle.text => atelier.primaryText,
    };

    final Color? fillColor = switch (style) {
      AtelierButtonStyle.tonal => scheme.primaryContainer,
      AtelierButtonStyle.outlined => atelier.card,
      AtelierButtonStyle.onPanel => atelier.onPanel,
      _ => null,
    };
    final Gradient? fillGradient = switch (style) {
      AtelierButtonStyle.filled => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [atelier.buttonTop, atelier.buttonBottom],
        ),
      AtelierButtonStyle.destructiveFilled => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [atelier.destructiveTop, atelier.destructiveBottom],
        ),
      _ => null,
    };

    LinearGradient vertical(Color top, Color bottom) =>
        LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]);

    final AtelierBorderSpec? border = switch (style) {
      AtelierButtonStyle.filled => AtelierBorderSpec(
          gradient: vertical(atelierBlueSoft.withValues(alpha: 0.35), atelierBlueSoft.withValues(alpha: 0.08)),
        ),
      AtelierButtonStyle.tonal => AtelierBorderSpec(color: scheme.primary.withValues(alpha: 0.18)),
      AtelierButtonStyle.outlined => AtelierBorderSpec(
          gradient: atelier.isDark
              ? vertical(atelier.specularTop, atelier.specularBottom)
              : vertical(scheme.outline.withValues(alpha: 0.50), scheme.outline.withValues(alpha: 0.85)),
        ),
      AtelierButtonStyle.destructive => AtelierBorderSpec(color: atelier.bad),
      AtelierButtonStyle.destructiveFilled => AtelierBorderSpec(
          gradient: vertical(Colors.white.withValues(alpha: 0.28), Colors.transparent),
        ),
      AtelierButtonStyle.onPanel || AtelierButtonStyle.text => null,
    };

    final largeFont = MediaQuery.textScalerOf(context).scale(1) >= 1.2;
    final EdgeInsets padding = style == AtelierButtonStyle.text
        ? const EdgeInsets.symmetric(horizontal: 12)
        : largeFont
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
            : const EdgeInsets.symmetric(horizontal: 20);

    final splash = (style == AtelierButtonStyle.filled || style == AtelierButtonStyle.destructiveFilled)
        ? Colors.white.withValues(alpha: 0.24)
        : content.withValues(alpha: 0.14);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        if (widget.loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: content, strokeWidth: 2),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 20, color: content)
        else if (widget.vectorIcon != null)
          AtelierIcon(widget.vectorIcon!, size: 20, color: content),
        Flexible(
          child: Text(
            widget.text,
            style: context.text.labelLarge!.copyWith(color: content),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    Widget button = DecoratedBox(
      decoration: ShapeDecoration(shape: controlShape, color: fillColor, gradient: fillGradient),
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: controlShape),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: interactive ? widget.onClick : null,
                onHighlightChanged: interactive ? (v) => setState(() => _pressed = v) : null,
                customBorder: controlShape,
                splashColor: splash,
                highlightColor: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Padding(padding: padding, child: label),
                  ),
                ),
              ),
            ),
            if (border != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: AtelierBorderPainter(shape: controlShape, spec: border)),
                ),
              ),
          ],
        ),
      ),
    );

    if (interactive) {
      button = SpringPressScale(isPressed: _pressed, child: button);
    }
    return Semantics(
      button: true,
      enabled: interactive,
      container: true,
      child: Opacity(opacity: widget.enabled ? 1 : 0.38, child: button),
    );
  }
}
