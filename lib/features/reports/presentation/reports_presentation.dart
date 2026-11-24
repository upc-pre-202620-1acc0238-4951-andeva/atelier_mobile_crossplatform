import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/navigation/reports_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_view_model.dart';

/// Pantalla de `reports`: el flujo de caja del taller (sin exportación en PDF, US41).
void setupReportsPresentation() {
  registerReportsRoutes();

  getIt.registerFactory<ReportsViewModel>(
    () => ReportsViewModel(
      getCashFlow: getIt<GetCashFlowSummaryUseCase>(),
      observeSession: getIt<ObserveSessionUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
