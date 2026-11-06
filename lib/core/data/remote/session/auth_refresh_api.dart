import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';

/// El refresh lo maneja TokenRefresher; aquí queda el cierre de sesión.
class AuthRefreshApi {
  final ApiClient client;

  const AuthRefreshApi({required this.client});

  Future<void> signOut(String refreshToken) async {
    await client.post(
      '/api/v1/auth/sign-out',
      body: {'refreshToken': refreshToken},
    );
  }
}
