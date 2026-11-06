/// Sin red o sin respuesta del servidor. Equivale al `IOException` de Android.
class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Sin conexión']);

  @override
  String toString() => message;
}
