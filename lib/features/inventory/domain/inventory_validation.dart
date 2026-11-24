import 'package:decimal/decimal.dart';

/// Restricciones de docs/api/inventory.md. Solo evitan una llamada inútil; el backend vuelve a validar.
class InventoryValidation {
  static final _sku = RegExp(r'^[A-Z0-9_-]{3,50}$');
  static final _taxId = RegExp(r'^\d{8,20}$');
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _minPositiveQty = Decimal.parse('0.01');

  /// El backend pasa el SKU a mayúsculas y responde 400 si no cumple el formato.
  static String normalizeSku(String sku) => sku.trim().toUpperCase();

  static bool isSku(String sku) => _sku.hasMatch(normalizeSku(sku));

  static bool isReceiptNumber(String value) => value.trim().isNotEmpty;

  static bool isReceivedAt(DateTime? value, DateTime now) {
    return value == null || !value.isAfter(now);
  }

  static bool isNonEmptyText(String value) => value.trim().isNotEmpty;

  static bool isNonNegative(Decimal value) => value >= Decimal.zero;

  static bool isPositiveQty(Decimal value) => value >= _minPositiveQty;

  static String normalizeTaxId(String value) => value.trim();

  static bool isTaxId(String value) => _taxId.hasMatch(normalizeTaxId(value));

  static bool isOptionalEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty || _email.hasMatch(trimmed);
  }
}
