import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/enrich_reception_references_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/add_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/approve_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/attach_intake_photo_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/cancel_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/complete_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/create_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/delete_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/download_quotation_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/find_draft_work_order_for_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_part_movements_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/notify_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_intake_photos_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_pending_proposals_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/open_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_service_catalog_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/reject_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/remove_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/send_quotation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/start_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/submit_proposal_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_service_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/update_work_order_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/work_order_detail_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/finding/report_finding_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/intake/intake_gallery_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/list/work_orders_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/navigation/work_order_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/open/open_work_order_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/proposals/proposals_panel_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/services/services_catalog_view_model.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Pantallas y ViewModels de `workorders`: lista, apertura, detalle, galería, propuestas, hallazgo y
/// catálogo de servicios.
void setupWorkOrdersPresentation() {
  registerWorkOrderRoutes();

  getIt.registerFactoryParam<OpenWorkOrderViewModel, OpenWorkOrderArgs, void>(
    (args, _) => OpenWorkOrderViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      openWorkOrder: getIt<OpenWorkOrderUseCase>(),
      updateWorkOrder: getIt<UpdateWorkOrderUseCase>(),
      addTask: getIt<AddWorkOrderTaskUseCase>(),
      findDraft: getIt<FindDraftWorkOrderForVehicleUseCase>(),
      getServices: getIt<GetServiceCatalogUseCase>(),
      getMechanics: getIt<GetBranchMechanicsUseCase>(),
      vehicleId: args.vehicleId,
      customerId: args.customerId,
      workOrderId: args.workOrderId,
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
  getIt.registerFactory<WorkOrdersViewModel>(
    () => WorkOrdersViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      observeOrders: getIt<ObserveBranchWorkOrdersUseCase>(),
      refreshOrders: getIt<RefreshBranchWorkOrdersUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      enrichReferences: getIt<EnrichReceptionReferencesUseCase>(),
      observePendingSyncCount: getIt<ObservePendingOperationCountUseCase>(),
      observePushHistory: getIt<ObservePushHistoryUseCase>(),
    ),
  );
  getIt.registerFactoryParam<WorkOrderDetailViewModel, String, void>(
    (workOrderId, _) => WorkOrderDetailViewModel(
      workOrderId: workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      getDetail: getIt<GetWorkOrderDetailUseCase>(),
      getServices: getIt<GetServiceCatalogUseCase>(),
      addTask: getIt<AddWorkOrderTaskUseCase>(),
      updateTask: getIt<UpdateWorkOrderTaskUseCase>(),
      removeTask: getIt<RemoveWorkOrderTaskUseCase>(),
      searchParts: getIt<SearchPartsUseCase>(),
      addPart: getIt<AddPartToTaskUseCase>(),
      updatePartQuantity: getIt<UpdateTaskPartQuantityUseCase>(),
      removePart: getIt<RemovePartFromTaskUseCase>(),
      downloadQuotationPdf: getIt<DownloadQuotationPdfUseCase>(),
      sendQuotation: getIt<SendQuotationUseCase>(),
      approveQuotation: getIt<ApproveQuotationUseCase>(),
      rejectQuotation: getIt<RejectQuotationUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      getBranchMechanics: getIt<GetBranchMechanicsUseCase>(),
      reassignTaskMechanic: getIt<ReassignTaskMechanicUseCase>(),
      startOrder: getIt<StartWorkOrderUseCase>(),
      completeOrder: getIt<CompleteWorkOrderUseCase>(),
      cancelOrder: getIt<CancelWorkOrderUseCase>(),
      getPartMovements: getIt<GetPartMovementsUseCase>(),
      observeWorkOrder: getIt<ObserveWorkOrderUseCase>(),
    ),
  );
  getIt.registerFactoryParam<IntakeGalleryViewModel, String, void>(
    (workOrderId, _) => IntakeGalleryViewModel(
      workOrderId: workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      attachPhoto: getIt<AttachIntakePhotoUseCase>(),
      observePending: getIt<ObservePendingIntakePhotosUseCase>(),
      getDetail: getIt<GetWorkOrderDetailUseCase>(),
    ),
  );
  getIt.registerFactoryParam<ProposalsPanelViewModel, String, void>(
    (workOrderId, _) => ProposalsPanelViewModel(
      workOrderId: workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      getDetail: getIt<GetWorkOrderDetailUseCase>(),
      getServices: getIt<GetServiceCatalogUseCase>(),
      notifyProposal: getIt<NotifyProposalUseCase>(),
      approveProposal: getIt<ApproveProposalUseCase>(),
      rejectProposal: getIt<RejectProposalUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      getBranchMechanics: getIt<GetBranchMechanicsUseCase>(),
    ),
  );
  getIt.registerFactoryParam<ReportFindingViewModel, String, void>(
    (workOrderId, _) => ReportFindingViewModel(
      workOrderId: workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      submitProposal: getIt<SubmitProposalUseCase>(),
      observePending: getIt<ObservePendingProposalsUseCase>(),
      getServices: getIt<GetServiceCatalogUseCase>(),
    ),
  );
  getIt.registerFactory<ServicesCatalogViewModel>(
    () => ServicesCatalogViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      refreshServices: getIt<RefreshServiceCatalogUseCase>(),
      createService: getIt<CreateServiceUseCase>(),
      updateService: getIt<UpdateServiceUseCase>(),
      deleteService: getIt<DeleteServiceUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
}
