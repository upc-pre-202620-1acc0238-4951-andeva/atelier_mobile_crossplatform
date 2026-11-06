class InvalidTaskInputException implements Exception {
  final String field;

  const InvalidTaskInputException(this.field);

  @override
  String toString() => 'InvalidTaskInputException: $field';
}
