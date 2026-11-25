import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_voucher_document_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/refresh_voucher_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/navigation/cashier_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';

/// Pantallas de `cashier`: Caja del día, Comprobantes SUNAT y Facturación de orden (US37).
/// Series fiscales (US42) y pasos de cobro/entrega (US38/US39) quedan excluidos.
void setupCashierPresentation() {
  registerCashierRoutes();

  getIt.registerFactory<DailyCashViewModel>(
    () => DailyCashViewModel(
      getDailyCashSummary: getIt<GetDailyCashSummaryUseCase>(),
      observeSession: getIt<ObserveSessionUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );
  getIt.registerFactory<VouchersViewModel>(
    () => VouchersViewModel(
      getVouchers: getIt<GetVouchersUseCase>(),
      voidVoucher: getIt<VoidVoucherUseCase>(),
      issueCreditNote: getIt<IssueCreditNoteUseCase>(),
      observeSession: getIt<ObserveSessionUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      downloadVoucherDocument: getIt<DownloadVoucherDocumentUseCase>(),
      refreshVoucherStatus: getIt<RefreshVoucherStatusUseCase>(),
      getBranchSeries: getIt<GetBranchSeriesUseCase>(),
    ),
  );
  getIt.registerFactoryParam<WorkOrderCheckoutViewModel, String, void>(
    (workOrderId, _) => WorkOrderCheckoutViewModel(
      workOrderId: workOrderId,
      observeSession: getIt<ObserveSessionUseCase>(),
      observeOrder: getIt<ObserveWorkOrderUseCase>(),
      getWorkOrderDetail: getIt<GetWorkOrderDetailUseCase>(),
      observeVouchers: getIt<ObserveWorkOrderVouchersUseCase>(),
      getVouchers: getIt<GetWorkOrderVouchersUseCase>(),
      prepareVoucher: getIt<PrepareVoucherUseCase>(),
      issueVoucher: getIt<IssueVoucherUseCase>(),
      voidVoucher: getIt<VoidVoucherUseCase>(),
      issueCreditNote: getIt<IssueCreditNoteUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      downloadVoucherDocument: getIt<DownloadVoucherDocumentUseCase>(),
      refreshVoucherStatus: getIt<RefreshVoucherStatusUseCase>(),
    ),
  );
}
