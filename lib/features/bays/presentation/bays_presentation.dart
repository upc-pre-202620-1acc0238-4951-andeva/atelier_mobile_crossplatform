import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/create_work_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/release_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/restore_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/set_bay_maintenance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/navigation/bays_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';

/// Pantalla de `bays`: tablero de ocupación y reasignación (US40).
void setupBaysPresentation() {
  registerBaysRoutes();

  getIt.registerFactory<BaysViewModel>(
    () => BaysViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeBoard: getIt<ObserveBayBoardUseCase>(),
      pollBoard: getIt<PollBayBoardUseCase>(),
      observeOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      refreshOrders: getIt<RefreshBranchWorkOrdersUseCase>(),
      getMechanics: getIt<GetBranchMechanicsUseCase>(),
      reassignBay: getIt<ReassignBayUseCase>(),
      reassignTaskMechanic: getIt<ReassignTaskMechanicUseCase>(),
      releaseBay: getIt<ReleaseBayUseCase>(),
      createBay: getIt<CreateWorkBayUseCase>(),
      setBayMaintenance: getIt<SetBayMaintenanceUseCase>(),
      restoreBay: getIt<RestoreBayUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
