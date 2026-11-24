import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:decimal/decimal.dart';

enum PartDetailSheet { none, editPart, receiveBatch, dispatchFifo, restoreBatch }

/// US32: repuesto con sus lotes en orden FIFO (el más antiguo primero). [nextBatchId] es el lote del que saldrá
/// el próximo descargo: el primero con saldo.
class PartDetailUiState {
  final Part? part;
  final List<PartBatch> batches;
  final bool isLoading;
  final bool isOnline;

  /// La recarga de lotes falló (sin red): se muestran los guardados.
  final bool showingCache;
  final UiText? error;
  final bool canReadBatches;
  final bool canManageParts;
  final bool canReceiveBatch;
  final bool canDispatchFifo;
  final bool canRestoreBatch;
  final bool canOpenPurchaseOrders;
  final UiText? actionBanner;
  final PartDetailSheet activeSheet;
  final bool isSubmitting;
  final UiText? sheetError;

  // Formulario editar repuesto
  final String editName;
  final ItemCategory editCategory;
  final String editBasePrice;
  final String editMinStock;
  final PartStatus editStatus;
  final UiText? editNameError;
  final UiText? editPriceError;
  final UiText? editMinStockError;

  // Formularios de lote FIFO
  final String batchNumber;
  final String batchQuantity;
  final String batchUnitCost;
  final String? selectedBatchId;
  final String restoreReason;
  final UiText? batchNumberError;
  final UiText? batchQtyError;
  final UiText? batchCostError;
  final int hapticEvent;
  final bool hapticIsError;

  const PartDetailUiState({
    this.part,
    this.batches = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.showingCache = false,
    this.error,
    this.canReadBatches = false,
    this.canManageParts = false,
    this.canReceiveBatch = false,
    this.canDispatchFifo = false,
    this.canRestoreBatch = false,
    this.canOpenPurchaseOrders = false,
    this.actionBanner,
    this.activeSheet = PartDetailSheet.none,
    this.isSubmitting = false,
    this.sheetError,
    this.editName = '',
    this.editCategory = ItemCategory.lubricants,
    this.editBasePrice = '',
    this.editMinStock = '',
    this.editStatus = PartStatus.active,
    this.editNameError,
    this.editPriceError,
    this.editMinStockError,
    this.batchNumber = '',
    this.batchQuantity = '',
    this.batchUnitCost = '',
    this.selectedBatchId,
    this.restoreReason = '',
    this.batchNumberError,
    this.batchQtyError,
    this.batchCostError,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  String? get nextBatchId {
    for (final batch in batches) {
      if (batch.isActive) return batch.id;
    }
    return null;
  }

  /// Existencias que suman los lotes con saldo.
  Decimal get batchesRemaining => batches
      .where((b) => b.isActive)
      .fold(Decimal.zero, (sum, batch) => sum + batch.remainingQty);

  bool get hasAnyBatchAction => canReceiveBatch || canDispatchFifo || canRestoreBatch;

  PartDetailUiState copyWith({
    Part? part,
    List<PartBatch>? batches,
    bool? isLoading,
    bool? isOnline,
    bool? showingCache,
    UiText? error,
    bool clearError = false,
    bool? canReadBatches,
    bool? canManageParts,
    bool? canReceiveBatch,
    bool? canDispatchFifo,
    bool? canRestoreBatch,
    bool? canOpenPurchaseOrders,
    UiText? actionBanner,
    PartDetailSheet? activeSheet,
    bool? isSubmitting,
    UiText? sheetError,
    bool clearSheetError = false,
    String? editName,
    ItemCategory? editCategory,
    String? editBasePrice,
    String? editMinStock,
    PartStatus? editStatus,
    UiText? editNameError,
    UiText? editPriceError,
    UiText? editMinStockError,
    bool clearEditErrors = false,
    String? batchNumber,
    String? batchQuantity,
    String? batchUnitCost,
    String? selectedBatchId,
    bool clearSelectedBatch = false,
    String? restoreReason,
    UiText? batchNumberError,
    UiText? batchQtyError,
    UiText? batchCostError,
    bool clearBatchErrors = false,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return PartDetailUiState(
      part: part ?? this.part,
      batches: batches ?? this.batches,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      showingCache: showingCache ?? this.showingCache,
      error: clearError ? null : error ?? this.error,
      canReadBatches: canReadBatches ?? this.canReadBatches,
      canManageParts: canManageParts ?? this.canManageParts,
      canReceiveBatch: canReceiveBatch ?? this.canReceiveBatch,
      canDispatchFifo: canDispatchFifo ?? this.canDispatchFifo,
      canRestoreBatch: canRestoreBatch ?? this.canRestoreBatch,
      canOpenPurchaseOrders: canOpenPurchaseOrders ?? this.canOpenPurchaseOrders,
      actionBanner: actionBanner ?? this.actionBanner,
      activeSheet: activeSheet ?? this.activeSheet,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sheetError: clearSheetError ? null : sheetError ?? this.sheetError,
      editName: editName ?? this.editName,
      editCategory: editCategory ?? this.editCategory,
      editBasePrice: editBasePrice ?? this.editBasePrice,
      editMinStock: editMinStock ?? this.editMinStock,
      editStatus: editStatus ?? this.editStatus,
      editNameError: clearEditErrors ? null : editNameError ?? this.editNameError,
      editPriceError: clearEditErrors ? null : editPriceError ?? this.editPriceError,
      editMinStockError: clearEditErrors ? null : editMinStockError ?? this.editMinStockError,
      batchNumber: batchNumber ?? this.batchNumber,
      batchQuantity: batchQuantity ?? this.batchQuantity,
      batchUnitCost: batchUnitCost ?? this.batchUnitCost,
      selectedBatchId: clearSelectedBatch ? null : selectedBatchId ?? this.selectedBatchId,
      restoreReason: restoreReason ?? this.restoreReason,
      batchNumberError: clearBatchErrors ? null : batchNumberError ?? this.batchNumberError,
      batchQtyError: clearBatchErrors ? null : batchQtyError ?? this.batchQtyError,
      batchCostError: clearBatchErrors ? null : batchCostError ?? this.batchCostError,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
