import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_components.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A6 Recuperar contraseña · paso 1: pedir el enlace por correo (US05 E1).
class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onHaveToken;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final ForgotPasswordViewModel? viewModel;

  const ForgotPasswordScreen({
    super.key,
    required this.onBack,
    required this.onHaveToken,
    this.viewModel,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final ForgotPasswordViewModel _viewModel = widget.viewModel ?? getIt<ForgotPasswordViewModel>();

  @override
  void dispose() {
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => ForgotPasswordContent(
        state: _viewModel.state,
        onBack: widget.onBack,
        onEmailChange: _viewModel.onEmailChange,
        onSubmit: _viewModel.onSubmit,
        onHaveToken: widget.onHaveToken,
        onRequestAgain: _viewModel.onRequestAgain,
      ),
    );
  }
}

class ForgotPasswordContent extends StatelessWidget {
  final ForgotPasswordUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onEmailChange;
  final VoidCallback onSubmit;
  final VoidCallback onHaveToken;
  final VoidCallback onRequestAgain;

  const ForgotPasswordContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onEmailChange,
    required this.onSubmit,
    required this.onHaveToken,
    required this.onRequestAgain,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final error = state.error;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(title: strings.authForgotTitle, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  Rise(
                    child: AuthHeroHeader(
                      title: state.sent ? strings.authForgotSentTitle : strings.authForgotTitle,
                      subtitle: state.sent ? null : strings.authForgotBody,
                    ),
                  ),
                  Rise(
                    index: 1,
                    child: AtelierSurface(
                      tier: SurfaceTier.elevated,
                      shape: cardLargeShape,
                      contentPadding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: state.sent
                            ? [
                                AtelierBanner(
                                  message: strings.authForgotSent,
                                  icon: Icons.check_circle,
                                  kind: BannerKind.ok,
                                ),
                              ]
                            : [
                                if (error != null)
                                  AtelierBanner(
                                    message: error.asString(strings),
                                    icon: Icons.error,
                                    kind: BannerKind.bad,
                                  ),
                                AtelierTextField(
                                  label: strings.authEmailLabel,
                                  value: state.email,
                                  onValueChange: onEmailChange,
                                  leadingIcon: Icons.email_outlined,
                                  enabled: !state.isLoading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: onSubmit,
                                  autofillHints: const [AutofillHints.email],
                                ),
                              ],
                      ),
                    ),
                  ),
                ],
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: state.sent
                      ? [
                          AtelierButton(text: strings.authHaveToken, onClick: onHaveToken),
                          AtelierButton(
                            text: strings.authRequestAgain,
                            onClick: onRequestAgain,
                            style: AtelierButtonStyle.text,
                          ),
                        ]
                      : [
                          AtelierButton(
                            text: strings.authForgotAction,
                            onClick: onSubmit,
                            enabled: state.canSubmit,
                            loading: state.isLoading,
                          ),
                          AtelierButton(
                            text: strings.authHaveToken,
                            onClick: onHaveToken,
                            style: AtelierButtonStyle.text,
                            enabled: !state.isLoading,
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
