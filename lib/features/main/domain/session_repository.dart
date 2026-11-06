import 'package:atelier_mobile_crossplatform/core/domain/session.dart';

abstract class SessionRepository {
  /// Sesión actual y sus cambios; `null` al salir.
  Stream<Session?> watchSession();
}
