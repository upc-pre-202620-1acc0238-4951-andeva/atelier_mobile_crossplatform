import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

enum BannerKind { bad, info, ok, wait }

/// Aviso en línea sobre `SurfaceTier.card` con borde semántico suave y medallón para el ícono.
/// Anuncia su aparición al lector de pantalla (Flutter no distingue asertivo de cortés).
class AtelierBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final BannerKind kind;
  final String? title;

  const AtelierBanner({
    super.key,
    required this.message,
    required this.icon,
    this.kind = BannerKind.bad,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final (container, accent) = switch (kind) {
      BannerKind.bad => (colors.badContainer, colors.bad),
      BannerKind.info => (colors.infoContainer, colors.info),
      BannerKind.ok => (colors.okContainer, colors.ok),
      BannerKind.wait => (colors.waitContainer, colors.wait),
    };
    final bodyMedium = context.text.bodyMedium!.copyWith(color: context.scheme.onSurface);

    return Semantics(
      liveRegion: true,
      container: true,
      child: ClipPath(
        clipper: const ShapeBorderClipper(shape: controlShape),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: cardRadius,
              side: BorderSide(color: accent.withValues(alpha: 0.28)),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(color: container.withValues(alpha: colors.isDark ? 0.55 : 0.75)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.14)),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (title != null)
                            TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: message),
                        ],
                      ),
                      style: bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
