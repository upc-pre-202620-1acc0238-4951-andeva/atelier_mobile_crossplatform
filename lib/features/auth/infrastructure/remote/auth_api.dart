import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/accept_invitation_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/forgot_password_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/google_sign_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/invitation_validation_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/message_response_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/resend_verification_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/reset_password_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/sign_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/auth/infrastructure/remote/verify_email_request_dto.dart';

/// Endpoints públicos de docs/api/iam.md. `refresh` y `sign-out` están en el núcleo.
class AuthApi {
  final ApiClient client;

  const AuthApi({required this.client});

  Future<AuthenticatedUserDto> signIn(SignInRequestDto body) {
    return _session('/api/v1/auth/sign-in', body.toJson());
  }

  Future<AuthenticatedUserDto> googleSignIn(GoogleSignInRequestDto body) {
    return _session('/api/v1/auth/google-sign-in', body.toJson());
  }

  /// 201 con la sesión completa.
  Future<AuthenticatedUserDto> acceptInvitation(
    AcceptInvitationRequestDto body,
  ) {
    return _session('/api/v1/invitations/accept', body.toJson());
  }

  Future<MessageResponseDto> verifyEmail(VerifyEmailRequestDto body) {
    return _message('/api/v1/auth/verify-email', body.toJson());
  }

  Future<MessageResponseDto> resendVerification(
    ResendVerificationRequestDto body,
  ) {
    return _message('/api/v1/auth/resend-verification', body.toJson());
  }

  Future<MessageResponseDto> forgotPassword(ForgotPasswordRequestDto body) {
    return _message('/api/v1/auth/forgot-password', body.toJson());
  }

  Future<MessageResponseDto> resetPassword(ResetPasswordRequestDto body) {
    return _message('/api/v1/auth/reset-password', body.toJson());
  }

  Future<InvitationValidationDto> validateInvitation(String token) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/invitations/validate',
      query: {'token': token},
    );
    return InvitationValidationDto.fromJson(json);
  }

  Future<AuthenticatedUserDto> _session(
    String path,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> json = await client.post(path, body: body);
    return AuthenticatedUserDto.fromJson(json);
  }

  Future<MessageResponseDto> _message(
    String path,
    Map<String, dynamic> body,
  ) async {
    final Map<String, dynamic> json = await client.post(path, body: body);
    return MessageResponseDto.fromJson(json);
  }
}
