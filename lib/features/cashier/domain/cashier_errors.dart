/// Un dato no cumple las reglas de caja; [field] dice cuál: `status`, `lines`, `currency`, `taxId`,
/// `amount`, `transactionReference`, `serie` o `initialCorrelative`. No se llamó al backend.
class InvalidCashierInputException implements Exception {
  final String field;

  const InvalidCashierInputException(this.field);

  @override
  String toString() => 'InvalidCashierInputException: $field';
}

/// La sede no tiene una serie activa del tipo a emitir: llevar a la configuración de series (US42).
class MissingFiscalSeriesException implements Exception {
  const MissingFiscalSeriesException();

  @override
  String toString() => 'MissingFiscalSeriesException';
}

/// El cobro pudo registrarse o no (timeout, 5xx, respuesta ilegible o relectura fallida). No cobrar
/// de nuevo sin mirar antes el historial con `GetVoucherPaymentsUseCase` (H28).
class PaymentOutcomeUnknownException implements Exception {
  final Object cause;

  const PaymentOutcomeUnknownException(this.cause);

  @override
  String toString() => 'PaymentOutcomeUnknownException: $cause';
}
