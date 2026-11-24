import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/purchase_order.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';

extension ItemCategoryLabel on ItemCategory {
  String label(AppLocalizations s) => switch (this) {
    ItemCategory.lubricants => s.categoryLubricants,
    ItemCategory.brakes => s.categoryBrakes,
    ItemCategory.suspension => s.categorySuspension,
    ItemCategory.engine => s.categoryEngine,
    ItemCategory.electrical => s.categoryElectrical,
    ItemCategory.tires => s.categoryTires,
    ItemCategory.filters => s.categoryFilters,
    ItemCategory.bodywork => s.categoryBodywork,
    ItemCategory.accessories => s.categoryAccessories,
  };
}

/// Semáforo de existencias (US31 E2): agotado en rojo, en el mínimo en aviso y con saldo en verde.
extension PartStockLabel on Part {
  String stockLabel(AppLocalizations s) {
    if (isOutOfStock) return s.stockOut;
    if (isLowStock) return s.stockLow;
    return s.stockOk;
  }

  ChipKind get stockChipKind {
    if (isOutOfStock) return ChipKind.bad;
    if (isLowStock) return ChipKind.warn;
    return ChipKind.ok;
  }
}

extension PurchaseOrderStatusLabel on PurchaseOrderStatus? {
  String label(AppLocalizations s) => switch (this) {
    PurchaseOrderStatus.draft => s.inventoryPoStatusDraft,
    PurchaseOrderStatus.issued => s.inventoryPoStatusIssued,
    PurchaseOrderStatus.received => s.inventoryPoStatusReceived,
    PurchaseOrderStatus.canceled => s.inventoryPoStatusCanceled,
    null => s.inventoryPoStatusUnknown,
  };

  ChipKind get chipKind => switch (this) {
    PurchaseOrderStatus.issued => ChipKind.info,
    PurchaseOrderStatus.received => ChipKind.ok,
    PurchaseOrderStatus.canceled => ChipKind.bad,
    _ => ChipKind.idle,
  };
}

/// Número tecleado con coma o punto decimal; `null` si no es un número.
Decimal? parseDecimalInput(String raw) => Decimal.tryParse(raw.trim().replaceAll(',', '.'));
