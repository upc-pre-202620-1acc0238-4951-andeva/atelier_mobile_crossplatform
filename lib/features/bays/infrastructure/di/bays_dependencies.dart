import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/refresh_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/bay_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_dao.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';

/// `BayDao` y `WorkBayApi` también los usa `TaskRepositoryImpl`: se registran solo aquí.
void setupBaysDependencies() {
  getIt.registerLazySingleton<BayDao>(() => getIt<AppDatabase>().bayDao);
  getIt.registerLazySingleton<WorkBayApi>(
    () => WorkBayApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BayRepository>(
    () => BayRepositoryImpl(
      api: getIt<WorkBayApi>(),
      bayDao: getIt<BayDao>(),
      workOrderDao: getIt<WorkOrderDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      workOrders: getIt<WorkOrderRepository>(),
      session: getIt<SessionManager>(),
    ),
  );

  getIt.registerLazySingleton<RefreshBayBoardUseCase>(
    () => RefreshBayBoardUseCase(repository: getIt<BayRepository>()),
  );
  getIt.registerLazySingleton<ObserveBayBoardUseCase>(
    () => ObserveBayBoardUseCase(repository: getIt<BayRepository>()),
  );
  getIt.registerLazySingleton<PollBayBoardUseCase>(
    () => PollBayBoardUseCase(repository: getIt<BayRepository>()),
  );
  getIt.registerLazySingleton<ReassignBayUseCase>(
    () => ReassignBayUseCase(repository: getIt<BayRepository>()),
  );
  getIt.registerLazySingleton<ReassignTaskMechanicUseCase>(
    () => ReassignTaskMechanicUseCase(repository: getIt<BayRepository>()),
  );
}
