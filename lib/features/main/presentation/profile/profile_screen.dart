import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Perfil de la cuenta: quién es, su taller y sede, el plan y la sincronización. Se abre desde "Más" con Atrás.
/// La app no conoce el nombre del rol, así que no muestra ninguno. No incluye "Cerrar sesión" (US04).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileViewModel viewModel = getIt<ProfileViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route) => AppNavigator.push(context, route);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => ProfileContent(
        state: viewModel.state,
        onBack: canPop ? () => Navigator.of(context).maybePop() : null,
        onSelectBranch: () => _open(AppRoute.branchSelection),
        onOpenSyncQueue: () => _open(AppRoute.pendingOperations),
        onOpenNotifications: () => _open(AppRoute.notifications),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final ProfileUiState state;
  final VoidCallback? onBack;
  final VoidCallback onSelectBranch;
  final VoidCallback onOpenSyncQueue;
  final VoidCallback onOpenNotifications;

  const ProfileContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSelectBranch,
    required this.onOpenSyncQueue,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final back = onBack;
    final title = state.fullName.trim().isEmpty ? strings.mainTabProfile : state.fullName;
    final email = state.email.trim().isEmpty ? null : state.email;
    return Scaffold(
      body: Column(
        children: [
          if (back != null)
            AtelierFichaPanel(onBack: back, title: title, subtitle: email)
          else
            AtelierMainTopBar(title: strings.mainTabProfile),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: FloatingBarPadding(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    if (back == null)
                      _HeroIdentity(title: title, email: email)
                    else
                      _AccountSummary(state: state),
                    _WorkshopCard(
                      state: state,
                      onSelectBranch: onSelectBranch,
                    ),
                    AtelierGroupedCard(
                      title: strings.profileSectionOps,
                      children: [
                        AtelierGroupedRow(
                          title: strings.profileItemSync,
                          subtitle: state.pendingCount > 0
                              ? strings.profilePendingCount(state.pendingCount)
                              : strings.profileSyncUpToDate,
                          icon: Icons.sync_outlined,
                          trailingBadgeText: state.pendingCount > 0
                              ? state.pendingCount.toString()
                              : null,
                          trailingBadgeColor: colors.waitContainer,
                          onClick: onOpenSyncQueue,
                          showDivider: true,
                        ),
                        AtelierGroupedRow(
                          title: strings.profileItemNotifications,
                          subtitle: state.unreadNotificationsCount > 0
                              ? strings.profileUnreadCount(state.unreadNotificationsCount)
                              : strings.profileNoUnread,
                          icon: Icons.notifications_outlined,
                          trailingBadgeText: state.unreadNotificationsCount > 0
                              ? state.unreadNotificationsCount.toString()
                              : null,
                          trailingBadgeColor: colors.infoContainer,
                          onClick: onOpenNotifications,
                        ),
                      ],
                    ),
                    if (state.version.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          strings.profileVersion(state.version),
                          style: context.text.bodySmall?.copyWith(color: colors.muted),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIdentity extends StatelessWidget {
  final String title;
  final String? email;

  const _HeroIdentity({required this.title, required this.email});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final email = this.email;
    return AtelierSurface(
      tier: SurfaceTier.heroNavy,
      shape: heroShape,
      contentPadding: const EdgeInsets.all(20),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.onPanel.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline, size: 24, color: colors.onPanel),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: context.text.titleLarge?.copyWith(color: colors.onPanel),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email != null)
                  Text(
                    email,
                    style: context.text.bodyMedium?.copyWith(
                      color: colors.onPanel.withValues(alpha: 0.82),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  final ProfileUiState state;

  const _AccountSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final workshop = [
      if (state.tenantName.trim().isNotEmpty) state.tenantName,
      ?state.branchName,
    ].join(' · ');
    return AtelierSurface(
      tier: SurfaceTier.elevated,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            strings.profileAccountSummary,
            style: context.text.labelLarge?.copyWith(color: colors.primaryText),
          ),
          Text(
            workshop.isEmpty ? strings.profileBranchUnknown : workshop,
            style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
          ),
        ],
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final ProfileUiState state;
  final VoidCallback onSelectBranch;

  const _WorkshopCard({required this.state, required this.onSelectBranch});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierGroupedCard(
      title: strings.profileSectionWorkshop,
      children: [
        if (state.tenantName.trim().isNotEmpty)
          AtelierGroupedRow(
            title: state.tenantName,
            subtitle: strings.profileLabelWorkshop,
            icon: Icons.business_outlined,
            showChevron: false,
            showDivider: true,
          ),
        AtelierGroupedRow(
          title: state.branchName ?? strings.profileBranchUnknown,
          subtitle: state.canChangeBranch ? strings.profileBranchChange : strings.profileLabelBranch,
          icon: Icons.storefront_outlined,
          showChevron: state.canChangeBranch,
          onClick: state.canChangeBranch ? onSelectBranch : null,
          showDivider: state.hasPlan,
        ),
        if (state.hasPlan)
          AtelierGroupedRow(
            title: strings.profilePlanFormat(state.planTier),
            subtitle: _planModules(strings),
            icon: Icons.star_outline,
            showChevron: false,
          ),
      ],
    );
  }

  /// Módulos del plan en palabras: lo que incluye, o que es el plan base.
  String _planModules(AppLocalizations strings) {
    final modules = [
      if (state.iotTelemetryEnabled) strings.profileModuleObd,
      if (state.aiDiagnosticsEnabled) strings.profileModuleAi,
    ];
    return modules.isEmpty ? strings.profileModuleNone : modules.join(' · ');
  }
}
