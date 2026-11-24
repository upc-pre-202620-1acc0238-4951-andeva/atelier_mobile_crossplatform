import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';

class LoginUiState {
  final String email;
  final String password;
  final bool passwordVisible;
  final bool isLoading;
  final UiText? error;

  /// Llegó desde la verificación del correo: se muestra el aviso de éxito.
  final bool emailVerified;

  /// Llegó desde A6 tras cambiar la contraseña: se muestra el aviso de éxito.
  final bool passwordReset;

  /// Un solo uso: el backend rechazó el acceso porque el correo no está verificado.
  final String? unverifiedEmail;

  /// Cantidad total de operaciones pendientes en el dispositivo (US04).
  final int devicePendingCount;

  const LoginUiState({
    this.email = '',
    this.password = '',
    this.passwordVisible = false,
    this.isLoading = false,
    this.error,
    this.emailVerified = false,
    this.passwordReset = false,
    this.unverifiedEmail,
    this.devicePendingCount = 0,
  });

  bool get canSubmit => !isLoading && AuthValidation.isEmail(email.trim()) && password.isNotEmpty;

  LoginUiState copyWith({
    String? email,
    String? password,
    bool? passwordVisible,
    bool? isLoading,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
    bool? emailVerified,
    bool? passwordReset,
    String? unverifiedEmail,
    bool clearUnverifiedEmail = false,
    int? devicePendingCount,
  }) {
    return LoginUiState(
      email: email ?? this.email,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      emailVerified: emailVerified ?? this.emailVerified,
      passwordReset: passwordReset ?? this.passwordReset,
      unverifiedEmail: clearUnverifiedEmail ? null : unverifiedEmail ?? this.unverifiedEmail,
      devicePendingCount: devicePendingCount ?? this.devicePendingCount,
    );
  }
}
