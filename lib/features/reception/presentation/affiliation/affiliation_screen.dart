import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/affiliation/affiliation_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// US44: buscar por correo si el conductor ya está en Atelier, afiliarlo con sus autos o registrarlo en el counter.
class AffiliationScreen extends StatefulWidget {
  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final AffiliationViewModel? viewModel;

  const AffiliationScreen({super.key, this.viewModel});

  @override
  State<AffiliationScreen> createState() => _AffiliationScreenState();
}

class _AffiliationScreenState extends State<AffiliationScreen> {
  late final AffiliationViewModel _viewModel = widget.viewModel ?? getIt<AffiliationViewModel>();
  Object? _lastAffiliated;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_haptics);
  }

  void _haptics() {
    final state = _viewModel.state;
    final haptics = rememberAtelierHaptics();
    if (state.affiliated != null && !identical(state.affiliated, _lastAffiliated)) haptics.confirm();
    if (state.error != null && !identical(state.error, _lastError)) haptics.reject();
    _lastAffiliated = state.affiliated;
    _lastError = state.error;
  }

  @override
  void dispose() {
    _viewModel.removeListener(_haptics);
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => AffiliationContent(
        state: _viewModel.state,
        onBack: () => Navigator.of(context).maybePop(),
        onEmailChange: _viewModel.onEmailChange,
        onTaxIdChange: _viewModel.onTaxIdChange,
        onPhoneChange: _viewModel.onPhoneChange,
        onSearch: _viewModel.onSearch,
        onAffiliate: _viewModel.onAffiliate,
        onRegisterWalkIn: () => AppNavigator.push(
          context,
          AppRoute.registerCustomer,
          RegisterCustomerArgs(email: _viewModel.state.email.trim()),
        ),
      ),
    );
  }
}

class AffiliationContent extends StatelessWidget {
  final AffiliationUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onTaxIdChange;
  final ValueChanged<String> onPhoneChange;
  final VoidCallback onSearch;
  final VoidCallback onAffiliate;
  final VoidCallback onRegisterWalkIn;

  const AffiliationContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onEmailChange,
    required this.onTaxIdChange,
    required this.onPhoneChange,
    required this.onSearch,
    required this.onAffiliate,
    required this.onRegisterWalkIn,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = state.error;
    final Widget? action = state.affiliated != null || state.step == AffiliationStep.alreadyCustomer
        ? null
        : state.lookup == null
        ? AtelierButton(
            text: strings.affiliationSearch,
            onClick: onSearch,
            enabled: state.canSearch,
            loading: state.isSearching,
          )
        : state.step == AffiliationStep.affiliate
        ? AtelierButton(
            text: strings.affiliationSubmit,
            onClick: onAffiliate,
            enabled: state.canSubmitAffiliation,
            loading: state.isAffiliating,
          )
        : AtelierButton(
            text: strings.affiliationRegisterWalkIn,
            onClick: onRegisterWalkIn,
            enabled: state.canAffiliate && state.isOnline,
          );
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.affiliationTitle, onBack: onBack),
          Expanded(
            child: DelayedLoading(
              loading: state.isSearching && state.lookup == null,
              builder: (context, showSkeleton) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Spacing.md,
                  Spacing.md,
                  Spacing.md,
                  Spacing.md + FloatingBarInset.of(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.md,
                  children: [
                    Text(
                      strings.affiliationSubtitle,
                      style: context.text.bodyLarge!.copyWith(color: context.atelier.inkSecondary),
                    ),
                    if (!state.canLookup)
                      AtelierNoPermissionState(text: strings.receptionNoPermission)
                    else ...[
                      AtelierSurface(
                        tier: SurfaceTier.card,
                        shape: cardLargeShape,
                        contentPadding: const EdgeInsets.all(Spacing.md),
                        child: AtelierTextField(
                          label: strings.affiliationEmail,
                          value: state.email,
                          onValueChange: onEmailChange,
                          leadingIcon: Icons.mail_outline,
                          enabled: !state.isBusy,
                          isError: state.invalidField == 'email',
                          errorText: state.invalidField == 'email' ? strings.receptionFieldEmail : null,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.search,
                          onSubmitted: onSearch,
                        ),
                      ),
                      if (showSkeleton)
                        Semantics(
                          label: strings.affiliationSearchingLabel,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: Spacing.sm,
                            children: [
                              Bone(
                                loading: true,
                                widthFraction: 0.7,
                                child: Text(strings.affiliationSearchingLabel, style: context.text.titleMedium),
                              ),
                              const AtelierListRow(
                                title: 'Vehículo de plataforma',
                                subtitle: 'Toyota Yaris 2021',
                                plate: 'BKL482',
                                loading: true,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._lookupResult(context, strings),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Material(
            color: context.scheme.surface,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(height: 1, thickness: 1, color: context.scheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.sm,
                      children: [
                        if (error != null)
                          AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
                        if (!state.isOnline) const AtelierRequiresConnection(),
                        ?action,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _lookupResult(BuildContext context, AppLocalizations strings) {
    final lookup = state.lookup;
    if (lookup == null) return const [];
    final affiliated = state.affiliated;
    if (affiliated != null) {
      return [
        AtelierBanner(
          message: strings.affiliationDone(affiliated.displayName),
          icon: Icons.check_circle_outline,
          kind: BannerKind.ok,
        ),
      ];
    }
    return switch (state.step) {
      AffiliationStep.alreadyCustomer => [
        AtelierBanner(
          title: strings.affiliationAlreadyTitle,
          message: strings.affiliationAlreadyBody(lookup.workshopCustomer?.displayName ?? state.email),
          icon: Icons.check_circle_outline,
          kind: BannerKind.ok,
        ),
      ],
      AffiliationStep.affiliate => [
        AtelierBanner(
          title: strings.affiliationFoundTitle,
          message: strings.affiliationFoundBody(
            lookup.platformAccount?.fullName ?? state.email,
            lookup.vehicles.length,
          ),
          icon: Icons.info_outline,
          kind: BannerKind.info,
        ),
        if (lookup.vehicles.isNotEmpty) ...[
          AtelierSectionHeader(title: strings.affiliationVehiclesHeader, count: lookup.vehicles.length),
          AtelierSurface(
            tier: SurfaceTier.card,
            shape: cardLargeShape,
            child: Column(
              children: [
                for (var i = 0; i < lookup.vehicles.length; i++)
                  AtelierListRow(
                    title: [
                      lookup.vehicles[i].brand,
                      lookup.vehicles[i].model,
                      if (lookup.vehicles[i].year != null) lookup.vehicles[i].year.toString(),
                    ].join(' '),
                    plate: lookup.vehicles[i].plate,
                    showDivider: i < lookup.vehicles.length - 1,
                  ),
              ],
            ),
          ),
        ],
        AtelierSurface(
          tier: SurfaceTier.card,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.sm,
            children: [
              AtelierTextField(
                label: strings.affiliationTaxId,
                value: state.taxId,
                onValueChange: onTaxIdChange,
                enabled: !state.isBusy,
                isError: state.invalidField == 'taxId',
                errorText: state.invalidField == 'taxId' ? strings.receptionFieldTaxIdPerson : null,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              AtelierTextField(
                label: strings.affiliationPhone,
                value: state.phone,
                onValueChange: onPhoneChange,
                enabled: !state.isBusy,
                isError: state.invalidField == 'phone',
                errorText: state.invalidField == 'phone' ? strings.receptionFieldPhone : null,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: onAffiliate,
              ),
            ],
          ),
        ),
      ],
      AffiliationStep.registerWalkIn || null => [
        AtelierBanner(
          title: strings.affiliationNotFoundTitle,
          message: strings.affiliationNotFoundBody,
          icon: Icons.info_outline,
          kind: BannerKind.wait,
        ),
      ],
    };
  }
}
