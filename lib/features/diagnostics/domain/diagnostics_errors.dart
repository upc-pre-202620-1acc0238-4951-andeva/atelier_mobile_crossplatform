/// Falta el permiso de Bluetooth: pedirlo con su explicación es de la UI
/// (`RequestBluetoothPermissionUseCase`).
class BluetoothPermissionDeniedException implements Exception {
  const BluetoothPermissionDeniedException();

  @override
  String toString() => 'BluetoothPermissionDeniedException';
}

/// El teléfono no tiene Bluetooth o está apagado.
class BluetoothDisabledException implements Exception {
  const BluetoothDisabledException();

  @override
  String toString() => 'BluetoothDisabledException';
}

/// No se pudo abrir el canal con el ELM327: apagado, fuera de alcance o sin alimentación (US16 E2).
class ObdAdapterUnreachableException implements Exception {
  const ObdAdapterUnreachableException();

  @override
  String toString() => 'ObdAdapterUnreachableException';
}

/// El adaptador responde pero la computadora del vehículo no (US16 E2): contacto apagado o caída de
/// tensión en el conector. La UI orienta a revisar la alimentación y la posición del interruptor.
class ObdNoResponseException implements Exception {
  const ObdNoResponseException();

  @override
  String toString() => 'ObdNoResponseException';
}

/// Se cortó la comunicación con el adaptador a mitad de la sesión.
class ObdConnectionLostException implements Exception {
  const ObdConnectionLostException();

  @override
  String toString() => 'ObdConnectionLostException';
}

/// La acción necesita una sesión de diagnóstico conectada.
class ObdNotConnectedException implements Exception {
  const ObdNotConnectedException();

  @override
  String toString() => 'ObdNotConnectedException';
}

/// `POST /iot/health-reports/generate` respondió 422 (US21 E3): ampliar la ventana o escanear en bahía.
/// [message] es el del backend.
class InsufficientTelemetryException implements Exception {
  final String message;

  const InsufficientTelemetryException(this.message);

  @override
  String toString() => 'InsufficientTelemetryException: $message';
}

/// Un dato no cumple `DiagnosticsValidation`; [field] dice cuál (`daysToAnalyze`, `odometerKm`…).
class InvalidDiagnosticsInputException implements Exception {
  final String field;

  const InvalidDiagnosticsInputException(this.field);

  @override
  String toString() => 'InvalidDiagnosticsInputException: $field';
}
