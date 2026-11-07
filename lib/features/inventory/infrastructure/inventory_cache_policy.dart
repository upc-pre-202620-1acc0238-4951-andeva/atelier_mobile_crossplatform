/// Vigencia de las cachés del inventario (06 §4).
class InventoryCachePolicy {
  static const catalogScope = 'parts:catalog';
  static const ttl = Duration(hours: 1);
  static const pageSize = 100;

  /// shortcut: más de 5000 repuestos dejarían la caché truncada sin aviso; subirlo si un taller llega.
  static const maxPages = 50;

  static String batchesScope(String itemId) => 'batches:$itemId';
}
