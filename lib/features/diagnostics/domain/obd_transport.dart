/// El protocolo ELM327 (comandos AT y modos OBD-II) es el mismo sobre SPP o BLE (04 §4).
abstract class ObdTransport {
  /// Lo que manda el adaptador, en trozos sin relación con los comandos. Termina o falla si se cae el
  /// canal.
  Stream<String> get incoming;

  /// Lanza `BluetoothPermissionDeniedException`, `BluetoothDisabledException`,
  /// `ObdAdapterUnreachableException` o `InvalidDiagnosticsInputException('address')`.
  Future<void> connect(String address);

  /// Lanza `ObdConnectionLostException` si el canal ya no sirve.
  Future<void> send(String command);

  Future<void> disconnect();
}
