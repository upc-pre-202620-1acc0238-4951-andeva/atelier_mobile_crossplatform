import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

class ResetPasswordUiState {
  /// Enlace completo del correo o solo el token (H1: sin App Link se pega).
  final String token;
  final String password;
  final String confirmation;
  final bool passwordVisible;
  final bool confirmationVisible;
  final bool isLoading;
  final bool done;
  final UiText? error;

  /// 400/404: el enlace venció, se usó o es inválido (US05 E2). La contraseña previa no cambia.
  final bool tokenInvalid;

  const ResetPasswordUiState({
    this.token = '',
    this.password = '',
    this.confirmation = '',
    this.passwordVisible = false,
    this.confirmationVisible = false,
    this.isLoading = false,
    this.done = false,
    this.error,
    this.tokenInvalid = false,
  });

  bool get hasMinLength => password.length >= AuthValidation.passwordMin;

  bool get hasUppercase => password.runes.any((r) {
    final char = String.fromCharCode(r);
    return char != char.toLowerCase() && char == char.toUpperCase();
  });

  bool get passwordsMatch => confirmation.isNotEmpty && password == confirmation;

  /// Un enlace sin `token` (o con `?token=` vacío) no cuenta: no se envía un token vacío.
  bool get hasValidExtractedToken => AuthValidation.tokenFrom(token).trim().isNotEmpty;

  bool get hasUnsavedChanges => !done && (password.isNotEmpty || confirmation.isNotEmpty);

  bool get canSubmit =>
      !isLoading &&
      hasValidExtractedToken &&
      AuthValidation.isPassword(password) &&
      hasUppercase &&
      passwordsMatch;

  ResetPasswordUiState copyWith({
    String? token,
    String? password,
    String? confirmation,
    bool? passwordVisible,
    bool? confirmationVisible,
    bool? isLoading,
    bool? done,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
    bool? tokenInvalid,
  }) {
    return ResetPasswordUiState(
      token: token ?? this.token,
      password: password ?? this.password,
      confirmation: confirmation ?? this.confirmation,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmationVisible: confirmationVisible ?? this.confirmationVisible,
      isLoading: isLoading ?? this.isLoading,
      done: done ?? this.done,
      error: clearError ? null : error ?? this.error,
      tokenInvalid: tokenInvalid ?? this.tokenInvalid,
    );
  }
}
