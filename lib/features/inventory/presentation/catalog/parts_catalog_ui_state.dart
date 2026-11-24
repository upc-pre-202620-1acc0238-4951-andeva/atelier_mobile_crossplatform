import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// US31: catálogo de repuestos. Sin texto se ve la caché completa (por categoría); con texto, la búsqueda por
/// nombre o SKU. [category] `null` = todas.
class PartsCatalogUiState {
  final String query;
  final ItemCategory? category;
  final List<Part> parts;
  final bool isLoaded;
  final bool isRefreshing;
  final bool isSearching;
  final bool isOnline;

  /// La última recarga falló (sin red): se sigue con la caché.
  final bool showingCache;
  final UiText? error;
  final bool canRead;
  final bool canManage;
  final UiText? bannerMessage;
  final bool createSheetOpen;
  final String formName;
  final String formSku;
  final ItemCategory formCategory;
  final String formBasePrice;
  final String formMinimumStock;
  final UiText? nameError;
  final UiText? skuError;
  final UiText? priceError;
  final UiText? minStockError;
  final UiText? createError;
  final bool isCreating;
  final int hapticEvent;
  final bool hapticIsError;

  const PartsCatalogUiState({
    this.query = '',
    this.category,
    this.parts = const [],
    this.isLoaded = false,
    this.isRefreshing = false,
    this.isSearching = false,
    this.isOnline = true,
    this.showingCache = false,
    this.error,
    this.canRead = true,
    this.canManage = false,
    this.bannerMessage,
    this.createSheetOpen = false,
    this.formName = '',
    this.formSku = '',
    this.formCategory = ItemCategory.lubricants,
    this.formBasePrice = '',
    this.formMinimumStock = '',
    this.nameError,
    this.skuError,
    this.priceError,
    this.minStockError,
    this.createError,
    this.isCreating = false,
    this.hapticEvent = 0,
    this.hapticIsError = false,
  });

  bool get hasFilters => query.trim().isNotEmpty || category != null;

  PartsCatalogUiState copyWith({
    String? query,
    ItemCategory? category,
    bool clearCategory = false,
    List<Part>? parts,
    bool? isLoaded,
    bool? isRefreshing,
    bool? isSearching,
    bool? isOnline,
    bool? showingCache,
    UiText? error,
    bool clearError = false,
    bool? canRead,
    bool? canManage,
    UiText? bannerMessage,
    bool clearBanner = false,
    bool? createSheetOpen,
    String? formName,
    String? formSku,
    ItemCategory? formCategory,
    String? formBasePrice,
    String? formMinimumStock,
    UiText? nameError,
    UiText? skuError,
    UiText? priceError,
    UiText? minStockError,
    bool clearFieldErrors = false,
    UiText? createError,
    bool clearCreateError = false,
    bool? isCreating,
    int? hapticEvent,
    bool? hapticIsError,
  }) {
    return PartsCatalogUiState(
      query: query ?? this.query,
      category: clearCategory ? null : category ?? this.category,
      parts: parts ?? this.parts,
      isLoaded: isLoaded ?? this.isLoaded,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSearching: isSearching ?? this.isSearching,
      isOnline: isOnline ?? this.isOnline,
      showingCache: showingCache ?? this.showingCache,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
      canManage: canManage ?? this.canManage,
      bannerMessage: clearBanner ? null : bannerMessage ?? this.bannerMessage,
      createSheetOpen: createSheetOpen ?? this.createSheetOpen,
      formName: formName ?? this.formName,
      formSku: formSku ?? this.formSku,
      formCategory: formCategory ?? this.formCategory,
      formBasePrice: formBasePrice ?? this.formBasePrice,
      formMinimumStock: formMinimumStock ?? this.formMinimumStock,
      nameError: clearFieldErrors ? null : nameError ?? this.nameError,
      skuError: clearFieldErrors ? null : skuError ?? this.skuError,
      priceError: clearFieldErrors ? null : priceError ?? this.priceError,
      minStockError: clearFieldErrors ? null : minStockError ?? this.minStockError,
      createError: clearCreateError ? null : createError ?? this.createError,
      isCreating: isCreating ?? this.isCreating,
      hapticEvent: hapticEvent ?? this.hapticEvent,
      hapticIsError: hapticIsError ?? this.hapticIsError,
    );
  }
}
