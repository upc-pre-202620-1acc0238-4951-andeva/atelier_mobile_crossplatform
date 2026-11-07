import 'package:decimal/decimal.dart';

/// Restricciones de los requests de docs/api/operations.md. Solo evitan una llamada inútil; el
/// backend vuelve a validar.
class WorkOrderValidation {
  static const diagnosticMax = 2000;
  static const taskDescriptionMax = 1000;
  static const proposalDescriptionMax = 2000;
  static const reasonMax = 1000;
  static const notesMax = 1000;
  static const photoDescriptionMax = 500;

  static bool isMileage(int value) => value >= 0;

  static bool isOptionalText(String? value, int max) {
    return value == null || value.trim().length <= max;
  }

  static bool isRequiredText(String value, int max) {
    final text = value.trim();
    return text.isNotEmpty && text.length <= max;
  }

  static bool isAmount(Decimal value) => value >= Decimal.zero;

  static bool isOptionalAmount(Decimal? value) {
    return value == null || isAmount(value);
  }
}
