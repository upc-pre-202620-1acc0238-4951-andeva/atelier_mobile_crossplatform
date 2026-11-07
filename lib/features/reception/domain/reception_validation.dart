/// Restricciones de los requests de docs/api/crm.md. Solo evitan una llamada inútil; el backend
/// vuelve a validar.
class ReceptionValidation {
  static const nameMax = 100;
  static const companyNameMax = 150;
  static const taxIdMax = 20;
  static const personTaxIdMin = 8;
  static const companyTaxIdMin = 11;
  static const emailMax = 150;
  static const phoneMax = 20;
  static const plateMax = 15;
  static const brandModelMax = 50;
  static const vinMax = 17;
  static const yearMin = 1950;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// La placa se busca y se guarda en mayúsculas y sin espacios.
  static String normalizePlate(String plate) {
    return plate.replaceAll(RegExp(r'\s'), '').toUpperCase();
  }

  static bool isPlate(String plate) {
    final normalized = normalizePlate(plate);
    return normalized.isNotEmpty && normalized.length <= plateMax;
  }

  static bool isName(String value) => _isRequired(value, nameMax);

  static bool isCompanyName(String value) {
    return _isRequired(value, companyNameMax);
  }

  static bool isPersonTaxId(String value) {
    final length = value.trim().length;
    return length >= personTaxIdMin && length <= taxIdMax;
  }

  static bool isCompanyTaxId(String value) {
    final length = value.trim().length;
    return length >= companyTaxIdMin && length <= taxIdMax;
  }

  static bool isEmail(String value) {
    final email = value.trim();
    return email.length <= emailMax && _email.hasMatch(email);
  }

  static bool isOptionalEmail(String? value) {
    return value == null || value.trim().isEmpty || isEmail(value);
  }

  static bool isOptionalPhone(String? value) {
    return value == null || value.trim().length <= phoneMax;
  }

  static bool isBrandOrModel(String value) {
    return _isRequired(value, brandModelMax);
  }

  static bool isOptionalVin(String? value) {
    return value == null || value.trim().length <= vinMax;
  }

  static bool isOptionalYear(int? value) {
    return value == null || value >= yearMin;
  }

  static bool _isRequired(String value, int max) {
    final text = value.trim();
    return text.isNotEmpty && text.length <= max;
  }
}
