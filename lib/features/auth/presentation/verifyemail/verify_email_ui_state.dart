import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

class VerifyEmailUiState {
  static const resendCooldownSeconds = 60;

  /// El OTP vive 15 minutos (docs/03-traceability.md US02).
  static const codeLifetimeSeconds = 15 * 60;

  final String email;
  final String code;
  final bool isVerifying;
  final bool isResending;
  final UiText? error;
  final UiText? info;

  /// Segundos para poder pedir otro código.
  final int resendSecondsLeft;

  /// Segundos de vida del código. `null` hasta que la app envía uno (no se sabe cuándo se mandó el anterior).
  final int? expiresSecondsLeft;
  final bool verified;

  const VerifyEmailUiState({
    required this.email,
    this.code = '',
    this.isVerifying = false,
    this.isResending = false,
    this.error,
    this.info,
    this.resendSecondsLeft = resendCooldownSeconds,
    this.expiresSecondsLeft,
    this.verified = false,
  });

  bool get canSubmit => !isVerifying && !isResending && AuthValidation.isOtp(code);
  bool get canResend => resendSecondsLeft == 0 && !isVerifying && !isResending;

  /// `a•••••@taller.pe`: el correo no se muestra completo en pantalla.
  String get maskedEmail {
    final at = email.indexOf('@');
    final local = at < 0 ? email : email.substring(0, at);
    final domain = at < 0 ? '' : email.substring(at + 1);
    final head = local.isEmpty ? '' : String.fromCharCode(local.runes.first);
    return '$head•••••@$domain';
  }

  VerifyEmailUiState copyWith({
    String? code,
    bool? isVerifying,
    bool? isResending,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
    UiText? info,
    bool clearInfo = false,
    int? resendSecondsLeft,
    int? expiresSecondsLeft,
    bool? verified,
  }) {
    return VerifyEmailUiState(
      email: email,
      code: code ?? this.code,
      isVerifying: isVerifying ?? this.isVerifying,
      isResending: isResending ?? this.isResending,
      error: clearError ? null : error ?? this.error,
      info: clearInfo ? null : info ?? this.info,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
      expiresSecondsLeft: expiresSecondsLeft ?? this.expiresSecondsLeft,
      verified: verified ?? this.verified,
    );
  }
}
