/// Dato que se rechaza antes de llamar al backend; [field] es `name` o `reason`.
class InvalidBayInputException implements Exception {
  final String field;

  const InvalidBayInputException(this.field);

  @override
  String toString() => 'InvalidBayInputException: $field';
}
