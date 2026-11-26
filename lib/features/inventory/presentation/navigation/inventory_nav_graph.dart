import 'package:atelier_mobile_crossplatform/features/inventory/presentation/alerts/stock_alerts_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_screen.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de inventario (equivale a `inventoryNavGraph`), con las alertas de stock mínimo (US34).
void registerInventoryRoutes() {
  AppNavigator.register(
    AppRoute.partsCatalog,
    (context, args) => const PartsCatalogScreen(),
  );
  AppNavigator.register(
    AppRoute.skuScanner,
    (context, args) => const SkuScannerScreen(),
  );
  AppNavigator.register(
    AppRoute.partDetail,
    (context, args) => PartDetailScreen(partId: args as String),
  );
  AppNavigator.register(
    AppRoute.suppliers,
    (context, args) => const SuppliersScreen(),
  );
  AppNavigator.register(
    AppRoute.purchaseOrders,
    (context, args) => const PurchaseOrdersScreen(),
  );
  AppNavigator.register(
    AppRoute.purchaseOrderDetail,
    (context, args) => PurchaseOrderDetailScreen(orderId: args as String),
  );
  AppNavigator.register(
    AppRoute.inventoryValuation,
    (context, args) => const InventoryValuationScreen(),
  );
  AppNavigator.register(
    AppRoute.stockAlerts,
    (context, args) => const StockAlertsScreen(),
  );
}
