import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_profile_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/auth_refresh_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_maintenance_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/accept_invitation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invalid_invitation_exception.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invitation_preview.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/accept_invitation_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/auth_api.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/forgot_password_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/google_sign_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/resend_verification_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/reset_password_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/sign_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/verify_email_request_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi api;
  final EmployeeApi employeeApi;
  final AuthRefreshApi refreshApi;
  final SessionManager session;
  final DeviceTokenRegistrar deviceTokens;
  final CacheMaintenanceDao cacheDao;
  final PendingOperationDao pendingDao;
  final void Function() requestSync;

  const AuthRepositoryImpl({
    required this.api,
    required this.employeeApi,
    required this.refreshApi,
    required this.session,
    required this.deviceTokens,
    required this.cacheDao,
    required this.pendingDao,
    required this.requestSync,
  });

  @override
  Future<void> signIn(String email, String password) async {
    final user = await api.signIn(
      SignInRequestDto(email: email.trim(), password: password),
    );
    await _startSession(user);
  }

  @override
  Future<void> signInWithGoogle(String idToken) async {
    final user = await api.googleSignIn(
      GoogleSignInRequestDto(idToken: idToken),
    );
    await _startSession(user);
  }

  @override
  Future<String?> verifyEmail(String email, String code) async {
    final response = await api.verifyEmail(
      VerifyEmailRequestDto(email: email.trim(), token: code),
    );
    return response.message;
  }

  @override
  Future<String?> resendVerification(String email) async {
    final response = await api.resendVerification(
      ResendVerificationRequestDto(email: email.trim()),
    );
    return response.message;
  }

  @override
  Future<InvitationPreview> validateInvitation(String token) async {
    final dto = await api.validateInvitation(token.trim());
    if (!dto.valid) throw const InvalidInvitationException();
    return InvitationPreview(
      email: dto.email ?? '',
      tenantName: dto.tenantName ?? '',
      roleName: dto.roleName ?? '',
    );
  }

  @override
  Future<void> acceptInvitation(AcceptInvitation request) async {
    final phone = request.phone?.trim();
    final user = await api.acceptInvitation(
      AcceptInvitationRequestDto(
        token: request.token.trim(),
        firstName: request.firstName.trim(),
        lastName: request.lastName.trim(),
        password: request.password,
        phone: phone == null || phone.isEmpty ? null : phone,
      ),
    );
    await _startSession(user);
  }

  @override
  Future<String?> forgotPassword(String email) async {
    final response = await api.forgotPassword(
      ForgotPasswordRequestDto(email: email.trim()),
    );
    return response.message;
  }

  @override
  Future<String?> resetPassword(String token, String newPassword) async {
    final response = await api.resetPassword(
      ResetPasswordRequestDto(token: token.trim(), newPassword: newPassword),
    );
    return response.message;
  }

  @override
  Future<int> pendingOperationCount() async {
    final userId = await session.getUserId();
    if (userId == null) return 0;
    return pendingDao.watchPendingCount(userId).first;
  }

  /// Orden de docs/07-roadmap.md (paso 2). A diferencia de Android, `ApiClient` lanza en vez de
  /// devolver el error: nada de la red debe impedir salir.
  @override
  Future<void> signOut() async {
    try {
      await _bestEffort('borrar el token del dispositivo', deviceTokens.clear);
      // Después del PUT: su 401 puede renovar y rotar el token, y revocar el viejo dejaría vivo el nuevo.
      final refreshToken = await session.getRefreshToken();
      if (refreshToken != null) {
        await _bestEffort(
          'revocar el refresh token',
          () => refreshApi.signOut(refreshToken),
        );
      }
    } finally {
      try {
        await cacheDao.clearCaches();
      } finally {
        await session.clear();
      }
    }
  }

  /// Común a sign-in, Google y aceptar invitación. La sede se pide antes de guardar y el `save` va
  /// al final: es lo que hace visible la sesión, y así AppRoot la ve completa en su primera lectura.
  Future<void> _startSession(AuthenticatedUserDto user) async {
    final membershipId = user.membershipId;
    EmployeeProfileDto? profile;
    var withoutWorkProfile = membershipId == null;
    if (membershipId != null) {
      try {
        profile = await employeeApi.getByMembership(
          membershipId,
          token: user.token,
        );
      } on ApiException catch (e) {
        // Solo un 404 es "sin perfil laboral" (H33). Otro error no debe dejar elegir sede.
        withoutWorkProfile = e.httpStatus == 404;
      } on NetworkException {
        // Se entra sin sede.
      }
    }

    await session.updateAssignment(profile?.branchId, profile?.assignedShiftId);
    await session.setBranchChoicePending(withoutWorkProfile);
    await session.save(user);

    await _bestEffort(
      'registrar el token del dispositivo',
      deviceTokens.registerCurrentToken,
    );
    requestSync(); // "Tras entrar, se envían" (docs/06-offline-sync.md).
  }

  Future<void> _bestEffort(String what, Future<void> Function() call) async {
    try {
      await call();
    } on ApiException catch (e) {
      log('No se pudo $what: $e', name: 'AuthRepository');
    } on NetworkException catch (e) {
      log('No se pudo $what: $e', name: 'AuthRepository');
    }
  }
}
