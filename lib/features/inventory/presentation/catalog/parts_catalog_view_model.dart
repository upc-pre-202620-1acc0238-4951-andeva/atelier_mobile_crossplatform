import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/search_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

/// US31: buscador reactivo del catálogo + alta de repuestos (`PARTS_MANAGE`). Al abrir recarga el catálogo (1 h de
/// caché) y observa Drift; el texto se busca por nombre o SKU con debounce y la categoría filtra. Sin red se busca
/// en la caché.
class PartsCatalogViewModel extends ChangeNotifier {
  static const searchDebounce = Duration(milliseconds: 300);

  final ObserveSessionUseCase observeSession;
  final ObservePartsCatalogUseCase observeCatalog;
  final RefreshPartsCatalogUseCase refreshCatalog;
  final SearchPartsCatalogUseCase searchCatalog;
  final ConnectivityObserver connectivity;
  final CreatePartUseCase createPart;

  PartsCatalogViewModel({
    required this.observeSession,
    required this.observeCatalog,
    required this.refreshCatalog,
    required this.searchCatalog,
    required this.connectivity,
    required this.createPart,
  }) {
    _subscriptions.add(
      observeSession.execute().listen(
        (session) => _update(
          _state.copyWith(
            canRead: session?.has(Permission.partsRead) ?? false,
            canManage: session?.has(Permission.partsManage) ?? false,
          ),
        ),
      ),
    );
    _applyFilters();
    _state = _state.copyWith(isOnline: connectivity.isOnline);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  PartsCatalogUiState _state = const PartsCatalogUiState();
  PartsCatalogUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<List<Part>>? _catalogSubscription;
  Timer? _debounce;
  int _searchToken = 0;
  bool _disposed = false;

  /// D2: al volver la red tras una recarga fallida, se actualiza sola y el aviso se quita.
  void _onConnectivity() {
    final online = connectivity.isOnline;
    final retry = online && _state.showingCache;
    _update(_state.copyWith(isOnline: online));
    if (retry) refresh();
  }

  void _scheduleFilters() {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, _applyFilters);
  }

  Future<void> _applyFilters() async {
    final token = ++_searchToken;
    await _catalogSubscription?.cancel();
    _catalogSubscription = null;
    if (_disposed) return;
    final query = _state.query;
    final category = _state.category;
    if (query.trim().isEmpty) {
      _update(_state.copyWith(isSearching: false));
      _catalogSubscription = observeCatalog
          .execute(category: category)
          .listen((parts) {
            if (token == _searchToken) _update(_state.copyWith(parts: parts, isLoaded: true));
          });
      return;
    }
    _update(_state.copyWith(isSearching: true, clearError: true));
    try {
      final parts = await searchCatalog.execute(query.trim(), category: category);
      if (token != _searchToken) return;
      _update(_state.copyWith(parts: parts, isLoaded: true, isSearching: false));
    } on Object catch (e) {
      if (token != _searchToken) return;
      _update(_state.copyWith(isSearching: false, isLoaded: true, error: toUiText(e)));
    }
  }

  /// Al abrir y al tocar actualizar: [force] ignora la antigüedad de la caché.
  Future<void> refresh({bool force = false}) async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    try {
      await refreshCatalog.execute(force: force);
      _update(_state.copyWith(isRefreshing: false, showingCache: false));
    } on Object catch (e) {
      _update(_state.copyWith(isRefreshing: false, showingCache: true, error: toUiText(e)));
    }
  }

  void onQueryChange(String value) {
    _update(_state.copyWith(query: value));
    _scheduleFilters();
  }

  /// Tocar la categoría activa la quita.
  void onCategoryClick(ItemCategory? category) {
    final next = _state.category == category ? null : category;
    _update(_state.copyWith(category: next, clearCategory: next == null));
    _scheduleFilters();
  }

  void onClearFilters() {
    _debounce?.cancel();
    _update(_state.copyWith(query: '', clearCategory: true));
    _applyFilters();
  }

  void onOpenCreateSheet() {
    _update(
      _state.copyWith(
        createSheetOpen: true,
        formName: '',
        formSku: '',
        formCategory: _state.category ?? ItemCategory.lubricants,
        formBasePrice: '',
        formMinimumStock: '',
        clearFieldErrors: true,
        clearCreateError: true,
      ),
    );
  }

  void onDismissCreateSheet() {
    if (!_state.createSheetOpen) return;
    if (_state.isCreating) return;
    _update(_state.copyWith(createSheetOpen: false, clearCreateError: true));
  }

  void onFormNameChange(String v) =>
      _update(_state.copyWith(formName: v, clearFieldErrors: true, clearCreateError: true));
  void onFormSkuChange(String v) =>
      _update(_state.copyWith(formSku: v, clearFieldErrors: true, clearCreateError: true));
  void onFormCategoryChange(ItemCategory v) =>
      _update(_state.copyWith(formCategory: v, clearCreateError: true));
  void onFormBasePriceChange(String v) =>
      _update(_state.copyWith(formBasePrice: v, clearFieldErrors: true, clearCreateError: true));
  void onFormMinimumStockChange(String v) =>
      _update(_state.copyWith(formMinimumStock: v, clearFieldErrors: true, clearCreateError: true));

  Future<void> onCreatePart() async {
    final state = _state;
    if (state.isCreating || !state.isOnline) return;
    final price = parseDecimalInput(state.formBasePrice);
    final minStock = parseDecimalInput(state.formMinimumStock);

    final nameErr = !InventoryValidation.isNonEmptyText(state.formName)
        ? UiText.resource((s) => s.invSeg2PartErrName)
        : null;
    final skuErr = !InventoryValidation.isSku(state.formSku)
        ? UiText.resource((s) => s.invSeg2PartErrSku)
        : null;
    final priceErr = price == null || !InventoryValidation.isNonNegative(price)
        ? UiText.resource((s) => s.invSeg2PartErrPrice)
        : null;
    final minErr = minStock == null || !InventoryValidation.isNonNegative(minStock)
        ? UiText.resource((s) => s.invSeg2PartErrMinStock)
        : null;

    if (nameErr != null || skuErr != null || priceErr != null || minErr != null) {
      _update(
        _state.copyWith(
          clearFieldErrors: true,
          nameError: nameErr,
          skuError: skuErr,
          priceError: priceErr,
          minStockError: minErr,
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
      return;
    }

    _update(_state.copyWith(isCreating: true, clearCreateError: true));
    try {
      await createPart.execute(
        name: state.formName,
        sku: state.formSku,
        category: state.formCategory,
        basePrice: price!,
        minimumStock: minStock!,
      );
      _update(
        _state.copyWith(
          isCreating: false,
          createSheetOpen: false,
          bannerMessage: UiText.resource((s) => s.invSeg2PartSaved),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: false,
        ),
      );
    } on Object catch (e) {
      _update(
        _state.copyWith(
          isCreating: false,
          createError: toUiText(e),
          hapticEvent: _state.hapticEvent + 1,
          hapticIsError: true,
        ),
      );
    }
  }

  void _update(PartsCatalogUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    connectivity.removeListener(_onConnectivity);
    _catalogSubscription?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
