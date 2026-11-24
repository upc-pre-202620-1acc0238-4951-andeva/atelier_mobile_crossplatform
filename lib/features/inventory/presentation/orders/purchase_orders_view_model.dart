import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_suppliers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

/// US34 E2: órdenes de compra por estado + alta de borrador (`PURCHASE_ORDERS_CREATE`). En línea (06 §2).
/// La recepción de la orden (US34) no está en esta versión.
class PurchaseOrdersViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final GetPurchaseOrdersUseCase getOrders;
  final GetSuppliersUseCase getSuppliers;
  final CreatePurchaseOrderUseCase createPurchaseOrder;
  final ConnectivityObserver connectivity;
  final ObservePartsCatalogUseCase observeCatalog;
  final RefreshPartsCatalogUseCase refreshCatalog;

  PurchaseOrdersViewModel({
    required this.observeSession,
    required this.getOrders,
    required this.getSuppliers,
    required this.createPurchaseOrder,
    required this.connectivity,
    required this.observeCatalog,
    required this.refreshCatalog,
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
      observeCatalog.execute().listen((parts) {
        final state = _state;
        final selected = state.selectedPartId;
        Part? nextPart;
        if (selected != null) {
          for (final part in parts) {
            if (part.id == selected) nextPart = part;
          }
        }
        nextPart ??= parts.isEmpty ? null : parts.first;
        _update(
          state.copyWith(
            catalogParts: parts,
            selectedPartId: nextPart?.id,
            clearSelectedPart: nextPart == null,
            lineUnitCost: state.lineUnitCost.trim().isEmpty
                ? nextPart?.basePrice?.amount.toString() ?? ''
                : state.lineUnitCost,
          ),
        );
      }),
    );
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  PurchaseOrdersUiState _state = const PurchaseOrdersUiState();
  PurchaseOrdersUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  int _loadToken = 0;
  bool _disposed = false;

  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && !_state.isOnline && _state.error != null;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  void onStatusClick(PurchaseOrderStatus? status) {
    if (status == _state.status) return;
    _update(_state.copyWith(status: status, setStatus: true, orders: const []));
    refresh();
  }

  Future<void> refresh() async {
    final token = ++_loadToken;
    final status = _state.status;
    _update(_state.copyWith(isLoading: true, clearError: true));
    try {
      final orders = await getOrders.execute(status: status);
      if (token != _loadToken) return;
      _update(_state.copyWith(orders: orders, isLoading: false));
    } on Object catch (e) {
      if (token != _loadToken) return;
      _update(_state.copyWith(isLoading: false, error: toUiText(e)));
    }
  }

  Future<void> onOpenCreateSheet() async {
    final state = _state;
    final firstPart = state.filteredCatalogParts.isNotEmpty
        ? state.filteredCatalogParts.first
        : state.catalogParts.isNotEmpty
        ? state.catalogParts.first
        : null;
    _update(
      state.copyWith(
        createSheetOpen: true,
        clearSelectedSupplier: true,
        partQuery: '',
        lowStockOnly: false,
        selectedPartId: firstPart?.id,
        clearSelectedPart: firstPart == null,
        lineQuantity: firstPart == null ? '1' : plainQuantity(suggestedReplenishmentQty(firstPart)),
        lineUnitCost: firstPart?.basePrice?.amount.toString() ?? '0.00',
        clearLineErrors: true,
        orderNumber: '',
        notes: '',
        clearCreateError: true,
        clearSuppliersError: true,
        isLoadingSuppliers: true,
      ),
    );
    unawaited(refreshCatalog.execute(force: false).catchError((Object _) {}));
    try {
      final list = await getSuppliers.execute();
      final active = [for (final s in list) if (s.active) s];
      final display = active.isEmpty ? list : active;
      _update(
        _state.copyWith(
          suppliers: display,
          isLoadingSuppliers: false,
          selectedSupplierId: display.isEmpty ? null : display.first.id,
          clearSelectedSupplier: display.isEmpty,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(isLoadingSuppliers: false, suppliersError: toUiText(e)));
    }
  }

  void onDismissCreateSheet() {
    if (!_state.createSheetOpen || _state.isCreating) return;
    _update(_state.copyWith(createSheetOpen: false, clearCreateError: true));
  }

  void onSelectSupplier(String supplierId) =>
      _update(_state.copyWith(selectedSupplierId: supplierId, clearCreateError: true));

  void onPartQueryChange(String v) => _update(_state.copyWith(partQuery: v, clearCreateError: true));

  void onToggleLowStockOnly() {
    final state = _state;
    final updated = state.copyWith(lowStockOnly: !state.lowStockOnly, clearCreateError: true);
    final visible = updated.filteredCatalogParts;
    final keepSelected = visible.any((p) => p.id == updated.selectedPartId);
    final nextPart = keepSelected || visible.isEmpty ? null : visible.first;
    if (nextPart == null) {
      _update(updated);
      return;
    }
    _update(
      updated.copyWith(
        selectedPartId: nextPart.id,
        lineQuantity: plainQuantity(suggestedReplenishmentQty(nextPart)),
        lineUnitCost:
            nextPart.basePrice?.amount.toString() ??
            (updated.lineUnitCost.trim().isEmpty ? '0.00' : updated.lineUnitCost),
        clearLineErrors: true,
      ),
    );
  }

  void onSelectPart(Part part) {
    _update(
      _state.copyWith(
        selectedPartId: part.id,
        lineQuantity: plainQuantity(suggestedReplenishmentQty(part)),
        lineUnitCost:
            part.basePrice?.amount.toString() ??
            (_state.lineUnitCost.trim().isEmpty ? '0.00' : _state.lineUnitCost),
        clearLineErrors: true,
        clearCreateError: true,
      ),
    );
  }

  /// Crea un borrador con TODOS los repuestos en o debajo del stock mínimo y cantidades sugeridas.
  Future<void> onCreateLowStockOrder() async {
    final state = _state;
    final supplierId = state.selectedSupplierId;
    if (supplierId == null) return;
    final lowStock = state.lowStockParts;
    if (lowStock.isEmpty || state.isCreating || !state.isOnline) return;
    final items = [
      for (final part in lowStock)
        PurchaseOrderLineInput(
          itemId: part.id,
          quantity: suggestedReplenishmentQty(part),
          unitCost: part.basePrice?.amount ?? Decimal.zero,
        ),
    ];
    await _submitOrder(supplierId, items, state.orderNumber, state.notes);
  }

  void onLineQuantityChange(String v) =>
      _update(_state.copyWith(lineQuantity: v, clearLineErrors: true, clearCreateError: true));

  void onLineUnitCostChange(String v) =>
      _update(_state.copyWith(lineUnitCost: v, clearLineErrors: true, clearCreateError: true));

  void onOrderNumberChange(String v) =>
      _update(_state.copyWith(orderNumber: v, clearCreateError: true));

  void onNotesChange(String v) => _update(_state.copyWith(notes: v, clearCreateError: true));

  Future<void> onCreateOrder() async {
    final state = _state;
    final supplierId = state.selectedSupplierId;
    if (supplierId == null || state.isCreating || !state.isOnline) return;
    final partId = state.selectedPartId;
    if (partId == null) {
      _update(
        _state.copyWith(
          createError: UiText.resource((s) => s.invSeg2PoNoParts),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }
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
    await _submitOrder(
      supplierId,
      [PurchaseOrderLineInput(itemId: partId, quantity: qty!, unitCost: cost!)],
      state.orderNumber,
      state.notes,
    );
  }

  Future<void> _submitOrder(
    String supplierId,
    List<PurchaseOrderLineInput> items,
    String orderNumber,
    String notes,
  ) async {
    _update(_state.copyWith(isCreating: true, clearCreateError: true));
    try {
      final created = await createPurchaseOrder.execute(
        supplierId,
        items: items,
        orderNumber: orderNumber,
        notes: notes,
      );
      _update(
        _state.copyWith(
          isCreating: false,
          createSheetOpen: false,
          createdOrderId: created.id,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
      refresh();
    } on Object catch (e) {
      final error = e is MissingBranchException
          ? UiText.resource((s) => s.invSeg2PoMissingBranch)
          : toUiText(e);
      _update(
        _state.copyWith(
          isCreating: false,
          createError: error,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void onCreatedOrderNavigated() => _update(_state.copyWith(clearCreatedOrder: true));

  void _update(PurchaseOrdersUiState state) {
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
