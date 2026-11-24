import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_validation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invitation_preview.dart';

/// Pasos de A3: pegar el enlace → formulario, o invitación vencida.
enum RegisterStep { link, form, gone }

/// Por qué la invitación ya no sirve: 410 vencida, 404 inexistente o revocada.
enum InvitationProblem { expired, notFound }

class RegisterUiState {
  final RegisterStep step;
  final String linkInput;
  final InvitationPreview? invitation;
  final InvitationProblem? problem;
  final String firstName;
  final String lastName;
  final String password;
  final String confirmPassword;
  final bool passwordVisible;
  final bool confirmVisible;
  final bool isLoading;
  final UiText? error;

  const RegisterUiState({
    this.step = RegisterStep.link,
    this.linkInput = '',
    this.invitation,
    this.problem,
    this.firstName = '',
    this.lastName = '',
    this.password = '',
    this.confirmPassword = '',
    this.passwordVisible = false,
    this.confirmVisible = false,
    this.isLoading = false,
    this.error,
  });

  bool get hasMinLength => password.length >= AuthValidation.passwordMin;
  bool get hasUppercase => password.runes.any((r) {
    final char = String.fromCharCode(r);
    return char != char.toLowerCase() && char == char.toUpperCase();
  });
  bool get passwordsMatch => confirmPassword.isNotEmpty && password == confirmPassword;

  bool get canValidate => !isLoading && linkInput.trim().isNotEmpty;

  bool get canSubmit =>
      step == RegisterStep.form &&
      !isLoading &&
      AuthValidation.isName(firstName) &&
      AuthValidation.isName(lastName) &&
      AuthValidation.isPassword(password) &&
      hasUppercase &&
      passwordsMatch;

  RegisterUiState copyWith({
    RegisterStep? step,
    String? linkInput,
    InvitationPreview? invitation,
    InvitationProblem? problem,
    bool clearProblem = false,
    String? firstName,
    String? lastName,
    String? password,
    String? confirmPassword,
    bool? passwordVisible,
    bool? confirmVisible,
    bool? isLoading,
    UiText? error,
    bool clearError = false, // copyWith(error: null) no borraría el error
  }) {
    return RegisterUiState(
      step: step ?? this.step,
      linkInput: linkInput ?? this.linkInput,
      invitation: invitation ?? this.invitation,
      problem: clearProblem ? null : problem ?? this.problem,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmVisible: confirmVisible ?? this.confirmVisible,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
