import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/find_part_by_sku_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_inventory_valuation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_part_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_purchase_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/get_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_part_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/observe_stock_alerts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/receive_purchase_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_part_batches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/refresh_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/application/search_parts_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/inventory_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:path_provider/path_provider.dart';

void setupInventoryDependencies() {
  getIt.registerLazySingleton<PartDao>(() => getIt<AppDatabase>().partDao);
  getIt.registerLazySingleton<BatchDao>(() => getIt<AppDatabase>().batchDao);

  getIt.registerLazySingleton<InventoryApi>(
    () => InventoryApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      api: getIt<InventoryApi>(),
      partDao: getIt<PartDao>(),
      batchDao: getIt<BatchDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      uploader: getIt<SupabaseUploader>(),
      session: getIt<SessionManager>(),
      cacheDirectory: getTemporaryDirectory,
    ),
  );

  getIt.registerLazySingleton<RefreshPartsCatalogUseCase>(
    () => RefreshPartsCatalogUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<ObservePartsCatalogUseCase>(
    () => ObservePartsCatalogUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<SearchPartsCatalogUseCase>(
    () => SearchPartsCatalogUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<FindPartBySkuUseCase>(
    () => FindPartBySkuUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<ObservePartUseCase>(
    () => ObservePartUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<GetPartDetailUseCase>(
    () => GetPartDetailUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<RefreshPartBatchesUseCase>(
    () => RefreshPartBatchesUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<ObservePartBatchesUseCase>(
    () => ObservePartBatchesUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<GetStockAlertsUseCase>(
    () => GetStockAlertsUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<ObserveStockAlertsUseCase>(
    () => ObserveStockAlertsUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<GetInventoryValuationUseCase>(
    () =>
        GetInventoryValuationUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<GetPurchaseOrdersUseCase>(
    () => GetPurchaseOrdersUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<GetPurchaseOrderUseCase>(
    () => GetPurchaseOrderUseCase(repository: getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton<ReceivePurchaseOrderUseCase>(
    () => ReceivePurchaseOrderUseCase(repository: getIt<InventoryRepository>()),
  );
}
