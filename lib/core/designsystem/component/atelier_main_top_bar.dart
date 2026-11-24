import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cabecera limpia de un destino de la barra inferior: título en Satoshi Black sobre el lienzo, subtítulo
/// opcional y acciones en medallones circulares elevados (sincronización pendiente, notificaciones y cuenta).
class AtelierMainTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onOpenNotifications;
  final int unreadNotificationsCount;
  final VoidCallback? onOpenSync;
  final int pendingSyncCount;
  final VoidCallback? onOpenProfile;

  const AtelierMainTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onOpenNotifications,
    this.unreadNotificationsCount = 0,
    this.onOpenSync,
    this.pendingSyncCount = 0,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final subtitle = this.subtitle;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                child: Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: context.text.titleLarge?.copyWith(color: scheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (subtitle != null && subtitle.trim().isNotEmpty)
                            Text(
                              subtitle,
                              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    PanelActions(
                      onOpenNotifications: onOpenNotifications,
                      unreadNotificationsCount: unreadNotificationsCount,
                      onOpenSync: onOpenSync,
                      pendingSyncCount: pendingSyncCount,
                      onOpenProfile: onOpenProfile,
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.outlineSoft.withValues(alpha: 0.50)),
          ],
        ),
      ),
    );
  }
}

/// Acciones globales de cabecera: sincronización pendiente, notificaciones y acceso a cuenta.
class PanelActions extends StatelessWidget {
  final VoidCallback? onOpenNotifications;
  final int unreadNotificationsCount;
  final VoidCallback? onOpenSync;
  final int pendingSyncCount;
  final VoidCallback? onOpenProfile;

  const PanelActions({
    super.key,
    required this.onOpenNotifications,
    required this.unreadNotificationsCount,
    required this.onOpenSync,
    required this.pendingSyncCount,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (pendingSyncCount > 0 && onOpenSync != null)
          _PanelIconButton(
            icon: Icons.cloud_off_outlined,
            contentDescription: strings.profilePendingCount(pendingSyncCount),
            badgeCount: pendingSyncCount,
            badgeColor: atelierBlue,
            onClick: onOpenSync!,
          ),
        if (onOpenNotifications != null)
          _PanelIconButton(
            icon: Icons.notifications_outlined,
            contentDescription: strings.notificationsTitle,
            badgeCount: unreadNotificationsCount,
            badgeColor: atelierError,
            onClick: onOpenNotifications!,
          ),
        // Acceso rápido a la cuenta, junto a las notificaciones.
        if (onOpenProfile != null)
          _PanelIconButton(
            icon: Icons.account_circle_outlined,
            contentDescription: strings.moreHProfile,
            badgeCount: 0,
            badgeColor: atelierBlue,
            onClick: onOpenProfile!,
          ),
      ],
    );
  }
}

class _PanelIconButton extends StatelessWidget {
  final IconData icon;
  final String contentDescription;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback onClick;

  const _PanelIconButton({
    required this.icon,
    required this.contentDescription,
    required this.badgeCount,
    required this.badgeColor,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return AtelierCircularIconButton(
      icon: icon,
      contentDescription: contentDescription,
      onClick: onClick,
      badgeCount: badgeCount,
      badgeColor: badgeColor,
    );
  }
}
