import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// `ItemCategory` de docs/api/README.md §8.
enum ItemCategory {
  lubricants('LUBRICANTS'),
  brakes('BRAKES'),
  suspension('SUSPENSION'),
  engine('ENGINE'),
  electrical('ELECTRICAL'),
  tires('TIRES'),
  filters('FILTERS'),
  bodywork('BODYWORK'),
  accessories('ACCESSORIES');

  final String value;
  const ItemCategory(this.value);

  static ItemCategory? fromString(String? raw) {
    for (final category in values) {
      if (category.value == raw) return category;
    }
    return null;
  }
}

/// `InventoryItemStatus` del backend.
enum PartStatus {
  active('ACTIVE'),
  inactive('INACTIVE'),
  discontinued('DISCONTINUED');

  final String value;
  const PartStatus(this.value);

  static PartStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// Repuesto del catálogo (`PartResource`, US31). [basePrice] es el precio de venta sin IGV.
/// [unitOfMeasure] vale siempre "UNIT" (H12).
class Part {
  final String id;
  final String name;
  final String sku;
  final ItemCategory? category;
  final Money? basePrice;
  final Decimal totalStock;
  final Decimal minimumStock;
  final String? unitOfMeasure;
  final PartStatus? status;

  const Part({
    required this.id,
    required this.name,
    required this.sku,
    this.category,
    this.basePrice,
    required this.totalStock,
    required this.minimumStock,
    this.unitOfMeasure,
    this.status,
  });

  /// Existencia agotada (US31 E2): la UI la resalta y bloquea su selección.
  bool get isOutOfStock => totalStock <= Decimal.zero;

  /// Misma regla que `GET /inventory/alerts`: en el mínimo o debajo (US34 E1).
  bool get isLowStock => totalStock <= minimumStock;

  /// Se puede elegir para una tarea: activo y con saldo.
  bool get isSelectable {
    return status != PartStatus.inactive &&
        status != PartStatus.discontinued &&
        !isOutOfStock;
  }

  /// Alerta derivada de la caché con la misma regla del backend (H13).
  StockAlert toStockAlert() {
    final missing = minimumStock - totalStock;
    return StockAlert(
      itemId: id,
      name: name,
      sku: sku,
      category: category,
      currentStock: totalStock,
      minimumStock: minimumStock,
      deficit: missing > Decimal.zero ? missing : Decimal.zero,
    );
  }
}

/// Lote de compra (`BatchResource`, US32). [initialQty], [supplierId], [purchaseOrderId] y
/// [receiptImageUrl] solo llegan en línea: la caché `batches` no los guarda.
class PartBatch {
  final String id;
  final String itemId;
  final String batchNumber;
  final Decimal remainingQty;
  final Money? unitCost;
  final DateTime? arrivalDate;
  final Decimal? initialQty;
  final String? supplierId;
  final String? purchaseOrderId;
  final String? receiptImageUrl;

  const PartBatch({
    required this.id,
    required this.itemId,
    required this.batchNumber,
    required this.remainingQty,
    this.unitCost,
    this.arrivalDate,
    this.initialQty,
    this.supplierId,
    this.purchaseOrderId,
    this.receiptImageUrl,
  });

  /// Con saldo: de estos sale el próximo descargo FIFO.
  bool get isActive => remainingQty > Decimal.zero;
}

/// Detalle del repuesto con sus lotes en orden FIFO (el más antiguo primero).
class PartDetail {
  final Part part;
  final List<PartBatch> batches;

  const PartDetail({required this.part, required this.batches});
}

/// Repuesto en el mínimo o debajo (`StockAlertResource`, US34). [deficit] es lo que falta para el
/// mínimo.
class StockAlert {
  final String itemId;
  final String name;
  final String sku;
  final ItemCategory? category;
  final Decimal currentStock;
  final Decimal minimumStock;
  final Decimal deficit;

  const StockAlert({
    required this.itemId,
    required this.name,
    required this.sku,
    this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.deficit,
  });
}
