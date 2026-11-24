import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Contenedor de tarjeta agrupada («Precisión Automotriz»): encapsula opciones relacionadas en
/// [SurfaceTier.card] con esquinas de 18 dp, sombra ambiental y bisel especular vertical.
class AtelierGroupedCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const AtelierGroupedCard({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (title != null && title.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              style: context.text.titleSmall?.copyWith(
                color: context.atelier.inkSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        AtelierSurface(
          tier: SurfaceTier.card,
          shape: cardLargeShape,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// Elemento de fila individual dentro de un [AtelierGroupedCard] con medallón de ícono en plano
/// hundido (`surfaceRecessed`) y respuesta táctil con resorte ([SpringPressScale]).
class AtelierGroupedRow extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconContainerColor;
  final Color? iconTint;
  final String? trailingBadgeText;
  final Color? trailingBadgeColor;
  final bool showChevron;
  final bool showDivider;
  final VoidCallback? onClick;

  const AtelierGroupedRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconContainerColor,
    this.iconTint,
    this.trailingBadgeText,
    this.trailingBadgeColor,
    this.showChevron = true,
    this.showDivider = false,
    this.onClick,
  });

  @override
  State<AtelierGroupedRow> createState() => _AtelierGroupedRowState();
}

class _AtelierGroupedRowState extends State<AtelierGroupedRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final text = context.text;
    final icon = widget.icon;
    final subtitle = widget.subtitle;
    final badgeText = widget.trailingBadgeText;
    final onClick = widget.onClick;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        spacing: 14,
        children: [
          if (icon != null)
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: widget.iconContainerColor ?? atelier.surfaceRecessed,
                shape: RoundedRectangleBorder(
                  borderRadius: controlRadius,
                  side: BorderSide(color: atelier.outlineSoft.withValues(alpha: 0.65)),
                ),
              ),
              child: Icon(icon, size: 20, color: widget.iconTint ?? scheme.onSurfaceVariant),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  widget.title,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, color: scheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty)
                  Text(
                    subtitle,
                    style: text.bodySmall?.copyWith(color: atelier.inkSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (badgeText != null && badgeText.trim().isNotEmpty)
            DecoratedBox(
              decoration: ShapeDecoration(
                color: widget.trailingBadgeColor ?? scheme.primaryContainer,
                shape: plateShape,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  badgeText,
                  style: text.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (widget.showChevron && onClick != null)
            Icon(Icons.keyboard_arrow_right_outlined, size: 20, color: atelier.muted),
        ],
      ),
    );

    final Widget content = onClick == null
        ? row
        : SpringPressScale(
            isPressed: _pressed,
            pressed: 0.985,
            child: Semantics(
              button: true,
              child: InkWell(
                onTap: onClick,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: row,
              ),
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        content,
        if (widget.showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: icon != null ? 68 : 16,
            endIndent: 16,
            color: atelier.outlineSoft.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}
