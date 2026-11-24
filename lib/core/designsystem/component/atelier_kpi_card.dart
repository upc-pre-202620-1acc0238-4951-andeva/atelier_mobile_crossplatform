import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Indicador del panel de la sede: envuelto en [SurfaceTier.card] con punto acento sutil, título,
/// una cifra tabular, una línea de contexto y, si hace falta, una marca de estado. Sin icono en cajita:
/// la cifra es lo que se lee (DESIGN.md → Don't). Toda la tarjeta es un solo objetivo táctil que lleva
/// al módulo; con [loading] la cifra y el contexto son huesos.
class AtelierKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Widget? chip;
  final bool loading;
  final VoidCallback? onClick;

  const AtelierKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.chip,
    this.loading = false,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final text = context.text;
    final chip = this.chip;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 120),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        onClick: onClick != null && !loading ? onClick : null,
        contentPadding: const EdgeInsets.all(16),
        child: MergeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Row(
                spacing: 6,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primaryText.withValues(alpha: 0.72),
                    ),
                    child: const SizedBox(width: 6, height: 6),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: text.titleSmall?.copyWith(color: colors.inkSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Bone(
                    loading: loading,
                    widthFraction: 0.4,
                    child: Text(value, style: text.headlineMedium?.copyWith(color: scheme.onSurface)),
                  ),
                  if (chip != null && !loading) chip,
                ],
              ),
              Bone(
                loading: loading,
                widthFraction: 0.8,
                child: Text(
                  subtitle,
                  style: text.bodySmall?.copyWith(color: colors.inkSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
