import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';
import 'package:decimal/decimal.dart';

/// Cantidad sugerida para reponer: lo que falta para llegar al doble del mínimo, redondeado hacia arriba (mín. 1).
Decimal suggestedReplenishmentQty(Part part) {
  if (!part.isLowStock) return Decimal.one;
  final target = part.minimumStock * Decimal.fromInt(2);
  final needed = (target - part.totalStock).ceil();
  return needed > Decimal.one ? needed : Decimal.one;
}

/// Un decimal sin ceros sobrantes ni notación científica (`stripTrailingZeros().toPlainString()`).
String plainQuantity(Decimal value) {
  final text = value.toString();
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

class PurchaseOrdersUiState {
  final List<PurchaseOrder> orders;

  /// `null` = todas. Por defecto las emitidas: las que se pueden recibir.
  final PurchaseOrderStatus? status;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canRead;
  final bool canCreate;
  final bool createSheetOpen;
  final List<Supplier> suppliers;
  final bool isLoadingSuppliers;
  final UiText? suppliersError;
  final String? selectedSupplierId;
  final List<Part> catalogParts;
  final String partQuery;
  final bool lowStockOnly;
  final String? selectedPartId;
  final String lineQuantity;
  final String lineUnitCost;
  final UiText? lineQtyError;
  final UiText? lineCostError;
  final String orderNumber;
  final String notes;
  final bool isCreating;
  final UiText? createError;
  final String? createdOrderId;
  final int hapticEvent;
  final bool hapticIsError;

  const PurchaseOrdersUiState({
    this.orders = const [],
    this.status = PurchaseOrderStatus.issued,
    this.isLoading = true,
    this.isOnline = true,
    this.error,
    this.canRead = true,
    this.canCreate = false,
    this.createSheetOpen = false,
    this.suppliers = const [],
    this.isLoadingSuppliers = false,
    this.suppliersError,
    this.selectedSupplierId,
    this.catalogParts = const [],
    this.partQuery = '',
    this.lowStockOnly = false,
    this.selectedPartId,
    this.lineQuantity = '1',
    this.lineUnitCost = '',
    this.lineQtyError,
    this.lineCostError,
    this.orderNumber = '',
    this.notes = '',
    this.isCreating = false,
    this.createError,
    this.createdOrderId,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  /// En o debajo del mínimo y vigentes; primero los agotados, luego los de menos existencias.
  List<Part> get lowStockParts {
    final list = [
      for (final part in catalogParts)
        if (part.isLowStock &&
            part.status != PartStatus.discontinued &&
            part.status != PartStatus.inactive)
          part,
    ];
    list.sort((a, b) {
      if (a.isOutOfStock != b.isOutOfStock) return a.isOutOfStock ? -1 : 1;
      final byStock = a.totalStock.compareTo(b.totalStock);
      if (byStock != 0) return byStock;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return list;
  }

  List<Part> get filteredCatalogParts {
    final base = lowStockOnly ? lowStockParts : catalogParts;
    final q = partQuery.trim().toLowerCase();
    final matched = q.isEmpty
        ? [...base]
        : [
            for (final part in base)
              if (part.name.toLowerCase().contains(q) || part.sku.toLowerCase().contains(q)) part,
          ];
    matched.sort((a, b) {
      if (a.isOutOfStock != b.isOutOfStock) return a.isOutOfStock ? -1 : 1;
      if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matched.take(20).toList();
  }

  PurchaseOrdersUiState copyWith({
    List<PurchaseOrder>? orders,
    PurchaseOrderStatus? status,
    bool setStatus = false,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canRead,
    bool? canCreate,
    bool? createSheetOpen,
    List<Supplier>? suppliers,
    bool? isLoadingSuppliers,
    UiText? suppliersError,
    bool clearSuppliersError = false,
    String? selectedSupplierId,
    bool clearSelectedSupplier = false,
    List<Part>? catalogParts,
    String? partQuery,
    bool? lowStockOnly,
    String? selectedPartId,
    bool clearSelectedPart = false,
    String? lineQuantity,
    String? lineUnitCost,
    UiText? lineQtyError,
    UiText? lineCostError,
    bool clearLineErrors = false,
    String? orderNumber,
    String? notes,
    bool? isCreating,
    UiText? createError,
    bool clearCreateError = false,
    String? createdOrderId,
    bool clearCreatedOrder = false,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return PurchaseOrdersUiState(
      orders: orders ?? this.orders,
      status: setStatus ? status : this.status,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
      canCreate: canCreate ?? this.canCreate,
      createSheetOpen: createSheetOpen ?? this.createSheetOpen,
      suppliers: suppliers ?? this.suppliers,
      isLoadingSuppliers: isLoadingSuppliers ?? this.isLoadingSuppliers,
      suppliersError: clearSuppliersError ? null : suppliersError ?? this.suppliersError,
      selectedSupplierId: clearSelectedSupplier ? null : selectedSupplierId ?? this.selectedSupplierId,
      catalogParts: catalogParts ?? this.catalogParts,
      partQuery: partQuery ?? this.partQuery,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      selectedPartId: clearSelectedPart ? null : selectedPartId ?? this.selectedPartId,
      lineQuantity: lineQuantity ?? this.lineQuantity,
      lineUnitCost: lineUnitCost ?? this.lineUnitCost,
      lineQtyError: clearLineErrors ? null : lineQtyError ?? this.lineQtyError,
      lineCostError: clearLineErrors ? null : lineCostError ?? this.lineCostError,
      orderNumber: orderNumber ?? this.orderNumber,
      notes: notes ?? this.notes,
      isCreating: isCreating ?? this.isCreating,
      createError: clearCreateError ? null : createError ?? this.createError,
      createdOrderId: clearCreatedOrder ? null : createdOrderId ?? this.createdOrderId,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
