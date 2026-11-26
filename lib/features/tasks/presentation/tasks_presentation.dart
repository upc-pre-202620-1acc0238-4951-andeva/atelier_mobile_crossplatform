import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reopen_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/paused_elapsed_store.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/navigation/tasks_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Pantallas de `tasks`: Mis tareas (US26) y el detalle de tarea (US27, US33).
void setupTasksPresentation() {
  registerTasksRoutes();

  getIt.registerFactory<MyTasksViewModel>(
    () => MyTasksViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeMyTasks: getIt<ObserveMyTasksUseCase>(),
      refreshMyTasks: getIt<RefreshMyTasksUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      observePendingCount: getIt<ObservePendingOperationCountUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
    ),
  );
  getIt.registerFactoryParam<TaskDetailViewModel, TaskDetailArgs, void>(
    (args, _) => TaskDetailViewModel(
      taskId: TaskId(args.taskId),
      workOrderId: args.workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      observeTask: getIt<ObserveTaskUseCase>(),
      getDetail: getIt<GetTaskDetailUseCase>(),
      startTask: getIt<StartTaskUseCase>(),
      pauseTask: getIt<PauseTaskUseCase>(),
      reopenTask: getIt<ReopenTaskUseCase>(),
      searchParts: getIt<SearchPartsUseCase>(),
      addPart: getIt<AddPartToTaskUseCase>(),
      updatePartQuantity: getIt<UpdateTaskPartQuantityUseCase>(),
      removePart: getIt<RemovePartFromTaskUseCase>(),
      suggestLaborHours: getIt<SuggestLaborHoursUseCase>(),
      completeTask: getIt<CompleteTaskUseCase>(),
      attachTaskEvidence: getIt<AttachTaskEvidenceUseCase>(),
      observePendingEvidence: getIt<ObservePendingEvidenceUseCase>(),
      requestSuspension: getIt<RequestSuspensionUseCase>(),
      approveSuspension: getIt<ApproveSuspensionUseCase>(),
      rejectSuspension: getIt<RejectSuspensionUseCase>(),
      resumeSuspendedTask: getIt<ResumeSuspendedTaskUseCase>(),
      pausedElapsed: getIt<PausedElapsedStore>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
