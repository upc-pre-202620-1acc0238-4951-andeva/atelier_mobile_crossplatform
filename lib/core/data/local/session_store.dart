import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';

/// Lo mínimo que usan el cliente HTTP y la cola, para probarlos sin plugins.
abstract class SessionStore {
  Future<String?> getAuthToken();

  Future<String?> getRefreshToken();

  Future<int?> getTokenExpiresAt();

  Future<String?> getUserId();

  Future<void> save(AuthenticatedUserDto user);

  Future<void> clear();
}
