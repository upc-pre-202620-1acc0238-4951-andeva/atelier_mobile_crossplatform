import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Hay caché en pantalla y la actualización corre detrás: barra fina bajo el panel. Reserva su alto siempre,
/// así no empuja el contenido al aparecer.
class AtelierRefreshBar extends StatelessWidget {
  final bool visible;

  const AtelierRefreshBar({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: visible
            ? LinearProgressIndicator(
                key: const ValueKey('refresh'),
                minHeight: 2,
                color: context.scheme.primary,
                backgroundColor: Colors.transparent,
              )
            : const SizedBox.shrink(key: ValueKey('idle')),
      ),
    );
  }
}

/// Vacío: una línea que dice qué habría aquí y, si aplica, la acción para crearlo. Sin ilustraciones.
class AtelierEmptyState extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AtelierEmptyState({super.key, required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(text, style: context.text.bodyLarge!.copyWith(color: context.atelier.inkSecondary)),
            if (actionLabel != null && onAction != null)
              AtelierButton(text: actionLabel!, onClick: onAction!, style: AtelierButtonStyle.outlined),
          ],
        ),
      ),
    );
  }
}

/// Error: el `message` del backend tal cual y "Reintentar". El lector de pantalla lo anuncia al aparecer.
class AtelierErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AtelierErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              _StateLine(icon: Icons.error_outline, text: message, tint: context.atelier.bad),
              if (onRetry != null)
                AtelierButton(
                  text: AppLocalizations.of(context).commonRetry,
                  onClick: onRetry!,
                  style: AtelierButtonStyle.outlined,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sin red y sin caché. Con caché no se usa: se pinta Drift y se avisa de cuándo es el dato.
class AtelierOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const AtelierOfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            _StateLine(icon: Icons.cloud_off_outlined, text: strings.stateOfflineNoCache, tint: context.atelier.idle),
            if (onRetry != null)
              AtelierButton(text: strings.commonRetry, onClick: onRetry!, style: AtelierButtonStyle.outlined),
          ],
        ),
      ),
    );
  }
}

/// Sin permiso: el destino no debería mostrarse; si se llega por un enlace, una línea que lo explica.
class AtelierNoPermissionState extends StatelessWidget {
  final String text;

  const AtelierNoPermissionState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _StateLine(icon: Icons.lock_outline, text: text, tint: context.atelier.idle),
    );
  }
}

/// Bloqueado por plan: se dice qué plan lo incluye, sin tono de venta.
class AtelierPlanLockedState extends StatelessWidget {
  final String text;

  const AtelierPlanLockedState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _StateLine(icon: Icons.workspace_premium_outlined, text: text, tint: context.atelier.idle),
    );
  }
}

/// Motivo visible junto a una acción deshabilitada por falta de red ("Requiere conexión").
class AtelierRequiresConnection extends StatelessWidget {
  const AtelierRequiresConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return _StateLine(
      icon: Icons.cloud_off_outlined,
      text: AppLocalizations.of(context).errorRequiresConnection,
      tint: context.atelier.idle,
    );
  }
}

class _StateLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color tint;

  const _StateLine({required this.icon, required this.text, required this.tint});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: tint),
          ),
          Expanded(child: Text(text, style: context.text.bodyLarge!.copyWith(color: context.scheme.onSurface))),
        ],
      ),
    );
  }
}
