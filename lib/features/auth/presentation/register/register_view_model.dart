import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/accept_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/validate_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/accept_invitation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invalid_invitation_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_ui_state.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/foundation.dart';

class RegisterViewModel extends ChangeNotifier {
  final ValidateInvitationUseCase validateInvitationUseCase;
  final AcceptInvitationUseCase acceptInvitationUseCase;

  /// `token` de `RegisterArgs`: lo trae el enlace de invitación (deep link) y se valida al abrir.
  RegisterViewModel({
    required this.validateInvitationUseCase,
    required this.acceptInvitationUseCase,
    RegisterArgs? args,
  }) {
    final routeToken = args?.token;
    if (routeToken != null && routeToken.trim().isNotEmpty) {
      _state = _state.copyWith(linkInput: routeToken);
      onValidateLink();
    }
  }

  bool _disposed = false;

  /// Token ya extraído del enlace; se envía tal cual al aceptar.
  String _token = '';

  RegisterUiState _state = const RegisterUiState();
  RegisterUiState get state => _state;

  void onLinkChange(String value) => _update(_state.copyWith(linkInput: value, clearError: true));

  void onFirstNameChange(String value) => _update(_state.copyWith(firstName: value, clearError: true));

  void onLastNameChange(String value) => _update(_state.copyWith(lastName: value, clearError: true));

  void onPasswordChange(String value) => _update(_state.copyWith(password: value, clearError: true));

  void onConfirmPasswordChange(String value) => _update(_state.copyWith(confirmPassword: value, clearError: true));

  void onPasswordVisibleChange(bool visible) => _update(_state.copyWith(passwordVisible: visible));

  void onConfirmVisibleChange(bool visible) => _update(_state.copyWith(confirmVisible: visible));

  /// `GET /invitations/validate`: si es válida pasa al formulario; si venció o no existe, a la vista de aviso.
  Future<void> onValidateLink() async {
    final current = _state;
    if (!current.canValidate) return;
    final extracted = AuthValidation.tokenFrom(current.linkInput);
    _update(current.copyWith(isLoading: true, clearError: true));
    try {
      final preview = await validateInvitationUseCase.execute(extracted);
      _token = extracted;
      _update(
        _state.copyWith(isLoading: false, step: RegisterStep.form, invitation: preview, clearProblem: true),
      );
    } catch (e) {
      _failedWith(e);
    }
  }

  /// `POST /invitations/accept`: el backend devuelve la sesión y `AppRoot` entra a la app.
  Future<void> onSubmit() async {
    final current = _state;
    if (!current.canSubmit) return;
    _update(current.copyWith(isLoading: true, clearError: true));
    try {
      await acceptInvitationUseCase.execute(
        AcceptInvitation(
          token: _token,
          firstName: current.firstName,
          lastName: current.lastName,
          password: current.password,
          phone: null,
        ),
      );
      _update(_state.copyWith(isLoading: false));
    } catch (e) {
      _failedWith(e);
    }
  }

  /// 410 y 404 cierran el flujo con el aviso; el resto (409, red, 400) se muestra y se puede reintentar.
  void _failedWith(Object e) {
    final problem = switch (e) {
      InvalidInvitationException() => InvitationProblem.expired,
      ApiException(httpStatus: 410) => InvitationProblem.expired,
      ApiException(httpStatus: 404) => InvitationProblem.notFound,
      _ => null,
    };
    if (problem != null) {
      _update(_state.copyWith(isLoading: false, step: RegisterStep.gone, problem: problem, clearError: true));
    } else {
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  void _update(RegisterUiState state) {
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
