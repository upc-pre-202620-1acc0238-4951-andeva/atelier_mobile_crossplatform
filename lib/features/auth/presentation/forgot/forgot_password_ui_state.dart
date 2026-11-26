import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

class ForgotPasswordUiState {
  final String email;
  final bool isLoading;

  /// El backend aceptó la solicitud. No dice si el correo existe, así que la confirmación es siempre la misma.
  final bool sent;
  final UiText? error;

  const ForgotPasswordUiState({
    this.email = '',
    this.isLoading = false,
    this.sent = false,
    this.error,
  });

  bool get canSubmit => !isLoading && AuthValidation.isEmail(email.trim());

  ForgotPasswordUiState copyWith({
    String? email,
    bool? isLoading,
    bool? sent,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
  }) {
    return ForgotPasswordUiState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      sent: sent ?? this.sent,
      error: clearError ? null : error ?? this.error,
    );
  }
}
