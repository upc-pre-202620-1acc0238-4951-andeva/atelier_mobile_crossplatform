import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_cash_flow_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_fleet_health_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reports/infrastructure/remote/reports_api.dart';
import 'package:atelier_mobile_crossplatform/features/reports/infrastructure/reports_repository_impl.dart';

void setupReportsDependencies() {
  getIt.registerLazySingleton<ReportsApi>(
    () => ReportsApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(
      api: getIt<ReportsApi>(),
      pdfDownloader: getIt<PdfDownloader>(),
    ),
  );
  getIt.registerLazySingleton<GetCashFlowSummaryUseCase>(
    () => GetCashFlowSummaryUseCase(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton<DownloadCashFlowPdfUseCase>(
    () => DownloadCashFlowPdfUseCase(repository: getIt<ReportsRepository>()),
  );
  getIt.registerLazySingleton<DownloadFleetHealthPdfUseCase>(
    () => DownloadFleetHealthPdfUseCase(repository: getIt<ReportsRepository>()),
  );
}
