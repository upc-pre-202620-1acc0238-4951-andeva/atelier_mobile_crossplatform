import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/add_purchase_order_item_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/cancel_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/create_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/dispatch_fifo_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/find_part_by_sku_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_inventory_valuation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_suppliers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/issue_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_direct_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/restore_batch_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/search_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/update_supplier_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/catalog/parts_catalog_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/detail/part_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/navigation/inventory_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_order_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/orders/purchase_orders_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/scanner/sku_scanner_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/suppliers/suppliers_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/valuation/inventory_valuation_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';

/// Pantallas y ViewModels de `inventory` (catálogo, escáner, ficha FIFO, proveedores, órdenes de compra y
/// valorización). Alertas y recepción de compra (US34) quedan sin UI.
void setupInventoryPresentation() {
  registerInventoryRoutes();

  getIt.registerFactory<PartsCatalogViewModel>(
    () => PartsCatalogViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeCatalog: getIt<ObservePartsCatalogUseCase>(),
      refreshCatalog: getIt<RefreshPartsCatalogUseCase>(),
      searchCatalog: getIt<SearchPartsCatalogUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      createPart: getIt<CreatePartUseCase>(),
    ),
  );
  getIt.registerFactoryParam<PartDetailViewModel, String, void>(
    (partId, _) => PartDetailViewModel(
      partId: partId,
      observeSession: getIt<ObserveSessionUseCase>(),
      observePart: getIt<ObservePartUseCase>(),
      observeBatches: getIt<ObservePartBatchesUseCase>(),
      refreshBatches: getIt<RefreshPartBatchesUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      updatePart: getIt<UpdatePartUseCase>(),
      receiveDirectBatch: getIt<ReceiveDirectBatchUseCase>(),
      dispatchFifoBatch: getIt<DispatchFifoBatchUseCase>(),
      restoreBatch: getIt<RestoreBatchUseCase>(),
    ),
  );
  getIt.registerFactory<SkuScannerViewModel>(
    () => SkuScannerViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      findPartBySku: getIt<FindPartBySkuUseCase>(),
    ),
  );
  getIt.registerFactory<SuppliersViewModel>(
    () => SuppliersViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      getSuppliers: getIt<GetSuppliersUseCase>(),
      createSupplier: getIt<CreateSupplierUseCase>(),
      updateSupplier: getIt<UpdateSupplierUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
  getIt.registerFactory<PurchaseOrdersViewModel>(
    () => PurchaseOrdersViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      getOrders: getIt<GetPurchaseOrdersUseCase>(),
      getSuppliers: getIt<GetSuppliersUseCase>(),
      createPurchaseOrder: getIt<CreatePurchaseOrderUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      observeCatalog: getIt<ObservePartsCatalogUseCase>(),
      refreshCatalog: getIt<RefreshPartsCatalogUseCase>(),
    ),
  );
  getIt.registerFactoryParam<PurchaseOrderDetailViewModel, String, void>(
    (orderId, _) => PurchaseOrderDetailViewModel(
      orderId: orderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      getOrder: getIt<GetPurchaseOrderUseCase>(),
      observePart: getIt<ObservePartUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      observeCatalog: getIt<ObservePartsCatalogUseCase>(),
      refreshCatalog: getIt<RefreshPartsCatalogUseCase>(),
      addPurchaseOrderItem: getIt<AddPurchaseOrderItemUseCase>(),
      issuePurchaseOrder: getIt<IssuePurchaseOrderUseCase>(),
      cancelPurchaseOrder: getIt<CancelPurchaseOrderUseCase>(),
    ),
  );
  getIt.registerFactory<InventoryValuationViewModel>(
    () => InventoryValuationViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeCatalog: getIt<ObservePartsCatalogUseCase>(),
      getValuation: getIt<GetInventoryValuationUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
