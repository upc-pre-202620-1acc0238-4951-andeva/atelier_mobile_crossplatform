import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/navigation/cashier_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';

/// Pantallas de `cashier`: solo "Caja del día". Comprobantes, cobro y entrega, y series quedan sin UI
/// (US37, US38, US39 y US42 excluidas); sus casos de uso siguen registrados en `setupCashierDependencies`.
void setupCashierPresentation() {
  registerCashierRoutes();

  getIt.registerFactory<DailyCashViewModel>(
    () => DailyCashViewModel(
      getDailyCashSummary: getIt<GetDailyCashSummaryUseCase>(),
      observeSession: getIt<ObserveSessionUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
