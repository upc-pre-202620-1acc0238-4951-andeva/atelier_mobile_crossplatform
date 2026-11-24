import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_otp_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_components.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A4 Verificar correo · código de 6 dígitos.
class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final VoidCallback onBack;
  final ValueChanged<String> onVerified;

  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final VerifyEmailViewModel? viewModel;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.onBack,
    required this.onVerified,
    this.viewModel,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailViewModel _viewModel = widget.viewModel ?? getIt<VerifyEmailViewModel>(param1: widget.email);
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  void _onChanged() {
    if (_handled || !_viewModel.state.verified) return;
    _handled = true;
    widget.onVerified(_viewModel.state.email);
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
      builder: (context, _) => VerifyEmailContent(
        state: _viewModel.state,
        onBack: widget.onBack,
        onCodeChange: _viewModel.onCodeChange,
        onVerify: _viewModel.onVerify,
        onResend: _viewModel.onResend,
      ),
    );
  }
}

class VerifyEmailContent extends StatelessWidget {
  final VerifyEmailUiState state;
  final VoidCallback onBack;
  final ValueChanged<String> onCodeChange;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const VerifyEmailContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onCodeChange,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final info = state.info;
    final error = state.error;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AtelierTopBar(title: strings.authVerifyTitle, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                children: [
                  Rise(
                    child: AuthHeroHeader(
                      title: strings.authOtpTitle,
                      subtitle: strings.authOtpSentTo(state.maskedEmail),
                    ),
                  ),
                  if (info != null)
                    AtelierBanner(message: info.asString(strings), icon: Icons.info, kind: BannerKind.info),
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
                          AtelierOtpField(
                            value: state.code,
                            onValueChange: onCodeChange,
                            contentDescription: strings.authOtpLabel(6),
                            isError: error != null,
                            enabled: !state.isVerifying,
                            onDone: onVerify,
                          ),
                          if (error != null)
                            Semantics(
                              liveRegion: true,
                              child: Row(
                                spacing: 6,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, size: 18, color: colors.bad),
                                  Expanded(
                                    child: Text(
                                      error.asString(strings),
                                      style: context.text.bodyMedium!.copyWith(color: colors.bad),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(child: _ExpiryLabel(secondsLeft: state.expiresSecondsLeft)),
                              AtelierButton(
                                text: state.canResend || state.isResending
                                    ? strings.authResend
                                    : strings.authResendIn(formatClock(state.resendSecondsLeft, pad: false)),
                                onClick: onResend,
                                style: AtelierButtonStyle.text,
                                enabled: state.canResend,
                                loading: state.isResending,
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
                  text: strings.authVerifyAction,
                  onClick: onVerify,
                  enabled: state.canSubmit,
                  loading: state.isVerifying,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Vence en 09:42"; solo aparece cuando la app envió el código y sabe cuándo vence.
class _ExpiryLabel extends StatelessWidget {
  final int? secondsLeft;

  const _ExpiryLabel({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final strings = AppLocalizations.of(context);
    final seconds = secondsLeft;
    if (seconds == null) return const SizedBox.shrink();
    if (seconds == 0) {
      return Text(strings.authOtpExpired, style: context.text.bodyMedium!.copyWith(color: colors.bad));
    }
    final clock = formatClock(seconds, pad: true);
    final text = strings.authOtpExpiresIn(clock);
    final start = text.indexOf(clock);
    final style = context.text.bodyMedium!.copyWith(color: colors.muted);
    if (start < 0) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: clock,
            style: TextStyle(fontWeight: FontWeight.w700, color: context.scheme.onSurface),
          ),
          TextSpan(text: text.substring(start + clock.length)),
        ],
      ),
    );
  }
}

/// `09:42` con [pad]; `9:42` sin él.
String formatClock(int totalSeconds, {required bool pad}) {
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '${pad ? minutes.toString().padLeft(2, '0') : minutes}:$seconds';
}
