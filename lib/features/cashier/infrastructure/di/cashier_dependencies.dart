import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/deliver_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_exit_pass_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_voucher_payments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/mark_work_order_paid_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/cashier_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/local/voucher_dao.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/infrastructure/remote/cashier_api.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

void setupCashierDependencies() {
  getIt.registerLazySingleton<VoucherDao>(
    () => getIt<AppDatabase>().voucherDao,
  );
  getIt.registerLazySingleton<CashierApi>(
    () => CashierApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CashierRepository>(
    () => CashierRepositoryImpl(
      api: getIt<CashierApi>(),
      voucherDao: getIt<VoucherDao>(),
      session: getIt<SessionManager>(),
    ),
  );

  getIt.registerLazySingleton<PrepareVoucherUseCase>(
    () => PrepareVoucherUseCase(
      workOrders: getIt<WorkOrderRepository>(),
      reception: getIt<ReceptionRepository>(),
      inventory: getIt<InventoryRepository>(),
    ),
  );
  getIt.registerLazySingleton<IssueVoucherUseCase>(
    () => IssueVoucherUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<GetWorkOrderVouchersUseCase>(
    () => GetWorkOrderVouchersUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<ObserveWorkOrderVouchersUseCase>(
    () =>
        ObserveWorkOrderVouchersUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<RegisterPaymentUseCase>(
    () => RegisterPaymentUseCase(
      repository: getIt<CashierRepository>(),
      workOrders: getIt<WorkOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<GetVoucherPaymentsUseCase>(
    () => GetVoucherPaymentsUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<GetDailyCashSummaryUseCase>(
    () => GetDailyCashSummaryUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<MarkWorkOrderPaidUseCase>(
    () => MarkWorkOrderPaidUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<DownloadExitPassUseCase>(
    () => DownloadExitPassUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<DeliverVehicleUseCase>(
    () => DeliverVehicleUseCase(repository: getIt<WorkOrderRepository>()),
  );
  getIt.registerLazySingleton<GetBranchSeriesUseCase>(
    () => GetBranchSeriesUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<ConfigureSeriesUseCase>(
    () => ConfigureSeriesUseCase(repository: getIt<CashierRepository>()),
  );
  getIt.registerLazySingleton<SetSeriesActiveUseCase>(
    () => SetSeriesActiveUseCase(repository: getIt<CashierRepository>()),
  );
}
