import 'package:atelier_mobile_crossplatform/core/data/remote/session/device_token_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Token FCM del dispositivo (docs/04-mobile-integration.md §2): tras iniciar sesión se registra;
/// al cerrarla se borra antes de `sign-out`.
class DeviceTokenRegistrar {
  final DeviceTokenApi api;

  const DeviceTokenRegistrar({required this.api});

  /// Lo llama el login. Sin `google-services.json` Firebase no se inicializa y no se registra nada.
  Future<void> registerCurrentToken() async {
    if (Firebase.apps.isEmpty) return;
    final String? token;
    try {
      // `register()` entrega un FID y el backend espera un token de registro (04 §2).
      // ignore: deprecated_member_use
      token = await FirebaseMessaging.instance.getToken();
    } on FirebaseException {
      return; // Sin Google Play o sin red: no debe impedir el login. Se reintenta en el siguiente.
    }
    if (token != null) await register(token);
  }

  Future<void> register(String fcmToken) => api.register(fcmToken);

  Future<void> clear() => api.register(null);
}
