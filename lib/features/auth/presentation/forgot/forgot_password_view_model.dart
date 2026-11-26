import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/forgot_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/forgot/forgot_password_ui_state.dart';
import 'package:flutter/foundation.dart';

/// A6 Recuperar contraseña · paso 1 (US05 E1).
class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordViewModel({required this.forgotPasswordUseCase});

  bool _disposed = false;

  ForgotPasswordUiState _state = const ForgotPasswordUiState();
  ForgotPasswordUiState get state => _state;

  void onEmailChange(String value) => _update(_state.copyWith(email: value, clearError: true));

  /// `POST /auth/forgot-password { email }`. Con éxito se muestra la confirmación genérica.
  Future<void> onSubmit() async {
    final current = _state;
    if (!current.canSubmit) return;
    _update(current.copyWith(isLoading: true, clearError: true));
    try {
      await forgotPasswordUseCase.execute(current.email);
      _update(_state.copyWith(isLoading: false, sent: true));
    } catch (e) {
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  /// Volver a pedir el enlace (por ejemplo, con otro correo).
  void onRequestAgain() => _update(_state.copyWith(sent: false));

  void _update(ForgotPasswordUiState state) {
    if (_disposed) return; // Una respuesta puede llegar con la pantalla ya cerrada.
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
