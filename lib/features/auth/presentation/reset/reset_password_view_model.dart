import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/reset_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/reset/reset_password_ui_state.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/foundation.dart';

/// A6 Recuperar contraseña · paso 2: token + contraseña nueva (US05 E1/E2).
class ResetPasswordViewModel extends ChangeNotifier {
  /// `iam.md` documenta 400, pero el backend real responde 404 («VerificationToken … was not found») si el
  /// token no existe. Los dos significan "enlace vencido o inválido".
  static const invalidTokenStatuses = {400, 404};

  final ResetPasswordUseCase resetPasswordUseCase;

  /// `token` de `ResetPasswordArgs`: llega precargado desde el enlace del correo (App Link).
  ResetPasswordViewModel({required this.resetPasswordUseCase, ResetPasswordArgs? args})
    : _state = ResetPasswordUiState(token: args?.token ?? '');

  bool _disposed = false;

  ResetPasswordUiState _state;
  ResetPasswordUiState get state => _state;

  void onTokenChange(String value) =>
      _update(_state.copyWith(token: value, clearError: true, tokenInvalid: false));

  void onPasswordChange(String value) => _update(_state.copyWith(password: value, clearError: true));

  void onConfirmationChange(String value) => _update(_state.copyWith(confirmation: value, clearError: true));

  void onPasswordVisibleChange(bool visible) => _update(_state.copyWith(passwordVisible: visible));

  void onConfirmationVisibleChange(bool visible) => _update(_state.copyWith(confirmationVisible: visible));

  /// `POST /auth/reset-password { token, newPassword }`. El enlace pegado se pasa tal cual:
  /// `ResetPasswordUseCase` extrae el `token` de la URL.
  Future<void> onSubmit() async {
    final current = _state;
    if (!current.canSubmit) return;
    _update(current.copyWith(isLoading: true, clearError: true, tokenInvalid: false));
    try {
      await resetPasswordUseCase.execute(current.token, current.password);
      _update(_state.copyWith(isLoading: false, done: true));
    } catch (e) {
      if (e is ApiException && invalidTokenStatuses.contains(e.httpStatus)) {
        _update(_state.copyWith(isLoading: false, tokenInvalid: true));
      } else {
        _update(_state.copyWith(isLoading: false, error: toUiText(e)));
      }
    }
  }

  void _update(ResetPasswordUiState state) {
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
