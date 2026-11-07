/// Restricciones de docs/api/inventory.md. Solo evitan una llamada inútil; el backend vuelve a validar.
class InventoryValidation {
  static final _sku = RegExp(r'^[A-Z0-9_-]{3,50}$');

  /// El backend pasa el SKU a mayúsculas y responde 400 si no cumple el formato.
  static String normalizeSku(String sku) => sku.trim().toUpperCase();

  static bool isSku(String sku) => _sku.hasMatch(normalizeSku(sku));

  static bool isReceiptNumber(String value) => value.trim().isNotEmpty;

  static bool isReceivedAt(DateTime? value, DateTime now) {
    return value == null || !value.isAfter(now);
  }
}
