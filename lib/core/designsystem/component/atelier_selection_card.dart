import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Tarjeta de selección compacta para diálogos y hojas: usa [SurfaceTier.card] cuando está sin
/// seleccionar y eleva con borde azul luminoso y sombra suave al seleccionarse.
class AtelierSelectionCard extends StatefulWidget {
  final String title;
  final VoidCallback onClick;
  final String? subtitle;
  final String? price;
  final String? badgeText;
  final Color? badgeColor;
  final IconData? leadingIcon;
  final bool selected;
  final bool enabled;

  const AtelierSelectionCard({
    super.key,
    required this.title,
    required this.onClick,
    this.subtitle,
    this.price,
    this.badgeText,
    this.badgeColor,
    this.leadingIcon,
    this.selected = false,
    this.enabled = true,
  });

  @override
  State<AtelierSelectionCard> createState() => _AtelierSelectionCardState();
}

class _AtelierSelectionCardState extends State<AtelierSelectionCard> {
  static const _contentPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);
  static const _borderWidth = 1.5;

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final minTouch = AtelierMinTouchTarget.of(context);
    final content = _SelectionCardContent(
      title: widget.title,
      subtitle: widget.subtitle,
      price: widget.price,
      badgeText: widget.badgeText,
      badgeColor: widget.badgeColor,
      leadingIcon: widget.leadingIcon,
      selected: widget.selected,
    );

    if (!widget.selected) {
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: minTouch),
        child: AtelierSurface(
          tier: SurfaceTier.card,
          shape: controlShape,
          onClick: widget.onClick,
          enabled: widget.enabled,
          contentPadding: _contentPadding,
          child: content,
        ),
      );
    }

    // Borde de 1,5 dp en degradado vertical: anillo exterior en degradado y relleno opaco dentro.
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: controlRadius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [atelierBlueSoft, scheme.primary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_borderWidth),
        child: Material(
          color: Color.alphaBlend(scheme.primaryContainer.withValues(alpha: 0.42), atelier.card),
          borderRadius: const BorderRadius.all(Radius.circular(12 - _borderWidth)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.enabled ? widget.onClick : null,
            onHighlightChanged: widget.enabled ? (value) => setState(() => _pressed = value) : null,
            child: Padding(padding: _contentPadding, child: content),
          ),
        ),
      ),
    );
    card = widget.enabled
        ? SpringPressScale(isPressed: _pressed, child: card)
        : Opacity(opacity: 0.38, child: card);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minTouch),
      child: Semantics(button: true, selected: true, enabled: widget.enabled, container: true, child: card),
    );
  }
}

class _SelectionCardContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? price;
  final String? badgeText;
  final Color? badgeColor;
  final IconData? leadingIcon;
  final bool selected;

  const _SelectionCardContent({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.badgeText,
    required this.badgeColor,
    required this.leadingIcon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final atelier = context.atelier;
    final text = context.text;
    final leadingIcon = this.leadingIcon;
    final subtitle = this.subtitle;
    final badgeText = this.badgeText;
    final price = this.price;
    return Row(
      spacing: 10,
      children: [
        if (leadingIcon != null)
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? scheme.primary : atelier.surfaceRecessed,
            ),
            child: Icon(leadingIcon, size: 16, color: selected ? scheme.onPrimary : scheme.onSurfaceVariant),
          ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badgeText != null && badgeText.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: badgeColor ?? scheme.secondaryContainer,
                          shape: plateShape,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            badgeText,
                            style: text.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
        if (price != null && price.trim().isNotEmpty)
          Text(
            price,
            style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: atelier.primaryText),
          ),
        if (selected) Icon(Icons.check, size: 18, color: atelier.primaryText),
      ],
    );
  }
}
