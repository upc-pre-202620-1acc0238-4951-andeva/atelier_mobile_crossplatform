import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_components.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// A5 Iniciar sesión. Con sesión guardada `AppRoot` cambia de grafo solo.
/// "¿Olvidaste tu contraseña?" abre A6 (US05).
class LoginScreen extends StatefulWidget {
  final LoginArgs? args;
  final VoidCallback onHaveInvitation;
  final ValueChanged<String> onVerifyEmail;
  final VoidCallback? onForgotPassword;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final LoginViewModel? viewModel;

  const LoginScreen({
    super.key,
    this.args,
    required this.onHaveInvitation,
    required this.onVerifyEmail,
    this.onForgotPassword,
    this.viewModel,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginViewModel _viewModel = widget.viewModel ?? getIt<LoginViewModel>(param1: widget.args);

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    final email = _viewModel.state.unverifiedEmail;
    if (email == null) return;
    widget.onVerifyEmail(email);
    _viewModel.onVerificationHandled();
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
      builder: (context, _) => LoginContent(
        state: _viewModel.state,
        onEmailChange: _viewModel.onEmailChange,
        onPasswordChange: _viewModel.onPasswordChange,
        onPasswordVisibleChange: _viewModel.onPasswordVisibleChange,
        onSubmit: _viewModel.onSubmit,
        onHaveInvitation: widget.onHaveInvitation,
        onForgotPassword: widget.onForgotPassword,
      ),
    );
  }
}

class LoginContent extends StatelessWidget {
  final LoginUiState state;
  final ValueChanged<String> onEmailChange;
  final ValueChanged<String> onPasswordChange;
  final ValueChanged<bool> onPasswordVisibleChange;
  final VoidCallback onSubmit;
  final VoidCallback onHaveInvitation;
  final VoidCallback? onForgotPassword;

  const LoginContent({
    super.key,
    required this.state,
    required this.onEmailChange,
    required this.onPasswordChange,
    required this.onPasswordVisibleChange,
    required this.onSubmit,
    required this.onHaveInvitation,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final atelier = context.atelier;
    final forgot = onForgotPassword;
    final error = state.error;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    Rise(
                      child: AuthHeroHeader(title: strings.authLoginTitle, subtitle: strings.authLoginSubtitle),
                    ),
                    if (state.devicePendingCount > 0)
                      AtelierBanner(
                        message: strings.authDevicePendingBanner(state.devicePendingCount),
                        icon: Icons.info_outlined,
                        kind: BannerKind.info,
                      ),
                    if (state.emailVerified)
                      AtelierBanner(message: strings.authEmailVerified, icon: Icons.check_circle, kind: BannerKind.ok),
                    if (state.passwordReset)
                      AtelierBanner(
                        message: strings.authPasswordUpdated,
                        icon: Icons.check_circle,
                        kind: BannerKind.ok,
                      ),
                    if (error != null)
                      AtelierBanner(message: error.asString(strings), icon: Icons.error, kind: BannerKind.bad),
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
                              label: strings.authEmailLabel,
                              value: state.email,
                              onValueChange: onEmailChange,
                              leadingIcon: Icons.email_outlined,
                              enabled: !state.isLoading,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email, AutofillHints.username],
                            ),
                            AtelierPasswordField(
                              label: strings.authPasswordLabel,
                              value: state.password,
                              onValueChange: onPasswordChange,
                              visible: state.passwordVisible,
                              onVisibleChange: onPasswordVisibleChange,
                              enabled: !state.isLoading,
                              imeAction: TextInputAction.done,
                              onImeAction: onSubmit,
                            ),
                            if (forgot != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.translate(
                                  offset: const Offset(-12, 0),
                                  child: AtelierButton(
                                    text: strings.authForgotPassword,
                                    onClick: forgot,
                                    style: AtelierButtonStyle.text,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Rise(
                      index: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            AtelierButton(
                              text: strings.authLoginAction,
                              onClick: onSubmit,
                              enabled: state.canSubmit,
                              loading: state.isLoading,
                            ),
                            Row(
                              spacing: 12,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: Divider(height: 1, color: context.scheme.outlineVariant)),
                                Text(strings.authOr, style: context.text.labelMedium!.copyWith(color: atelier.muted)),
                                Expanded(child: Divider(height: 1, color: context.scheme.outlineVariant)),
                              ],
                            ),
                            AtelierButton(
                              text: strings.authHaveInvitation,
                              onClick: onHaveInvitation,
                              style: AtelierButtonStyle.outlined,
                              enabled: !state.isLoading,
                              icon: Icons.link_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
