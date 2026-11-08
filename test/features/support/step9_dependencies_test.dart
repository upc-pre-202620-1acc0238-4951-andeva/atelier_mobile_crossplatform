import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/refresh_bay_board_use_case.dart';
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
import 'package:atelier_mobile_crossplatform/features/reports/application/download_cash_flow_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_fleet_health_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_collaborator_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('dependencias', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      FlutterSecureStorage.setMockInitialValues({});
      setupDependencies();
      getIt.unregister<AppDatabase>();
      getIt.registerLazySingleton<AppDatabase>(
        () => AppDatabase(NativeDatabase.memory()),
        dispose: (database) => database.close(),
      );
    });

    tearDown(() => getIt.reset());

    test(
      'los 26 casos de uso del paso 9 se resuelven; tasks sigue usando bahías',
      () {
        final useCases = <Object>[
          getIt<RefreshBayBoardUseCase>(),
          getIt<ObserveBayBoardUseCase>(),
          getIt<PollBayBoardUseCase>(),
          getIt<ReassignBayUseCase>(),
          getIt<ReassignTaskMechanicUseCase>(),
          getIt<PrepareVoucherUseCase>(),
          getIt<IssueVoucherUseCase>(),
          getIt<GetWorkOrderVouchersUseCase>(),
          getIt<ObserveWorkOrderVouchersUseCase>(),
          getIt<RegisterPaymentUseCase>(),
          getIt<GetVoucherPaymentsUseCase>(),
          getIt<GetDailyCashSummaryUseCase>(),
          getIt<MarkWorkOrderPaidUseCase>(),
          getIt<DownloadExitPassUseCase>(),
          getIt<DeliverVehicleUseCase>(),
          getIt<GetBranchSeriesUseCase>(),
          getIt<ConfigureSeriesUseCase>(),
          getIt<SetSeriesActiveUseCase>(),
          getIt<GetCashFlowSummaryUseCase>(),
          getIt<DownloadCashFlowPdfUseCase>(),
          getIt<DownloadFleetHealthPdfUseCase>(),
          getIt<GetBranchDailyAttendanceUseCase>(),
          getIt<GetPendingJustificationsUseCase>(),
          getIt<GetCollaboratorAttendanceUseCase>(),
          getIt<ApproveJustificationUseCase>(),
          getIt<RejectJustificationUseCase>(),
        ];
        expect(useCases, hasLength(26));
        expect(getIt<TaskRepository>(), isNotNull);
      },
    );
  });

  for (final feature in ['bays', 'cashier', 'reports', 'team']) {
    test(
      'domain de $feature no importa Flutter, http, Drift, get_it ni plugins',
      () {
        final imports = RegExp(
          r'''^\s*(import|export)\s+['"]([^'"]+)['"]''',
          multiLine: true,
        );
        // Un dominio puede usar el de otra feature (p. ej. caja lee la orden de workorders).
        final domain = RegExp(
          r'^package:atelier_mobile_crossplatform/(core|features/\w+)/domain/',
        );
        final files = Directory('lib/features/$feature/domain')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'));
        expect(files, isNotEmpty);
        for (final file in files) {
          for (final match in imports.allMatches(file.readAsStringSync())) {
            final uri = match.group(2)!;
            final allowed =
                uri.startsWith('dart:') ||
                domain.hasMatch(uri) ||
                uri == 'package:decimal/decimal.dart' ||
                !uri.startsWith('package:');
            expect(allowed, isTrue, reason: '${file.path} importa $uri');
          }
        }
      },
    );
  }
}
