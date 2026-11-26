import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/deliver_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_exit_pass_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_voucher_document_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_voucher_payments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_credit_note_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/mark_work_order_paid_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/refresh_voucher_status_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/void_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/checkout/work_order_checkout_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/navigation/cashier_nav_graph.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/vouchers/vouchers_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_work_order_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_work_order_use_case.dart';

/// Pantallas de `cashier`: Caja del día, Comprobantes SUNAT, "Cobrar y entregar" de una orden (US37–US39) y
/// Series de comprobantes de la sede (US42).
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
  getIt.registerFactory<FiscalSeriesViewModel>(
    () => FiscalSeriesViewModel(
      observeSession: getIt<ObserveSessionUseCase>(),
      getBranchSeries: getIt<GetBranchSeriesUseCase>(),
      configureSeries: getIt<ConfigureSeriesUseCase>(),
      setSeriesActive: getIt<SetSeriesActiveUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
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
      getPayments: getIt<GetVoucherPaymentsUseCase>(),
      registerPayment: getIt<RegisterPaymentUseCase>(),
      markPaid: getIt<MarkWorkOrderPaidUseCase>(),
      downloadExitPass: getIt<DownloadExitPassUseCase>(),
      deliverVehicle: getIt<DeliverVehicleUseCase>(),
      connectivity: getIt<ConnectivityObserver>(),
      downloadVoucherDocument: getIt<DownloadVoucherDocumentUseCase>(),
      refreshVoucherStatus: getIt<RefreshVoucherStatusUseCase>(),
    ),
  );
}
