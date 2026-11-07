import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/attach_intake_photo_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/cancel_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/complete_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/download_quotation_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_draft_work_order_for_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_part_movements_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_profitability_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/notify_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_intake_photos_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_proposals_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/open_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/send_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/start_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/local/work_order_dao.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/service_catalog_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_api.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/attach_intake_image_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/sync/submit_proposal_handler.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/work_order_repository_impl.dart';
import 'package:path_provider/path_provider.dart';

void setupWorkOrdersDependencies() {
  getIt.registerLazySingleton<WorkOrderDao>(
    () => getIt<AppDatabase>().workOrderDao,
  );

  getIt.registerLazySingleton<WorkOrderApi>(
    () => WorkOrderApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ServiceCatalogApi>(
    () => ServiceCatalogApi(client: getIt<ApiClient>()),
  );

  final handlers = getIt<OperationHandlerRegistry>();
  handlers.register(
    AttachIntakeImageHandler.type,
    () => AttachIntakeImageHandler(api: getIt<WorkOrderApi>()),
  );
  handlers.register(
    SubmitProposalHandler.type,
    () => SubmitProposalHandler(api: getIt<WorkOrderApi>()),
  );

  getIt.registerLazySingleton<WorkOrderRepository>(
    () => WorkOrderRepositoryImpl(
      workOrderApi: getIt<WorkOrderApi>(),
      serviceCatalogApi: getIt<ServiceCatalogApi>(),
      employeeApi: getIt<EmployeeApi>(),
      workOrderDao: getIt<WorkOrderDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      pendingOperationDao: getIt<PendingOperationDao>(),
      pendingUploadDao: getIt<PendingUploadDao>(),
      photoCapture: getIt<PhotoCapture>(),
      pdfDownloader: getIt<PdfDownloader>(),
      session: getIt<SessionManager>(),
      supportDirectory: getApplicationSupportDirectory,
    ),
  );

  getIt.registerLazySingleton<RefreshBranchWorkOrdersUseCase>(
    () => RefreshBranchWorkOrdersUseCase(
      repository: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveBranchWorkOrdersUseCase>(
    () => ObserveBranchWorkOrdersUseCase(
      repository: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveWorkOrderUseCase>(
    () => ObserveWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetWorkOrderDetailUseCase>(
    () => GetWorkOrderDetailUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<OpenWorkOrderUseCase>(
    () => OpenWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<UpdateWorkOrderUseCase>(
    () => UpdateWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<FindDraftWorkOrderForVehicleUseCase>(
    () => FindDraftWorkOrderForVehicleUseCase(
      repository: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<StartWorkOrderUseCase>(
    () => StartWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<CompleteWorkOrderUseCase>(
    () => CompleteWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<CancelWorkOrderUseCase>(
    () => CancelWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<AddWorkOrderTaskUseCase>(
    () => AddWorkOrderTaskUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<UpdateWorkOrderTaskUseCase>(
    () => UpdateWorkOrderTaskUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetServiceCatalogUseCase>(
    () => GetServiceCatalogUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetBranchMechanicsUseCase>(
    () => GetBranchMechanicsUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<AttachIntakePhotoUseCase>(
    () => AttachIntakePhotoUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<ObservePendingIntakePhotosUseCase>(
    () => ObservePendingIntakePhotosUseCase(
      repository: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<SubmitProposalUseCase>(
    () => SubmitProposalUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<ObservePendingProposalsUseCase>(
    () => ObservePendingProposalsUseCase(
      repository: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<NotifyProposalUseCase>(
    () => NotifyProposalUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<ApproveProposalUseCase>(
    () => ApproveProposalUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<RejectProposalUseCase>(
    () => RejectProposalUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<DownloadQuotationPdfUseCase>(
    () => DownloadQuotationPdfUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<SendQuotationUseCase>(
    () => SendQuotationUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<ApproveQuotationUseCase>(
    () => ApproveQuotationUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<RejectQuotationUseCase>(
    () => RejectQuotationUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetPartMovementsUseCase>(
    () => GetPartMovementsUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetProfitabilityUseCase>(
    () => GetProfitabilityUseCase(repository: getIt<WorkOrderRepository>()),
  );
}
