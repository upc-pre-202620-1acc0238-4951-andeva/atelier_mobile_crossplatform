import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/add_purchase_order_item_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/cancel_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/issue_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// US34 E2: orden de compra con su ciclo: agregar líneas (`DRAFT`), emitir (`ISSUED`) y anular (`CANCELED`).
/// La recepción con comprobante fotográfico (US34) no está en esta versión.
class PurchaseOrderDetailViewModel extends ChangeNotifier {
  final String orderId;
  final ObserveSessionUseCase observeSession;
  final GetPurchaseOrderUseCase getOrder;
  final ObservePartUseCase observePart;
  final ConnectivityObserver connectivity;
  final ObservePartsCatalogUseCase observeCatalog;
  final RefreshPartsCatalogUseCase refreshCatalog;
  final AddPurchaseOrderItemUseCase addPurchaseOrderItem;
  final IssuePurchaseOrderUseCase issuePurchaseOrder;
  final CancelPurchaseOrderUseCase cancelPurchaseOrder;

  PurchaseOrderDetailViewModel({
    required this.orderId,
    required this.observeSession,
    required this.getOrder,
    required this.observePart,
    required this.connectivity,
    required this.observeCatalog,
    required this.refreshCatalog,
    required this.addPurchaseOrderItem,
    required this.issuePurchaseOrder,
    required this.cancelPurchaseOrder,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(
          _state.copyWith(
            canRead: session?.has(Permission.purchaseOrdersRead) ?? false,
            canCreate: session?.has(Permission.purchaseOrdersCreate) ?? false,
          ),
        ),
      ),
    );
    _subscriptions.add(
      observeCatalog.execute().listen((parts) => _update(_state.copyWith(catalogParts: parts))),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  PurchaseOrderDetailUiState _state = const PurchaseOrderDetailUiState();
  PurchaseOrderDetailUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.order == null;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  Future<void> refresh() async {
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final order = await getOrder.execute(orderId);
      _update(_state.copyWith(order: order, isLoading: false));
      await _loadPartNames(order);
    } on Object catch (e) {
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  Future<void> _loadPartNames(PurchaseOrder order) async {
    final names = <String, String>{};
    for (final id in order.lines.map((l) => l.itemId).toSet()) {
      try {
        final part = await observePart.execute(id).first;
        if (part != null) names[id] = part.name;
      } on Object {
        // La línea queda con el nombre genérico.
      }
    }
    _update(_state.copyWith(partNames: names));
  }

  Future<void> onOpenAddLine() async {
    final first = _state.catalogParts.isEmpty ? null : _state.catalogParts.first;
    _update(
      _state.copyWith(
        showAddLineSheet: true,
        partQuery: '',
        selectedPartId: first?.id,
        clearSelectedPart: first == null,
        lineQuantity: '',
        lineUnitCost: first?.basePrice?.amount.toString() ?? '',
        clearLineErrors: true,
        clearAddLineError: true,
      ),
    );
    unawaited(refreshCatalog.execute(force: false).catchError((Object _) {}));
  }

  void onDismissAddLine() {
    if (!_state.showAddLineSheet || _state.isAddingLine) return;
    _update(_state.copyWith(showAddLineSheet: false, clearAddLineError: true));
  }

  void onPartQueryChange(String v) => _update(_state.copyWith(partQuery: v));

  void onSelectPart(Part part) {
    _update(
      _state.copyWith(
        selectedPartId: part.id,
        lineUnitCost: _state.lineUnitCost.trim().isEmpty
            ? part.basePrice?.amount.toString() ?? ''
            : _state.lineUnitCost,
        clearAddLineError: true,
      ),
    );
  }

  void onLineQuantityChange(String v) =>
      _update(_state.copyWith(lineQuantity: v, clearLineErrors: true, clearAddLineError: true));

  void onLineUnitCostChange(String v) =>
      _update(_state.copyWith(lineUnitCost: v, clearLineErrors: true, clearAddLineError: true));

  Future<void> onConfirmAddLine() async {
    final state = _state;
    final itemId = state.selectedPartId;
    if (itemId == null || state.isAddingLine || !state.isOnline) return;
    final qty = parseDecimalInput(state.lineQuantity);
    final cost = parseDecimalInput(state.lineUnitCost);
    final qtyErr = qty == null || !InventoryValidation.isPositiveQty(qty)
        ? UiText.resource((s) => s.invSeg2BatchErrQty)
        : null;
    final costErr = cost == null || !InventoryValidation.isNonNegative(cost)
        ? UiText.resource((s) => s.invSeg2BatchErrCost)
        : null;
    if (qtyErr != null || costErr != null) {
      _update(
        _state.copyWith(
          clearLineErrors: true,
          lineQtyError: qtyErr,
          lineCostError: costErr,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
    _update(_state.copyWith(isAddingLine: true, clearAddLineError: true));
    try {
      final updated = await addPurchaseOrderItem.execute(
        orderId,
        itemId: itemId,
        quantity: qty!,
        unitCost: cost!,
      );
      _update(
        _state.copyWith(
          order: updated,
          isAddingLine: false,
          showAddLineSheet: false,
          actionBanner: UiText.resource((s) => s.invSeg2PoLineAddedOk),
          clearActionError: true,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      await _loadPartNames(updated);
    } on Object catch (e) {
      _update(
        _state.copyWith(
          isAddingLine: false,
          addLineError: toUiText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  Future<void> onIssueOrder() async {
    if (_state.isMutating || !_state.isOnline) return;
    _update(_state.copyWith(isMutating: true, clearActionError: true, clearActionBanner: true));
    try {
      final updated = await issuePurchaseOrder.execute(orderId);
      _update(
        _state.copyWith(
          order: updated,
          isMutating: false,
          actionBanner: UiText.resource((s) => s.invSeg2PoIssuedOk),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
    } on Object catch (e) {
      _update(
        _state.copyWith(
          isMutating: false,
          actionError: toUiText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void onOpenCancel() =>
      _update(_state.copyWith(showCancelSheet: true, cancelReason: '', clearCancelError: true));

  void onDismissCancel() {
    if (!_state.showCancelSheet || _state.isCanceling) return;
    _update(_state.copyWith(showCancelSheet: false, clearCancelError: true));
  }

  void onCancelReasonChange(String v) =>
      _update(_state.copyWith(cancelReason: v, clearCancelError: true));

  Future<void> onConfirmCancel() async {
    final state = _state;
    if (state.isCanceling || !state.isOnline) return;
    _update(_state.copyWith(isCanceling: true, clearCancelError: true));
    try {
      final updated = await cancelPurchaseOrder.execute(orderId, reason: state.cancelReason);
      _update(
        _state.copyWith(
          order: updated,
          isCanceling: false,
          showCancelSheet: false,
          actionBanner: UiText.resource((s) => s.invSeg2PoCanceledOk),
          clearActionError: true,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
    } on Object catch (e) {
      _update(
        _state.copyWith(
          isCanceling: false,
          cancelError: toUiText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void _update(PurchaseOrderDetailUiState state) {
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
