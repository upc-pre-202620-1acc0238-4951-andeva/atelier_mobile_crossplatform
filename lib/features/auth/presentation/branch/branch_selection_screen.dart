import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_components.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A5b Elegir sede. Solo la ven las cuentas que entraron sin perfil laboral (US03) o que cambian de sede (H33).
class BranchSelectionScreen extends StatefulWidget {
  final VoidCallback onDone;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final BranchSelectionViewModel? viewModel;

  const BranchSelectionScreen({super.key, required this.onDone, this.viewModel});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  late final BranchSelectionViewModel _viewModel = widget.viewModel ?? getIt<BranchSelectionViewModel>();
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (_handled || !_viewModel.state.done) return;
    _handled = true;
    widget.onDone();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => BranchSelectionContent(
        state: _viewModel.state,
        onSelect: _viewModel.onSelect,
        onContinue: _viewModel.onContinue,
        onSkip: _viewModel.onSkip,
        onRetry: _viewModel.load,
      ),
    );
  }
}

class BranchSelectionContent extends StatelessWidget {
  final BranchSelectionUiState state;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback onRetry;

  const BranchSelectionContent({
    super.key,
    required this.state,
    required this.onSelect,
    required this.onContinue,
    required this.onSkip,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final error = state.error;
    final selected = state.selected;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    Rise(
                      child: AuthHeroHeader(title: strings.branchTitle, subtitle: strings.branchSubtitle),
                    ),
                    Rise(
                      index: 1,
                      child: AtelierSurface(
                        tier: SurfaceTier.elevated,
                        shape: cardLargeShape,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        child: state.isLoading
                            ? Semantics(
                                label: strings.branchLoading,
                                container: true,
                                child: Column(
                                  children: [
                                    for (var i = 0; i < 3; i++)
                                      const AtelierListRow(
                                        title: 'Sede San Isidro',
                                        subtitle: 'Radio de 50 m',
                                        loading: true,
                                      ),
                                  ],
                                ),
                              )
                            : error != null
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: AtelierErrorState(message: error.asString(strings), onRetry: onRetry),
                              )
                            : state.branches.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: AtelierEmptyState(
                                  text: '${strings.branchEmptyTitle} ${strings.branchEmptyBody}',
                                ),
                              )
                            : Column(
                                children: [
                                  for (var index = 0; index < state.branches.length; index++)
                                    _BranchRow(
                                      branch: state.branches[index],
                                      selected: state.branches[index].id == state.selectedId,
                                      isAssigned: state.branches[index].id == state.assignedBranchId,
                                      enabled: !state.isSaving,
                                      showDivider: index < state.branches.length - 1,
                                      onClick: () => onSelect(state.branches[index].id),
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: colors.outlineSoft),
            Rise(
              index: 2,
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      AtelierButton(
                        text: selected != null ? strings.branchContinueIn(selected.name) : strings.branchContinue,
                        onClick: onContinue,
                        enabled: state.canContinue,
                        loading: state.isSaving,
                      ),
                      AtelierButton(
                        text: strings.branchLater,
                        onClick: onSkip,
                        style: AtelierButtonStyle.text,
                        enabled: !state.isSaving,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de sede: toda es el botón de radio; la elegida cambia de marca (círculo lleno) además de color.
class _BranchRow extends StatelessWidget {
  final BranchOption branch;
  final bool selected;
  final bool isAssigned;
  final bool enabled;
  final bool showDivider;
  final VoidCallback onClick;

  const _BranchRow({
    required this.branch,
    required this.selected,
    required this.isAssigned,
    required this.enabled,
    required this.showDivider,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final scheme = context.scheme;
    final radius = branch.geofenceRadiusMeters;
    final line = [
      if (isAssigned) strings.branchAssignedBadge,
      if (radius != null) strings.branchGeofence(radius),
    ].join(' · ');
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      child: AtelierListRow(
        title: branch.name,
        subtitle: line.isEmpty ? null : line,
        showDivider: showDivider,
        onClick: enabled ? onClick : null,
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked_outlined,
          color: selected ? scheme.primary : scheme.outline,
        ),
      ),
    );
  }
}
