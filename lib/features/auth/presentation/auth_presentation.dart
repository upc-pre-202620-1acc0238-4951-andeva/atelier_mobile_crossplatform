import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/accept_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/resend_verification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/select_branch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/skip_branch_choice_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/validate_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/verify_email_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/auth_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/branch/branch_selection_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/login/login_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/register/register_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/auth/presentation/verifyemail/verify_email_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// ViewModels y destinos de `auth` (login, registro por invitación, verificar correo, elegir sede).
/// Solo la UI lo llama: el worker no tiene pantallas.
void setupAuthPresentation() {
  getIt.registerFactoryParam<LoginViewModel, LoginArgs?, void>(
    (args, _) => LoginViewModel(
      signInUseCase: getIt<SignInUseCase>(),
      getPendingCountUseCase: getIt<GetPendingOperationCountUseCase>(),
      args: args,
    ),
  );
  getIt.registerFactoryParam<RegisterViewModel, RegisterArgs?, void>(
    (args, _) => RegisterViewModel(
      validateInvitationUseCase: getIt<ValidateInvitationUseCase>(),
      acceptInvitationUseCase: getIt<AcceptInvitationUseCase>(),
      args: args,
    ),
  );
  getIt.registerFactoryParam<VerifyEmailViewModel, String, void>(
    (email, _) => VerifyEmailViewModel(
      verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
      resendVerificationUseCase: getIt<ResendVerificationUseCase>(),
      email: email,
    ),
  );
  getIt.registerFactory<BranchSelectionViewModel>(
    () => BranchSelectionViewModel(
      getBranchesUseCase: getIt<GetSelectableBranchesUseCase>(),
      selectBranchUseCase: getIt<SelectBranchUseCase>(),
      skipBranchChoiceUseCase: getIt<SkipBranchChoiceUseCase>(),
      observeSessionUseCase: getIt<ObserveSessionUseCase>(),
    ),
  );

  registerAuthDestinations(
    deepLinks: () => getIt.isRegistered<AuthDeepLinkInbox>() ? getIt<AuthDeepLinkInbox>() : null,
  );
}
