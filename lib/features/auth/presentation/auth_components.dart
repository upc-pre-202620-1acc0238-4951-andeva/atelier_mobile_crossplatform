import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_logo.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Cabecera atmosférica común del flujo de acceso: [SurfaceTier.heroNavy] con el imagotipo en
/// contraste blanco sobre azul profundo, título y contexto breve.
class AuthHeroHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? badge;

  const AuthHeroHeader({super.key, required this.title, this.subtitle, this.badge});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final subtitle = this.subtitle;
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: AtelierSurface(
        tier: SurfaceTier.heroNavy,
        shape: heroShape,
        contentPadding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            // AtelierLogo usa onSurface; sobre HeroNavy se fuerza tinta clara para preservar el contraste AA.
            Theme(
              data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(onSurface: colors.onPanel)),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(height: 36, child: AtelierLogo()),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: context.text.headlineMedium!.copyWith(color: colors.onPanel)),
                ),
                if (subtitle != null && subtitle.trim().isNotEmpty)
                  Text(
                    subtitle,
                    style: context.text.bodyMedium!.copyWith(color: colors.onPanel.withValues(alpha: 0.84)),
                  ),
              ],
            ),
            if (badge != null) Align(alignment: Alignment.centerLeft, child: badge),
          ],
        ),
      ),
    );
  }
}
