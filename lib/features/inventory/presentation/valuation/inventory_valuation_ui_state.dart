import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:decimal/decimal.dart';

/// Existencias de una categoría; [category] `null` agrupa los repuestos sin categoría.
class CategoryStock {
  final ItemCategory? category;
  final int partCount;
  final Decimal units;

  const CategoryStock({required this.category, required this.partCount, required this.units});
}

class InventoryValuationUiState {
  final Money? valuation;
  final List<Part> parts;
  final bool isLoading;
  final bool isOnline;
  final UiText? error;
  final bool canRead;

  const InventoryValuationUiState({
    this.valuation,
    this.parts = const [],
    this.isLoading = true,
    this.isOnline = true,
    this.error,
    this.canRead = true,
  });

  int get withStockCount => parts.where((p) => p.totalStock > Decimal.zero).length;
  int get lowStockCount => parts.where((p) => p.isLowStock && !p.isOutOfStock).length;
  int get outOfStockCount => parts.where((p) => p.isOutOfStock).length;

  /// Existencias por categoría, de más a menos unidades. El backend solo da el total en soles.
  List<CategoryStock> get byCategory {
    final groups = <ItemCategory?, List<Part>>{};
    for (final part in parts) {
      if (part.totalStock > Decimal.zero) groups.putIfAbsent(part.category, () => []).add(part);
    }
    final rows = [
      for (final entry in groups.entries)
        CategoryStock(
          category: entry.key,
          partCount: entry.value.length,
          units: entry.value.fold(Decimal.zero, (sum, p) => sum + p.totalStock),
        ),
    ];
    rows.sort((a, b) => b.units.compareTo(a.units));
    return rows;
  }

  InventoryValuationUiState copyWith({
    Money? valuation,
    List<Part>? parts,
    bool? isLoading,
    bool? isOnline,
    UiText? error,
    bool clearError = false,
    bool? canRead,
  }) {
    return InventoryValuationUiState(
      valuation: valuation ?? this.valuation,
      parts: parts ?? this.parts,
      isLoading: isLoading ?? this.isLoading,
      isOnline: isOnline ?? this.isOnline,
      error: clearError ? null : error ?? this.error,
      canRead: canRead ?? this.canRead,
    );
  }
}
