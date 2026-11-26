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
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_screen.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// A6 Recuperar contraseña · paso 2: pegar el enlace o código y elegir la contraseña nueva (US05).
class ResetPasswordScreen extends StatefulWidget {
  final ResetPasswordArgs? args;
  final VoidCallback onBack;
  final VoidCallback onRequestNewLink;
  final VoidCallback onDone;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final ResetPasswordViewModel? viewModel;

  const ResetPasswordScreen({
    super.key,
    this.args,
    required this.onBack,
    required this.onRequestNewLink,
    required this.onDone,
    this.viewModel,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final ResetPasswordViewModel _viewModel =
      widget.viewModel ?? getIt<ResetPasswordViewModel>(param1: widget.args);
  bool _doneHandled = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_viewModel.state.done || _doneHandled) return;
    _doneHandled = true;
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
      builder: (context, _) => ResetPasswordContent(
        state: _viewModel.state,
        onBack: widget.onBack,
        onTokenChange: _viewModel.onTokenChange,
        onPasswordChange: _viewModel.onPasswordChange,
        onConfirmationChange: _viewModel.onConfirmationChange,
        onPasswordVisibleChange: _viewModel.onPasswordVisibleChange,
        onConfirmationVisibleChange: _viewModel.onConfirmationVisibleChange,
        onSubmit: _viewModel.onSubmit,
        onRequestNewLink: widget.onRequestNewLink,
      ),
    );
  }
}

class ResetPasswordContent extends StatelessWidget {
  final ResetPasswordUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onTokenChange;
  final ValueChanged<String> onPasswordChange;
  final ValueChanged<String> onConfirmationChange;
  final ValueChanged<bool> onPasswordVisibleChange;
  final ValueChanged<bool> onConfirmationVisibleChange;
  final VoidCallback onSubmit;
  final VoidCallback onRequestNewLink;

  const ResetPasswordContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onTokenChange,
    required this.onPasswordChange,
    required this.onConfirmationChange,
    required this.onPasswordVisibleChange,
    required this.onConfirmationVisibleChange,
    required this.onSubmit,
    required this.onRequestNewLink,
  });

  /// Con contraseña escrita, salir pide confirmación (como el `BackHandler` de Android).
  Future<void> _handleBack(BuildContext context) async {
    if (!state.hasUnsavedChanges) {
      onBack();
      return;
    }
    if (await _confirmDiscard(context)) onBack();
  }

  static Future<bool> _confirmDiscard(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.commonDiscardChangesTitle),
        content: Text(strings.commonDiscardChangesBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.commonKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.commonDiscardAction),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final error = state.error;
    return PopScope(
      canPop: !state.hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack(context);
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AtelierTopBar(title: strings.authResetTitle, onBack: () => _handleBack(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 20,
                  children: [
                    Rise(
                      child: AuthHeroHeader(title: strings.authResetTitle, subtitle: strings.authResetBody),
                    ),
                    if (state.tokenInvalid) ...[
                      Rise(
                        child: AtelierBanner(message: strings.authResetInvalid, icon: Icons.error),
                      ),
                      AtelierButton(
                        text: strings.authResetRequestNew,
                        onClick: onRequestNewLink,
                        style: AtelierButtonStyle.outlined,
                      ),
                    ],
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
                              label: strings.authResetTokenLabel,
                              value: state.token,
                              onValueChange: onTokenChange,
                              leadingIcon: Icons.link_outlined,
                              isError: state.tokenInvalid,
                              enabled: !state.isLoading,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
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
                            AtelierPasswordField(
                              label: strings.authConfirmPassword,
                              value: state.confirmation,
                              onValueChange: onConfirmationChange,
                              visible: state.confirmationVisible,
                              onVisibleChange: onConfirmationVisibleChange,
                              enabled: !state.isLoading,
                              imeAction: TextInputAction.done,
                              onImeAction: onSubmit,
                              autofill: const [AutofillHints.newPassword],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 6,
                              children: [
                                PasswordRule(text: strings.authRuleLength, met: state.hasMinLength),
                                PasswordRule(text: strings.authRuleUppercase, met: state.hasUppercase),
                                PasswordRule(text: strings.authRuleMatch, met: state.passwordsMatch),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    strings.authResetHint,
                                    style: context.text.bodySmall?.copyWith(color: colors.muted),
                                  ),
                                ),
                              ],
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
            ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 16),
                  child: AtelierButton(
                    text: strings.authResetAction,
                    onClick: onSubmit,
                    enabled: state.canSubmit,
                    loading: state.isLoading,
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
