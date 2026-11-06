import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';

class DeviceTokenApi {
  final ApiClient client;

  const DeviceTokenApi({required this.client});

  /// `null` lo borra al cerrar sesión. Responde 204.
  Future<void> register(String? fcmToken) async {
    await client.put(
      '/api/v1/users/me/device-token',
      body: {'fcmToken': fcmToken},
    );
  }
}
