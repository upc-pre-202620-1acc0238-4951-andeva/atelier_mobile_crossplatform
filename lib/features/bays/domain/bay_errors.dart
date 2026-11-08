/// La bahía destino no está `AVAILABLE` (US40 E2): no se llama al backend.
class BayUnavailableException implements Exception {
  const BayUnavailableException();

  @override
  String toString() => 'BayUnavailableException';
}
