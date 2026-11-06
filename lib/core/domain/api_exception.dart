/// Error del backend con el formato único `{ code, message, details }` (docs/api/README.md §5).
/// `message` ya viene traducido y se muestra tal cual; el flujo se decide por [httpStatus].
class ApiException implements Exception {
  final int httpStatus;
  final String code;
  final String message;
  final List<String> details;

  const ApiException({
    required this.httpStatus,
    required this.code,
    required this.message,
    this.details = const [],
  });

  @override
  String toString() => message;
}
