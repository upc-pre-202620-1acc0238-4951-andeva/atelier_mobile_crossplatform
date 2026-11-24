import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';

/// Orden de compra con su ciclo: agregar líneas (`DRAFT`), emitir (`ISSUED`) y anular (`CANCELED`). La recepción
/// con comprobante fotográfico (US34) no está en esta versión.
class PurchaseOrderDetailUiState {
  final PurchaseOrder? order;

  /// Nombre del repuesto por id, desde la caché del catálogo; la línea solo trae el id.
  final Map<String, String> partNames;
  final List<Part> catalogParts;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canRead;
  final bool canCreate;
  final UiText? actionBanner;
  final UiText? actionError;
  final bool isMutating;

  // Hoja agregar línea (DRAFT)
  final bool showAddLineSheet;
  final String partQuery;
  final String? selectedPartId;
  final String lineQuantity;
  final String lineUnitCost;
  final UiText? lineQtyError;
  final UiText? lineCostError;
  final UiText? addLineError;
  final bool isAddingLine;

  // Hoja anular OC (DRAFT o ISSUED)
  final bool showCancelSheet;
  final String cancelReason;
  final UiText? cancelError;
  final bool isCanceling;
  final int hapticEvent;
  final bool hapticIsError;

  const PurchaseOrderDetailUiState({
    this.order,
    this.partNames = const {},
    this.catalogParts = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.error,
    this.canRead = true,
    this.canCreate = false,
    this.actionBanner,
    this.actionError,
    this.isMutating = false,
    this.showAddLineSheet = false,
    this.partQuery = '',
    this.selectedPartId,
    this.lineQuantity = '',
    this.lineUnitCost = '',
    this.lineQtyError,
    this.lineCostError,
    this.addLineError,
    this.isAddingLine = false,
    this.showCancelSheet = false,
    this.cancelReason = '',
    this.cancelError,
    this.isCanceling = false,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  List<Part> get filteredCatalogParts {
    final q = partQuery.trim().toLowerCase();
    final matched = q.isEmpty
        ? [...catalogParts]
        : [
            for (final part in catalogParts)
              if (part.name.toLowerCase().contains(q) || part.sku.toLowerCase().contains(q)) part,
          ];
    matched.sort((a, b) {
      if (a.isOutOfStock != b.isOutOfStock) return a.isOutOfStock ? -1 : 1;
      if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return matched.take(20).toList();
  }

  PurchaseOrderDetailUiState copyWith({
    PurchaseOrder? order,
    Map<String, String>? partNames,
    List<Part>? catalogParts,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canRead,
    bool? canCreate,
    UiText? actionBanner,
    bool clearActionBanner = false,
    UiText? actionError,
    bool clearActionError = false,
    bool? isMutating,
    bool? showAddLineSheet,
    String? partQuery,
    String? selectedPartId,
    bool clearSelectedPart = false,
    String? lineQuantity,
    String? lineUnitCost,
    UiText? lineQtyError,
    UiText? lineCostError,
    bool clearLineErrors = false,
    UiText? addLineError,
    bool clearAddLineError = false,
    bool? isAddingLine,
    bool? showCancelSheet,
    String? cancelReason,
    UiText? cancelError,
    bool clearCancelError = false,
    bool? isCanceling,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return PurchaseOrderDetailUiState(
      order: order ?? this.order,
      partNames: partNames ?? this.partNames,
      catalogParts: catalogParts ?? this.catalogParts,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
      canCreate: canCreate ?? this.canCreate,
      actionBanner: clearActionBanner ? null : actionBanner ?? this.actionBanner,
      actionError: clearActionError ? null : actionError ?? this.actionError,
      isMutating: isMutating ?? this.isMutating,
      showAddLineSheet: showAddLineSheet ?? this.showAddLineSheet,
      partQuery: partQuery ?? this.partQuery,
      selectedPartId: clearSelectedPart ? null : selectedPartId ?? this.selectedPartId,
      lineQuantity: lineQuantity ?? this.lineQuantity,
      lineUnitCost: lineUnitCost ?? this.lineUnitCost,
      lineQtyError: clearLineErrors ? null : lineQtyError ?? this.lineQtyError,
      lineCostError: clearLineErrors ? null : lineCostError ?? this.lineCostError,
      addLineError: clearAddLineError ? null : addLineError ?? this.addLineError,
      isAddingLine: isAddingLine ?? this.isAddingLine,
      showCancelSheet: showCancelSheet ?? this.showCancelSheet,
      cancelReason: cancelReason ?? this.cancelReason,
      cancelError: clearCancelError ? null : cancelError ?? this.cancelError,
      isCanceling: isCanceling ?? this.isCanceling,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
