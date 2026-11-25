import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_cash_flow_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/navigation/reports_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_view_model.dart';

/// Pantalla de `reports`: flujo de caja del taller y exportación PDF (US41). Sin salud de flota (US43).
void setupReportsPresentation() {
  registerReportsRoutes();

  getIt.registerFactory<ReportsViewModel>(
    () => ReportsViewModel(
      getCashFlow: getIt<GetCashFlowSummaryUseCase>(),
      downloadCashFlowPdf: getIt<DownloadCashFlowPdfUseCase>(),
      observeSession: getIt<ObserveSessionUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
