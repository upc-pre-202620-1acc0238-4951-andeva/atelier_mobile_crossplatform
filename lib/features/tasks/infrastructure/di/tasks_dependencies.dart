import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_dao.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/local/vehicle_dao.dart';
import 'package:atelier_mobile_crossplatform/features/reception/infrastructure/remote/vehicle_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/preferences_paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_dao.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/remote/task_api.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/repository/task_evidence_capture.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/sync/attach_task_evidence_handler.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/task_repository_impl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setupTasksDependencies() {
  getIt.registerLazySingleton<TaskDao>(
    () => getIt<AppDatabase>().taskDao,
  );
  getIt.registerLazySingleton<VehicleDao>(
    () => getIt<AppDatabase>().vehicleDao,
  );
  getIt.registerLazySingleton<BayDao>(
    () => getIt<AppDatabase>().bayDao,
  );

  getIt.registerLazySingleton<TaskApi>(
    () => TaskApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<InventoryApi>(
    () => InventoryApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<VehicleApi>(
    () => VehicleApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WorkBayApi>(
    () => WorkBayApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<PausedElapsedStore>(
    () => PreferencesPausedElapsedStore(preferences: SharedPreferencesAsync()),
  );
  getIt.registerLazySingleton<TaskEvidenceCapture>(
    () => TaskEvidenceCapture(photoCapture: getIt<PhotoCapture>()),
  );

  final handlers = getIt<OperationHandlerRegistry>();
  handlers.register(
    AttachTaskEvidenceHandler.type,
    () => AttachTaskEvidenceHandler(api: getIt<TaskApi>()),
  );

  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      taskApi: getIt<TaskApi>(),
      inventoryApi: getIt<InventoryApi>(),
      vehicleApi: getIt<VehicleApi>(),
      bayApi: getIt<WorkBayApi>(),
      taskDao: getIt<TaskDao>(),
      vehicleDao: getIt<VehicleDao>(),
      bayDao: getIt<BayDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      pendingOperationDao: getIt<PendingOperationDao>(),
      pendingUploadDao: getIt<PendingUploadDao>(),
      evidenceCapture: getIt<TaskEvidenceCapture>(),
      session: getIt<SessionManager>(),
      supportDirectory: getApplicationSupportDirectory,
    ),
  );

  getIt.registerLazySingleton<ObserveMyTasksUseCase>(
    () => ObserveMyTasksUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<RefreshMyTasksUseCase>(
    () => RefreshMyTasksUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ObserveTaskUseCase>(
    () => ObserveTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<GetTaskDetailUseCase>(
    () => GetTaskDetailUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<StartTaskUseCase>(
    () => StartTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<PauseTaskUseCase>(
    () => PauseTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<RequestSuspensionUseCase>(
    () => RequestSuspensionUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ApproveSuspensionUseCase>(
    () => ApproveSuspensionUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<RejectSuspensionUseCase>(
    () => RejectSuspensionUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ResumeSuspendedTaskUseCase>(
    () => ResumeSuspendedTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<SuggestLaborHoursUseCase>(
    () => const SuggestLaborHoursUseCase(),
  );
  getIt.registerLazySingleton<CompleteTaskUseCase>(
    () => CompleteTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<AttachTaskEvidenceUseCase>(
    () => AttachTaskEvidenceUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<ObservePendingEvidenceUseCase>(
    () => ObservePendingEvidenceUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<SearchPartsUseCase>(
    () => SearchPartsUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<AddPartToTaskUseCase>(
    () => AddPartToTaskUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<UpdateTaskPartQuantityUseCase>(
    () => UpdateTaskPartQuantityUseCase(repository: getIt<TaskRepository>()),
  );
  getIt.registerLazySingleton<RemovePartFromTaskUseCase>(
    () => RemovePartFromTaskUseCase(repository: getIt<TaskRepository>()),
  );
}
