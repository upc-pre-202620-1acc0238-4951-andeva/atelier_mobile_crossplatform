import 'package:atelier_mobile_crossplatform/features/auth/domain/accept_invitation.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/invitation_preview.dart';

/// Sesión y acceso (US01–US05, docs/api/iam.md). Todo es en línea: nada se encola.
/// Los métodos que devuelven `String?` entregan el `message` del backend.
abstract class AuthRepository {
  /// Inicia sesión y deja guardada la sesión con su sede y turno.
  Future<void> signIn(String email, String password);

  Future<void> signInWithGoogle(String idToken);

  Future<String?> verifyEmail(String email, String code);

  Future<String?> resendVerification(String email);

  Future<InvitationPreview> validateInvitation(String token);

  /// El backend devuelve la sesión completa y se entra directo, sin pasar por el OTP.
  Future<void> acceptInvitation(AcceptInvitation request);

  Future<String?> forgotPassword(String email);

  Future<String?> resetPassword(String token, String newPassword);

  /// Operaciones de la cola del usuario actual que aún no se enviaron. Sin sesión, 0.
  Future<int> pendingOperationCount();

  /// Operaciones guardadas en el dispositivo, de cualquier usuario y sin necesitar sesión: el login avisa
  /// que hay trabajo local tras un cierre o una sesión vencida (US04).
  Future<int> devicePendingOperationCount();

  /// Cierre seguro (US04 E1). Nunca falla por la red: sin conexión igual se sale. Empaqueta lo capturado
  /// por el usuario saliente, revoca el token del dispositivo y el refresh token, borra cachés, avisos y
  /// archivos temporales, y al final la sesión. La cola se conserva (06 §3).
  Future<void> signOut();
}
