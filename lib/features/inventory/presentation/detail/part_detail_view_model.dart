import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/dispatch_fifo_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_direct_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/restore_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// US32 E1: ficha del repuesto, lotes FIFO, edición (`PARTS_MANAGE`) y operaciones directas de lote
/// (`BATCHES_RECEIVE`, `BATCHES_DISPATCH_FIFO`, `BATCHES_RESTORE`).
class PartDetailViewModel extends ChangeNotifier {
  final String partId;
  final ObserveSessionUseCase observeSession;
  final ObservePartUseCase observePart;
  final ObservePartBatchesUseCase observeBatches;
  final RefreshPartBatchesUseCase refreshBatches;
  final ConnectivityObserver connectivity;
  final UpdatePartUseCase updatePart;
  final ReceiveDirectBatchUseCase receiveDirectBatch;
  final DispatchFifoBatchUseCase dispatchFifoBatch;
  final RestoreBatchUseCase restoreBatch;

  PartDetailViewModel({
    required this.partId,
    required this.observeSession,
    required this.observePart,
    required this.observeBatches,
    required this.refreshBatches,
    required this.connectivity,
    required this.updatePart,
    required this.receiveDirectBatch,
    required this.dispatchFifoBatch,
    required this.restoreBatch,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(
          _state.copyWith(
            canReadBatches: session?.has(Permission.batchesRead) ?? false,
            canManageParts: session?.has(Permission.partsManage) ?? false,
            canReceiveBatch: session?.has(Permission.batchesReceive) ?? false,
            canDispatchFifo: session?.has(Permission.batchesDispatchFifo) ?? false,
            canRestoreBatch: session?.has(Permission.batchesRestore) ?? false,
            canOpenPurchaseOrders:
                (session?.has(Permission.purchaseOrdersRead) ?? false) ||
                (session?.has(Permission.purchaseOrdersCreate) ?? false),
          ),
        ),
      ),
    );
    _subscriptions.add(
      observePart.execute(partId).listen((part) {
        if (part != null) _update(_state.copyWith(part: part));
      }),
    );
    _subscriptions.add(
      observeBatches.execute(partId).listen((batches) {
        // Orden FIFO defensivo: del más antiguo al más nuevo; sin fecha al final.
        final fifo = [...batches]
          ..sort((a, b) {
            final x = a.arrivalDate;
            final y = b.arrivalDate;
            if (x == null && y == null) return 0;
            if (x == null) return 1;
            if (y == null) return -1;
            return x.compareTo(y);
          });
        _update(_state.copyWith(batches: fifo));
      }),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  PartDetailUiState _state = const PartDetailUiState();
  PartDetailUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  /// D2: al volver la red tras una recarga fallida, se actualiza sola y el aviso se quita.
  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && _state.showingCache;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  /// Recarga los lotes; sin red se siguen mostrando los guardados.
  Future<void> refresh({bool force = false}) async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      await refreshBatches.execute(partId, force: force);
      _update(_state.copyWith(isLoading: false, showingCache: false));
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, showingCache: true, error: toUiText(e)));
    }
  }

  void onOpenEditPart() {
    final part = _state.part;
    if (part == null) return;
    _update(
      _state.copyWith(
        activeSheet: PartDetailSheet.editPart,
        editName: part.name,
        editCategory: part.category ?? ItemCategory.lubricants,
        editBasePrice: part.basePrice?.amount.toString() ?? '',
        editMinStock: part.minimumStock.formatQuantity(),
        editStatus: part.status ?? PartStatus.active,
        clearEditErrors: true,
        clearSheetError: true,
      ),
    );
  }

  void onOpenReceiveBatch() {
    _update(
      _state.copyWith(
        activeSheet: PartDetailSheet.receiveBatch,
        batchNumber: '',
        batchQuantity: '',
        batchUnitCost: '',
        clearBatchErrors: true,
        clearSheetError: true,
      ),
    );
  }

  void onOpenDispatchFifo() {
    _update(
      _state.copyWith(
        activeSheet: PartDetailSheet.dispatchFifo,
        batchQuantity: '',
        clearBatchErrors: true,
        clearSheetError: true,
      ),
    );
  }

  void onOpenRestoreBatch() {
    _update(
      _state.copyWith(
        activeSheet: PartDetailSheet.restoreBatch,
        batchQuantity: '',
        clearSelectedBatch: true,
        restoreReason: '',
        clearBatchErrors: true,
        clearSheetError: true,
      ),
    );
  }

  void onDismissSheet() {
    if (_state.activeSheet == PartDetailSheet.none || _state.isSubmitting) return;
    _update(_state.copyWith(activeSheet: PartDetailSheet.none, clearSheetError: true));
  }

  void onEditNameChange(String v) =>
      _update(_state.copyWith(editName: v, clearEditErrors: true, clearSheetError: true));
  void onEditCategoryChange(ItemCategory v) =>
      _update(_state.copyWith(editCategory: v, clearSheetError: true));
  void onEditBasePriceChange(String v) =>
      _update(_state.copyWith(editBasePrice: v, clearEditErrors: true, clearSheetError: true));
  void onEditMinStockChange(String v) =>
      _update(_state.copyWith(editMinStock: v, clearEditErrors: true, clearSheetError: true));
  void onEditStatusChange(PartStatus v) =>
      _update(_state.copyWith(editStatus: v, clearSheetError: true));

  void onBatchNumberChange(String v) =>
      _update(_state.copyWith(batchNumber: v, clearBatchErrors: true, clearSheetError: true));
  void onBatchQuantityChange(String v) =>
      _update(_state.copyWith(batchQuantity: v, clearBatchErrors: true, clearSheetError: true));
  void onBatchUnitCostChange(String v) =>
      _update(_state.copyWith(batchUnitCost: v, clearBatchErrors: true, clearSheetError: true));
  void onSelectedBatchIdChange(String? v) => _update(
    _state.copyWith(selectedBatchId: v, clearSelectedBatch: v == null, clearSheetError: true),
  );
  void onRestoreReasonChange(String v) =>
      _update(_state.copyWith(restoreReason: v, clearSheetError: true));

  Future<void> onConfirmEditPart() async {
    final state = _state;
    final part = state.part;
    if (part == null || state.isSubmitting || !state.isOnline) return;
    final price = parseDecimalInput(state.editBasePrice);
    final minStock = parseDecimalInput(state.editMinStock);
    final nameErr = !InventoryValidation.isNonEmptyText(state.editName)
        ? UiText.resource((s) => s.invSeg2PartErrName)
        : null;
    final priceErr = price == null || !InventoryValidation.isNonNegative(price)
        ? UiText.resource((s) => s.invSeg2PartErrPrice)
        : null;
    final minErr = minStock == null || !InventoryValidation.isNonNegative(minStock)
        ? UiText.resource((s) => s.invSeg2PartErrMinStock)
        : null;
    if (nameErr != null || priceErr != null || minErr != null) {
      _update(
        _state.copyWith(
          clearEditErrors: true,
          editNameError: nameErr,
          editPriceError: priceErr,
          editMinStockError: minErr,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearSheetError: true));
    try {
      await updatePart.execute(
        part.id,
        name: state.editName,
        category: state.editCategory,
        basePrice: price!,
        minimumStock: minStock!,
        status: state.editStatus,
        unitOfMeasure: part.unitOfMeasure,
      );
      _succeed(UiText.resource((s) => s.invSeg2PartSaved));
    } on Object catch (e) {
      _fail(e);
    }
  }

  Future<void> onConfirmReceiveBatch() async {
    final state = _state;
    if (state.isSubmitting || !state.isOnline) return;
    final qty = parseDecimalInput(state.batchQuantity);
    final cost = parseDecimalInput(state.batchUnitCost);
    final numErr = !InventoryValidation.isNonEmptyText(state.batchNumber)
        ? UiText.resource((s) => s.invSeg2BatchErrNumber)
        : null;
    final qtyErr = qty == null || !InventoryValidation.isPositiveQty(qty)
        ? UiText.resource((s) => s.invSeg2BatchErrQty)
        : null;
    final costErr = cost == null || !InventoryValidation.isNonNegative(cost)
        ? UiText.resource((s) => s.invSeg2BatchErrCost)
        : null;
    if (numErr != null || qtyErr != null || costErr != null) {
      _update(
        _state.copyWith(
          clearBatchErrors: true,
          batchNumberError: numErr,
          batchQtyError: qtyErr,
          batchCostError: costErr,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearSheetError: true));
    try {
      await receiveDirectBatch.execute(
        partId,
        batchNumber: state.batchNumber,
        quantity: qty!,
        unitCost: cost!,
      );
      _succeed(UiText.resource((s) => s.invSeg2BatchReceivedOk));
    } on Object catch (e) {
      _fail(e);
    }
  }

  Future<void> onConfirmDispatchFifo() async {
    final state = _state;
    if (state.isSubmitting || !state.isOnline) return;
    final qty = parseDecimalInput(state.batchQuantity);
    if (qty == null || !InventoryValidation.isPositiveQty(qty)) {
      _update(
        _state.copyWith(
          clearBatchErrors: true,
          batchQtyError: UiText.resource((s) => s.invSeg2BatchErrQty),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearSheetError: true));
    try {
      final allocation = await dispatchFifoBatch.execute(partId, quantity: qty);
      final dispatched = allocation.allocatedQuantity.formatQuantity();
      _succeed(UiText.resource((s) => s.invSeg2BatchDispatchedOk(dispatched)));
    } on Object catch (e) {
      _fail(e);
    }
  }

  Future<void> onConfirmRestoreBatch() async {
    final state = _state;
    if (state.isSubmitting || !state.isOnline) return;
    final qty = parseDecimalInput(state.batchQuantity);
    if (qty == null || !InventoryValidation.isPositiveQty(qty)) {
      _update(
        _state.copyWith(
          clearBatchErrors: true,
          batchQtyError: UiText.resource((s) => s.invSeg2BatchErrQty),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearSheetError: true));
    try {
      final result = await restoreBatch.execute(
        partId,
        quantity: qty,
        batchId: state.selectedBatchId ?? (state.batches.isEmpty ? null : state.batches.last.id),
        reason: state.restoreReason,
      );
      final restored = result.restoredQuantity.formatQuantity();
      _succeed(UiText.resource((s) => s.invSeg2BatchRestoredOk(restored)));
    } on Object catch (e) {
      _fail(e);
    }
  }

  void _succeed(UiText banner) {
    _update(
      _state.copyWith(
        isSubmitting: false,
        activeSheet: PartDetailSheet.none,
        actionBanner: banner,
        hapticEvent: _state.hapticEvent + 1,
        hapticIsError: false,
      ),
    );
  }

  void _fail(Object e) {
    _update(
      _state.copyWith(
        isSubmitting: false,
        sheetError: toUiText(e),
        hapticEvent: _state.hapticEvent + 1,
        hapticIsError: true,
      ),
    );
  }

  void _update(PartDetailUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
