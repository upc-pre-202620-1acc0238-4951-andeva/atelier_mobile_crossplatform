/// Un dato no cumple `WorkOrderValidation`; [field] dice cuál (`mileageIn`, `photo`, `severity`…).
class InvalidWorkOrderInputException implements Exception {
  final String field;

  const InvalidWorkOrderInputException(this.field);

  @override
  String toString() => 'InvalidWorkOrderInputException: $field';
}
