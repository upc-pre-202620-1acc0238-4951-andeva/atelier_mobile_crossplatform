import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/auth_refresh_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_maintenance_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/notification_permission_requester.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/accept_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/forgot_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/google_sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/request_notification_permission_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/resend_verification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/reset_password_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/select_branch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/sign_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/skip_branch_choice_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/validate_invitation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/verify_email_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_choice_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/google_id_token_provider.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/notification_permission_gateway.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/branch_choice_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/google/google_sign_in_id_token_provider.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/auth_api.dart';

void setupAuthDependencies() {
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      api: getIt<AuthApi>(),
      employeeApi: getIt<EmployeeApi>(),
      refreshApi: getIt<AuthRefreshApi>(),
      session: getIt<SessionManager>(),
      deviceTokens: getIt<DeviceTokenRegistrar>(),
      cacheDao: getIt<CacheMaintenanceDao>(),
      pendingDao: getIt<PendingOperationDao>(),
      requestSync: getIt<SyncProcessor>().runDetached,
    ),
  );
  getIt.registerLazySingleton<BranchChoiceRepository>(
    () => BranchChoiceRepositoryImpl(
      api: getIt<BranchApi>(),
      session: getIt<SessionManager>(),
    ),
  );
  getIt.registerLazySingleton<GoogleIdTokenProvider>(
    () => GoogleSignInIdTokenProvider(
      webClientId: AppConfig.googleWebClientId,
      iosClientId: AppConfig.googleIosClientId,
    ),
  );
  getIt.registerLazySingleton<NotificationPermissionGateway>(
    () => NotificationPermissionRequester(
      registrar: getIt<DeviceTokenRegistrar>(),
    ),
  );

  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GoogleSignInUseCase>(
    () => GoogleSignInUseCase(
      provider: getIt<GoogleIdTokenProvider>(),
      repository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResendVerificationUseCase>(
    () => ResendVerificationUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ValidateInvitationUseCase>(
    () => ValidateInvitationUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<AcceptInvitationUseCase>(
    () => AcceptInvitationUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetPendingOperationCountUseCase>(
    () => GetPendingOperationCountUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(repository: getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetSelectableBranchesUseCase>(
    () => GetSelectableBranchesUseCase(
      repository: getIt<BranchChoiceRepository>(),
    ),
  );
  getIt.registerLazySingleton<SelectBranchUseCase>(
    () => SelectBranchUseCase(repository: getIt<BranchChoiceRepository>()),
  );
  getIt.registerLazySingleton<SkipBranchChoiceUseCase>(
    () => SkipBranchChoiceUseCase(repository: getIt<BranchChoiceRepository>()),
  );
  getIt.registerLazySingleton<RequestNotificationPermissionUseCase>(
    () => RequestNotificationPermissionUseCase(
      gateway: getIt<NotificationPermissionGateway>(),
    ),
  );
}
