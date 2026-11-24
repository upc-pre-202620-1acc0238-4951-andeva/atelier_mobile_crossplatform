import 'dart:async';
import 'dart:math' as math;

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/resend_verification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/verify_email_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_ui_state.dart';
import 'package:flutter/foundation.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResendVerificationUseCase resendVerificationUseCase;
  final String email;

  VerifyEmailViewModel({
    required this.verifyEmailUseCase,
    required this.resendVerificationUseCase,
    required this.email,
  }) : _state = VerifyEmailUiState(email: email) {
    _startTicker();
  }

  bool _disposed = false;
  Timer? _ticker;

  VerifyEmailUiState _state;
  VerifyEmailUiState get state => _state;

  void onCodeChange(String value) => _update(_state.copyWith(code: value, clearError: true));

  /// `POST /auth/verify-email { email, token }`. Con éxito la cuenta queda activa y se vuelve al login.
  Future<void> onVerify() async {
    final current = _state;
    if (!current.canSubmit) return;
    _update(current.copyWith(isVerifying: true, clearError: true, clearInfo: true));
    try {
      await verifyEmailUseCase.execute(email, current.code);
      _update(_state.copyWith(isVerifying: false, verified: true));
    } catch (e) {
      _update(_state.copyWith(isVerifying: false, error: toUiText(e)));
    }
  }

  /// `POST /auth/resend-verification`: código nuevo, y vuelven a correr el reenvío (60 s) y la vigencia (15 min).
  Future<void> onResend() async {
    if (!_state.canResend) return;
    _update(_state.copyWith(isResending: true, clearError: true, clearInfo: true));
    try {
      await resendVerificationUseCase.execute(email);
      _update(
        _state.copyWith(
          isResending: false,
          code: '',
          info: UiText.resource((s) => s.authOtpResent),
          resendSecondsLeft: VerifyEmailUiState.resendCooldownSeconds,
          expiresSecondsLeft: VerifyEmailUiState.codeLifetimeSeconds,
        ),
      );
      _startTicker();
    } catch (e) {
      _update(_state.copyWith(isResending: false, error: toUiText(e)));
    }
  }

  /// Un solo contador de 1 s; se detiene cuando ya no hay nada que descontar.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final expires = _state.expiresSecondsLeft;
      final next = _state.copyWith(
        resendSecondsLeft: math.max(0, _state.resendSecondsLeft - 1),
        expiresSecondsLeft: expires == null ? null : math.max(0, expires - 1),
      );
      _update(next);
      if (next.resendSecondsLeft == 0 && (next.expiresSecondsLeft ?? 0) == 0) timer.cancel();
    });
  }

  void _update(VerifyEmailUiState state) {
    if (_disposed) return; // Una respuesta puede llegar con la pantalla ya cerrada.
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
