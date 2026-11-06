import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
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
import 'package:atelier_mobile_crossplatform/features/tasks/infrastructure/local/task_dao.dart';
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
  });

  tearDown(() => getIt.reset());

  void setup() {
    setupDependencies();
    getIt.unregister<AppDatabase>();
    getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(NativeDatabase.memory()),
      dispose: (database) => database.close(),
    );
  }

  test('el registry incluye el handler de evidencia de tareas', () {
    setup();
    final registry = getIt<OperationHandlerRegistry>();
    expect(registry.find('ATTACH_TASK_EVIDENCE'), isNotNull);
  });

  test('resuelve DAOs y repositorios de tareas', () {
    setup();
    expect(getIt<TaskDao>(), isNotNull);
    expect(getIt<PausedElapsedStore>(), isNotNull);
    expect(getIt<TaskRepository>(), isNotNull);
  });

  test('los 18 casos de uso de tareas se pueden resolver', () {
    setup();
    expect(getIt<ObserveMyTasksUseCase>(), isNotNull);
    expect(getIt<RefreshMyTasksUseCase>(), isNotNull);
    expect(getIt<ObserveTaskUseCase>(), isNotNull);
    expect(getIt<GetTaskDetailUseCase>(), isNotNull);
    expect(getIt<StartTaskUseCase>(), isNotNull);
    expect(getIt<PauseTaskUseCase>(), isNotNull);
    expect(getIt<RequestSuspensionUseCase>(), isNotNull);
    expect(getIt<ApproveSuspensionUseCase>(), isNotNull);
    expect(getIt<RejectSuspensionUseCase>(), isNotNull);
    expect(getIt<ResumeSuspendedTaskUseCase>(), isNotNull);
    expect(getIt<SuggestLaborHoursUseCase>(), isNotNull);
    expect(getIt<CompleteTaskUseCase>(), isNotNull);
    expect(getIt<AttachTaskEvidenceUseCase>(), isNotNull);
    expect(getIt<ObservePendingEvidenceUseCase>(), isNotNull);
    expect(getIt<SearchPartsUseCase>(), isNotNull);
    expect(getIt<AddPartToTaskUseCase>(), isNotNull);
    expect(getIt<UpdateTaskPartQuantityUseCase>(), isNotNull);
    expect(getIt<RemovePartFromTaskUseCase>(), isNotNull);
  });
}
