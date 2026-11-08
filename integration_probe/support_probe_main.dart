import 'dart:async';
import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/refresh_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/deliver_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/download_exit_pass_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_voucher_payments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/issue_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/mark_work_order_paid_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/observe_work_order_vouchers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/prepare_voucher_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/register_payment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_cash_flow_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_fleet_health_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Prueba del paso 9 con Drift real, contra `tool/sync_mock_server.dart`. No se publica.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final session = getIt<SessionManager>();
  await session.clearIfReinstalled();

  if (await session.getSession() == null) {
    final seed = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/control/session'),
    );
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(utf8.decode(seed.bodyBytes))),
    );
    await session.updateAssignment('probe-branch', 'probe-shift');
    debugPrint('PROBE sesión sembrada');
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('En linea', _guarded(_online)),
              _button('Sin red', _guarded(_offline)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _button(String label, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      height: 96,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    ),
  );
}

VoidCallback _guarded(Future<void> Function() run) {
  return () async {
    try {
      await run();
    } catch (error, stack) {
      debugPrint('PROBE FALLA excepción $error\n$stack');
    }
  };
}

void _check(String name, bool passed, [Object? detail]) {
  debugPrint('PROBE ${passed ? 'OK' : 'FALLA'} $name ${detail ?? ''}');
}

Future<Map<String, dynamic>> _stats([String query = '']) async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/control/support$query'),
  );
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Object?> _error(Future<Object?> Function() run) async {
  try {
    await run();
    return null;
  } catch (error) {
    return error;
  }
}

final _order = WorkOrderId('sw1');

Future<void> _online() async {
  await _bays();
  await _cashier();
  await _reports();
  await _team();
  debugPrint('PROBE en linea terminado');
}

Future<void> _bays() async {
  await getIt<RefreshBayBoardUseCase>().execute();
  final board = await getIt<ObserveBayBoardUseCase>()
      .execute()
      .firstWhere((items) => items.any((i) => i.occupant?.laborElapsed != null))
      .timeout(const Duration(seconds: 10));
  final occupant = board.firstWhere((i) => i.occupant != null).occupant!;
  _check(
    'tablero con orden, mecánico y tiempo',
    occupant.internalNumber == 900 &&
        occupant.mechanicIds.single == 'probe-membership' &&
        occupant.laborElapsed!.inMinutes >= 29,
    '${occupant.internalNumber} ${occupant.mechanicIds} ${occupant.laborElapsed}',
  );

  BayBoardItem bay(String name) => board.firstWhere((i) => i.bay.name == name);
  final reassign = getIt<ReassignBayUseCase>();
  final blocked = await _error(
    () => reassign.execute('sw1', bay('Bahía C').bay),
  );
  _check(
    'bahía en mantenimiento bloqueada sin llamar',
    blocked is BayUnavailableException &&
        (await _stats())['bayOf']['sb1'] == 'sw1',
    blocked,
  );
  await reassign.execute('sw1', bay('Bahía B').bay);
  final moved = (await _stats())['bayOf'];
  _check(
    'traslado a bahía libre',
    moved['sb2'] == 'sw1' && moved['sb1'] == null,
    moved,
  );
  final again = await _error(() => reassign.execute('sw1', bay('Bahía B').bay));
  _check(
    'bahía ya ocupada da 409',
    again is ApiException && again.httpStatus == 409,
    again,
  );

  final ticks = <Object?>[];
  final subscription = getIt<PollBayBoardUseCase>().execute().listen(ticks.add);
  await Future<void>.delayed(const Duration(seconds: 3));
  await subscription.cancel();
  _check('sondeo refresca al empezar', ticks.length == 1, ticks.length);
}

Future<void> _cashier() async {
  var draft = await getIt<PrepareVoucherUseCase>().execute(_order);
  _check(
    'borrador boleta con DNI (H27)',
    draft.type == VoucherType.boleta &&
        draft.customerInfo.documentType == FiscalDocumentType.dni,
    draft.type,
  );
  _check(
    'IGV por línea (H26)',
    draft.lines.map((l) => l.unitPriceWithIgv).join(',') == '118,11.8' &&
        draft.total == Decimal.parse('141.6'),
    draft.total,
  );

  final issue = getIt<IssueVoucherUseCase>();
  final generic = await _error(() => issue.execute(draft));
  _check(
    'repuesto sin nombre bloquea emitir (H26)',
    generic is InvalidCashierInputException && generic.field == 'lines',
    generic,
  );
  draft = draft.copyWith(
    lines: [
      for (final line in draft.lines)
        line.needsDescription
            ? line.copyWith(description: 'Filtro de aceite')
            : line,
    ],
  );

  await _stats('?drop=issue');
  final issued = await issue.execute(draft);
  var stats = await _stats();
  _check(
    'corte tras emitir: se recupera sin duplicar (H28)',
    issued is Issued && stats['issuePosts'] == 1 && stats['vouchers'] == 1,
    '$issued $stats',
  );
  final repeated = await issue.execute(draft);
  stats = await _stats();
  _check(
    'segunda emisión: AlreadyIssued sin POST',
    repeated is AlreadyIssued && stats['issuePosts'] == 1,
    stats,
  );

  final voucherId = issued.voucherId;
  final pay = getIt<RegisterPaymentUseCase>();
  await _stats('?drop=payment');
  final unknown = await _error(
    () => pay.execute(voucherId, Decimal.parse('41.6'), PaymentMethod.cash),
  );
  final history = await getIt<GetVoucherPaymentsUseCase>().execute(voucherId);
  stats = await _stats();
  _check(
    'corte tras cobrar: resultado desconocido, un solo cobro (H28)',
    unknown is PaymentOutcomeUnknownException &&
        history.length == 1 &&
        stats['paymentPosts'] == 1,
    '$unknown $stats',
  );

  final unpaidPass = await _error(
    () => getIt<DownloadExitPassUseCase>().execute(_order),
  );
  _check(
    'pase de salida con saldo da 422',
    unpaidPass is ApiException && unpaidPass.httpStatus == 422,
    unpaidPass,
  );
  final early = await _error(
    () => getIt<MarkWorkOrderPaidUseCase>().execute(_order),
  );
  _check(
    'pago formal con saldo da 422',
    early is ApiException && early.httpStatus == 422,
    early,
  );

  final current = (await getIt<GetWorkOrderVouchersUseCase>().execute('sw1'))
      .single;
  final tooMuch = await _error(
    () => pay.execute(
      voucherId,
      current.pendingBalance.amount + Decimal.one,
      PaymentMethod.cash,
    ),
  );
  _check(
    'no cobra más que el saldo',
    tooMuch is InvalidCashierInputException && tooMuch.field == 'amount',
    tooMuch,
  );
  final paid = await pay.execute(
    voucherId,
    current.pendingBalance.amount,
    PaymentMethod.yape,
    transactionReference: 'OP-1',
  );
  _check(
    'saldo cobrado',
    paid.paymentStatus == VoucherPaymentStatus.paid,
    paid.pendingBalance.amount,
  );
  final cached = await getIt<ObserveWorkOrderVouchersUseCase>()
      .execute('sw1')
      .first;
  _check(
    'cabecera en caché al día',
    cached.single.pendingBalance == Decimal.zero,
    cached.single.pendingBalance,
  );

  final summary = await getIt<GetDailyCashSummaryUseCase>().execute(
    const BusinessTime().today(),
  );
  _check(
    'caja del día',
    summary.paymentCount == 2 &&
        summary.totalCollected.amount == Decimal.parse('141.6'),
    summary.totalCollected.amount,
  );

  final order = await getIt<MarkWorkOrderPaidUseCase>().execute(_order);
  final pass = await getIt<DownloadExitPassUseCase>().execute(_order);
  _check(
    'pagada y pase de salida',
    order.status?.value == 'PAID' && pass.lengthSync() > 0,
    pass.path,
  );
  await getIt<DeliverVehicleUseCase>().execute(_order);
  _check(
    'entrega libera la bahía (H29 sin firma)',
    (await _stats())['bayOf']['sb2'] == null,
  );

  final configure = getIt<ConfigureSeriesUseCase>();
  final created = await configure.execute(VoucherType.factura, 'F001');
  final duplicate = await _error(
    () => configure.execute(VoucherType.factura, 'F001'),
  );
  _check(
    'serie nueva y repetida 409',
    created.serie == 'F001' &&
        duplicate is ApiException &&
        duplicate.httpStatus == 409,
    duplicate,
  );
}

Future<void> _reports() async {
  final period = ReportPeriod.currentMonth(const BusinessTime());
  final flow = await getIt<GetCashFlowSummaryUseCase>().execute(period);
  _check(
    'flujo de caja (H31 en 0)',
    flow.totalIncome.amount == Decimal.parse('141.6') &&
        flow.movements.length == 2,
    flow.totalIncome.amount,
  );
  final pdf = await getIt<DownloadCashFlowPdfUseCase>().execute(period);
  _check(
    'PDF de flujo de caja',
    pdf.path.endsWith('flujo-de-caja-${period.from}-${period.to}.pdf'),
    pdf.path,
  );
  final fleet = await getIt<DownloadFleetHealthPdfUseCase>().execute('rc1');
  final other = await _error(
    () => getIt<DownloadFleetHealthPdfUseCase>().execute('nadie'),
  );
  _check(
    'PDF de flota y 404 de otro taller',
    fleet.lengthSync() > 0 && other is ApiException && other.httpStatus == 404,
    other,
  );
}

Future<void> _team() async {
  final today = const BusinessTime().today();
  final daily = await getIt<GetBranchDailyAttendanceUseCase>().execute(today);
  _check(
    'asistencia del día con ausente sin ingreso (H44)',
    daily.length == 2 &&
        daily.last.clockIn == null &&
        daily.first.jobTitle == 'Mecánico',
    daily.map((d) => d.jobTitle).toList(),
  );
  final pending = await getIt<GetPendingJustificationsUseCase>().execute();
  _check(
    'bandeja de 7 días con un día fallido (H32)',
    pending.items.single.id == 'sa1' &&
        pending.failedDates.single == BusinessTime.addDays(today, -2),
    pending.failedDates,
  );
  final approved = await getIt<ApproveJustificationUseCase>().execute('sa1');
  _check(
    'descargo aprobado',
    !approved.awaitsReview && approved.status?.apiName == 'EXCUSED',
  );
}

/// Con Wi-Fi, datos y `adb reverse` cortados.
Future<void> _offline() async {
  final refresh = await _error(() => getIt<RefreshBayBoardUseCase>().execute());
  final board = await getIt<ObserveBayBoardUseCase>().execute().first.timeout(
    const Duration(seconds: 5),
  );
  _check(
    'sin red: tablero desde la caché',
    refresh is NetworkException && board.length == 3,
    '$refresh ${board.length}',
  );
  final cached = await getIt<ObserveWorkOrderVouchersUseCase>()
      .execute('sw1')
      .first;
  _check(
    'sin red: comprobantes desde la caché',
    cached.length == 1,
    cached.length,
  );
  final pay = await _error(
    () => getIt<RegisterPaymentUseCase>().execute(
      cached.single.id,
      Decimal.one,
      PaymentMethod.cash,
    ),
  );
  _check(
    'sin red: cobrar falla antes del POST, no queda incierto',
    pay is NetworkException,
    pay,
  );
  final report = await _error(
    () => getIt<GetCashFlowSummaryUseCase>().execute(ReportPeriod.year(2026)),
  );
  _check('sin red: reporte en línea', report is NetworkException, report);
  debugPrint('PROBE sin red terminado');
}
