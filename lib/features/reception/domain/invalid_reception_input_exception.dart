/// Un dato no cumple `ReceptionValidation`; [field] dice cuál (`taxId`, `plate`, `email`…).
class InvalidReceptionInputException implements Exception {
  final String field;

  const InvalidReceptionInputException(this.field);

  @override
  String toString() => 'InvalidReceptionInputException: $field';
}
