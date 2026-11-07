import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
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
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/batch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/local/part_dao.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FlutterSecureStorage.setMockInitialValues({});
    setupDependencies();
    getIt.unregister<AppDatabase>();
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(NativeDatabase.memory()),
      dispose: (database) => database.close(),
    );
  });

  tearDown(() => getIt.reset());

  test('resuelve DAOs, API y repositorio; tasks sigue usando la misma API', () {
    expect(getIt<PartDao>(), isNotNull);
    expect(getIt<BatchDao>(), isNotNull);
    expect(getIt<InventoryApi>(), isNotNull);
    expect(getIt<InventoryRepository>(), isNotNull);
    expect(getIt<TaskRepository>(), isNotNull);
  });

  test('los 14 casos de uso se pueden resolver', () {
    expect(getIt<RefreshPartsCatalogUseCase>(), isNotNull);
    expect(getIt<ObservePartsCatalogUseCase>(), isNotNull);
    expect(getIt<SearchPartsCatalogUseCase>(), isNotNull);
    expect(getIt<FindPartBySkuUseCase>(), isNotNull);
    expect(getIt<ObservePartUseCase>(), isNotNull);
    expect(getIt<GetPartDetailUseCase>(), isNotNull);
    expect(getIt<RefreshPartBatchesUseCase>(), isNotNull);
    expect(getIt<ObservePartBatchesUseCase>(), isNotNull);
    expect(getIt<GetStockAlertsUseCase>(), isNotNull);
    expect(getIt<ObserveStockAlertsUseCase>(), isNotNull);
    expect(getIt<GetInventoryValuationUseCase>(), isNotNull);
    expect(getIt<GetPurchaseOrdersUseCase>(), isNotNull);
    expect(getIt<GetPurchaseOrderUseCase>(), isNotNull);
    expect(getIt<ReceivePurchaseOrderUseCase>(), isNotNull);
  });
}
