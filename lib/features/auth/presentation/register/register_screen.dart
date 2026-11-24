import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_components.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// A3 Registro por invitación: enlace → formulario | vencida. Al aceptar, `AppRoot` entra a la app.
class RegisterScreen extends StatefulWidget {
  final RegisterArgs? args;
  final VoidCallback onBack;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final RegisterViewModel? viewModel;

  const RegisterScreen({super.key, this.args, required this.onBack, this.viewModel});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterViewModel _viewModel = widget.viewModel ?? getIt<RegisterViewModel>(param1: widget.args);

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => RegisterContent(
        state: _viewModel.state,
        onBack: widget.onBack,
        onLinkChange: _viewModel.onLinkChange,
        onValidateLink: _viewModel.onValidateLink,
        onFirstNameChange: _viewModel.onFirstNameChange,
        onLastNameChange: _viewModel.onLastNameChange,
        onPasswordChange: _viewModel.onPasswordChange,
        onConfirmPasswordChange: _viewModel.onConfirmPasswordChange,
        onPasswordVisibleChange: _viewModel.onPasswordVisibleChange,
        onConfirmVisibleChange: _viewModel.onConfirmVisibleChange,
        onSubmit: _viewModel.onSubmit,
      ),
    );
  }
}

class RegisterContent extends StatelessWidget {
  final RegisterUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onLinkChange;
  final VoidCallback onValidateLink;
  final ValueChanged<String> onFirstNameChange;
  final ValueChanged<String> onLastNameChange;
  final ValueChanged<String> onPasswordChange;
  final ValueChanged<String> onConfirmPasswordChange;
  final ValueChanged<bool> onPasswordVisibleChange;
  final ValueChanged<bool> onConfirmVisibleChange;
  final VoidCallback onSubmit;

  const RegisterContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onLinkChange,
    required this.onValidateLink,
    required this.onFirstNameChange,
    required this.onLastNameChange,
    required this.onPasswordChange,
    required this.onConfirmPasswordChange,
    required this.onPasswordVisibleChange,
    required this.onConfirmVisibleChange,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(title: strings.authRegisterTitle, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: switch (state.step) {
                  RegisterStep.link => _linkStep(context, strings),
                  RegisterStep.form => _formStep(context, strings),
                  RegisterStep.gone => _goneStep(context, strings),
                },
              ),
            ),
          ),
          // Pie fijo: la acción principal siempre queda al alcance del pulgar.
          Divider(height: 1, color: colors.outlineSoft),
          ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 16),
                child: switch (state.step) {
                  RegisterStep.link => AtelierButton(
                    text: strings.authContinue,
                    onClick: onValidateLink,
                    enabled: state.canValidate,
                    loading: state.isLoading,
                  ),
                  RegisterStep.form => AtelierButton(
                    text: strings.authCompleteRegistration,
                    onClick: onSubmit,
                    enabled: state.canSubmit,
                    loading: state.isLoading,
                  ),
                  RegisterStep.gone => AtelierButton(
                    text: strings.authBackToLogin,
                    onClick: onBack,
                    style: AtelierButtonStyle.outlined,
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _linkStep(BuildContext context, AppLocalizations strings) {
    final error = state.error;
    return [
      Rise(
        child: AuthHeroHeader(title: strings.authLinkTitle, subtitle: strings.authLinkBody),
      ),
      if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error),
      Rise(
        index: 1,
        child: AtelierSurface(
          tier: SurfaceTier.elevated,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(20),
          child: AtelierTextField(
            label: strings.authLinkLabel,
            value: state.linkInput,
            onValueChange: onLinkChange,
            leadingIcon: Icons.link_outlined,
            placeholder: strings.authLinkPlaceholder,
            enabled: !state.isLoading,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            onSubmitted: onValidateLink,
          ),
        ),
      ),
    ];
  }

  List<Widget> _formStep(BuildContext context, AppLocalizations strings) {
    final invitation = state.invitation;
    final error = state.error;
    return [
      Rise(
        child: AuthHeroHeader(
          title: invitation?.tenantName ?? strings.authRegisterTitle,
          subtitle: invitation != null ? strings.authInvitedTo : null,
          badge: invitation != null && invitation.roleName.trim().isNotEmpty
              ? AtelierChip(
                  text: strings.authInvitedRole(invitation.roleName),
                  kind: ChipKind.info,
                  icon: Icons.badge,
                )
              : null,
        ),
      ),
      if (error != null) AtelierBanner(message: error.asString(strings), icon: Icons.error),
      Rise(
        index: 1,
        child: AtelierSurface(
          tier: SurfaceTier.elevated,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              AtelierTextField(
                label: strings.authFirstName,
                value: state.firstName,
                onValueChange: onFirstNameChange,
                leadingIcon: Icons.person_outlined,
                enabled: !state.isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
              ),
              AtelierTextField(
                label: strings.authLastName,
                value: state.lastName,
                onValueChange: onLastNameChange,
                leadingIcon: Icons.person_outlined,
                enabled: !state.isLoading,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
              ),
              AtelierPasswordField(
                label: strings.authPasswordLabel,
                value: state.password,
                onValueChange: onPasswordChange,
                visible: state.passwordVisible,
                onVisibleChange: onPasswordVisibleChange,
                enabled: !state.isLoading,
                imeAction: TextInputAction.next,
                autofill: const [AutofillHints.newPassword],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  PasswordRule(text: strings.authRuleLength, met: state.hasMinLength),
                  PasswordRule(text: strings.authRuleUppercase, met: state.hasUppercase),
                  PasswordRule(text: strings.authRuleMatch, met: state.passwordsMatch),
                ],
              ),
              AtelierPasswordField(
                label: strings.authConfirmPassword,
                value: state.confirmPassword,
                onValueChange: onConfirmPasswordChange,
                visible: state.confirmVisible,
                onVisibleChange: onConfirmVisibleChange,
                enabled: !state.isLoading,
                imeAction: TextInputAction.done,
                onImeAction: onSubmit,
                autofill: const [AutofillHints.newPassword],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _goneStep(BuildContext context, AppLocalizations strings) {
    final expired = state.problem != InvitationProblem.notFound;
    final title = expired ? strings.authInvitationExpiredTitle : strings.authInvitationGoneTitle;
    return [
      Rise(child: AuthHeroHeader(title: title)),
      Rise(
        index: 1,
        child: AtelierSurface(
          tier: SurfaceTier.elevated,
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(20),
          child: AtelierBanner(
            title: title,
            message: expired ? strings.authInvitationExpiredBody : strings.authInvitationGoneBody,
            icon: Icons.link_off_outlined,
          ),
        ),
      ),
    ];
  }
}

/// Regla de contraseña: verde y rellena al cumplirse, gris y vacía mientras no. Lleva texto, no solo color.
class PasswordRule extends StatelessWidget {
  final String text;
  final bool met;

  const PasswordRule({super.key, required this.text, required this.met});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final strings = AppLocalizations.of(context);
    final tint = met ? colors.ok : colors.muted;
    return Semantics(
      container: true,
      label: text,
      value: met ? strings.authRuleMet : strings.authRulePending,
      excludeSemantics: true,
      child: Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(met ? Icons.check_circle : Icons.radio_button_unchecked_outlined, size: 18, color: tint),
          Expanded(child: Text(text, style: context.text.bodyMedium!.copyWith(color: tint))),
        ],
      ),
    );
  }
}
