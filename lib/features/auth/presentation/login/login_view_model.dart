import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_device_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_errors.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_ui_state.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/foundation.dart';

class LoginViewModel extends ChangeNotifier {
  final SignInUseCase signInUseCase;
  /// Conteo del dispositivo, no del usuario: en el login no hay sesión (US04).
  final GetDevicePendingOperationCountUseCase getDevicePendingCountUseCase;

  /// `verifiedEmail` de `LoginRoute`: correo recién verificado en A4. `passwordReset`: contraseña recién cambiada.
  LoginViewModel({
    required this.signInUseCase,
    required this.getDevicePendingCountUseCase,
    LoginArgs? args,
  }) : _state = LoginUiState(
         email: args?.verifiedEmail ?? '',
         emailVerified: args?.verifiedEmail != null,
         passwordReset: args?.passwordReset ?? false,
       ) {
    _loadDevicePendingCount();
  }

  bool _disposed = false;

  LoginUiState _state;
  LoginUiState get state => _state;

  Future<void> _loadDevicePendingCount() async {
    try {
      final count = await getDevicePendingCountUseCase.execute();
      if (count > 0) _update(_state.copyWith(devicePendingCount: count));
    } on Exception catch (e) {
      log('No se pudo contar lo pendiente del teléfono: $e', name: 'LoginViewModel');
    }
  }

  void onEmailChange(String value) => _update(_state.copyWith(email: value, clearError: true));

  void onPasswordChange(String value) => _update(_state.copyWith(password: value, clearError: true));

  void onPasswordVisibleChange(bool visible) => _update(_state.copyWith(passwordVisible: visible));

  Future<void> onSubmit() async {
    final current = _state;
    if (!current.canSubmit) return;
    _update(current.copyWith(isLoading: true, clearError: true, emailVerified: false, passwordReset: false));
    try {
      await signInUseCase.execute(current.email, current.password);
      // Con la sesión guardada `AppRoot` cambia de grafo: aquí solo se libera el botón.
      _update(_state.copyWith(isLoading: false));
    } catch (e) {
      if (e is ApiException && e.code == emailNotVerifiedCode) {
        // El backend marca la cuenta sin verificar con `EMAIL_NOT_VERIFIED` (403): de ahí se pasa al OTP.
        _update(_state.copyWith(isLoading: false, unverifiedEmail: current.email.trim()));
      } else {
        _update(_state.copyWith(isLoading: false, error: toUiText(e)));
      }
    }
  }

  void onVerificationHandled() => _update(_state.copyWith(clearUnverifiedEmail: true));

  void _update(LoginUiState state) {
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
