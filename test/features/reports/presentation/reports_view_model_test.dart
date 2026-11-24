import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/get_cash_flow_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetCashFlow extends Mock implements GetCashFlowSummaryUseCase {}

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _FakePeriod extends Fake implements ReportPeriod {}

Session _session(Set<String> permissions) => Session(
  userId: 'u1',
  email: 'a@b.pe',
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: permissions,
  plan: null,
);

CashFlowSummary _summary() => CashFlowSummary(
  totalIncome: Money.of('100.00', 'PEN'),
  totalExpenses: Money.of('0.00', 'PEN'),
  accountsReceivable: Money.of('0.00', 'PEN'),
  netCashFlow: Decimal.parse('100.00'),
  currency: 'PEN',
  movements: const [],
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(() => registerFallbackValue(_FakePeriod()));

  late _MockGetCashFlow getCashFlow;
  late _MockObserveSession observeSession;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  ReportsViewModel? viewModel;

  Future<void> create() async {
    viewModel?.dispose();
    viewModel = ReportsViewModel(
      getCashFlow: getCashFlow,
      observeSession: observeSession,
      connectivity: connectivity,
      // 02:00 UTC del 16 de noviembre es el 15 en Lima (UTC−5).
      now: () => DateTime.utc(2026, 11, 16, 2),
    );
  }

  setUp(() async {
    getCashFlow = _MockGetCashFlow();
    observeSession = _MockObserveSession();
    sessions = StreamController<Session?>();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
  });

  tearDown(() async {
    viewModel?.dispose();
    viewModel = null;
    connectivity.dispose();
    await sessions.close();
    await network.close();
  });

  test('arranca en el mes en curso según el día de Lima', () async {
    await create();

    expect(viewModel!.state.today, '2026-11-15');
    expect(viewModel!.state.choice, PeriodChoice.thisMonth);
    expect(viewModel!.state.period.from, '2026-11-01');
    expect(viewModel!.state.period.to, '2026-11-30');
  });

  test('carga al recibir el permiso y no sin él', () async {
    when(() => getCashFlow.execute(any())).thenAnswer((_) async => _summary());
    await create();

    sessions.add(_session({}));
    await _settle();
    verifyNever(() => getCashFlow.execute(any()));
    expect(viewModel!.state.hasAnyAccess, isFalse);

    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();
    verify(() => getCashFlow.execute(any())).called(1);
    expect(viewModel!.state.canReadCashFlow, isTrue);
    expect(viewModel!.state.summary, isNotNull);
    expect(viewModel!.state.isLoading, isFalse);
  });

  test('un fallo deja el mensaje del backend y sin resumen', () async {
    when(() => getCashFlow.execute(any())).thenAnswer((_) async => throw const ApiException(httpStatus: 500, code: 'E', message: 'Reporte caído'));
    await create();

    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();

    expect(viewModel!.state.summary, isNull);
    expect(viewModel!.state.error, isNotNull);
    expect(viewModel!.state.isLoading, isFalse);
  });

  test('cambiar de periodo recalcula el rango y vuelve a cargar', () async {
    when(() => getCashFlow.execute(any())).thenAnswer((_) async => _summary());
    await create();
    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();

    viewModel!.onChoice(PeriodChoice.previousMonth);
    expect(viewModel!.state.period.from, '2026-10-01');
    expect(viewModel!.state.period.to, '2026-10-31');
    expect(viewModel!.state.summary, isNull);
    await _settle();

    viewModel!.onChoice(PeriodChoice.thisYear);
    expect(viewModel!.state.period.from, '2026-01-01');
    expect(viewModel!.state.period.to, '2026-12-31');
    await _settle();
    verify(() => getCashFlow.execute(any())).called(3);

    // Elegir el mismo periodo no recarga.
    viewModel!.onChoice(PeriodChoice.thisYear);
    await _settle();
    verifyNever(() => getCashFlow.execute(any()));
  });

  test('el mes pasado de enero es diciembre del año anterior', () async {
    await create();
    final january = periodFor(PeriodChoice.previousMonth, '2026-01-10');

    expect(january.from, '2025-12-01');
    expect(january.to, '2025-12-31');
  });

  test('rango personalizado: ordena los extremos y sin fin usa el inicio', () async {
    when(() => getCashFlow.execute(any())).thenAnswer((_) async => _summary());
    await create();
    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();

    viewModel!.onOpenCustomRange();
    expect(viewModel!.state.showCustomRangePicker, isTrue);

    viewModel!.onCustomRangePicked(DateTime(2026, 11, 20), DateTime(2026, 11, 5));
    expect(viewModel!.state.showCustomRangePicker, isFalse);
    expect(viewModel!.state.choice, const CustomChoice('2026-11-05', '2026-11-20'));
    expect(viewModel!.state.period.from, '2026-11-05');
    expect(viewModel!.state.period.to, '2026-11-20');
    await _settle();

    viewModel!.onCustomRangePicked(DateTime(2026, 3, 9), null);
    expect(viewModel!.state.period.from, '2026-03-09');
    expect(viewModel!.state.period.to, '2026-03-09');
    await _settle();

    viewModel!.onOpenCustomRange();
    viewModel!.onDismissCustomRange();
    expect(viewModel!.state.showCustomRangePicker, isFalse);
  });

  test('al volver la red sin datos reintenta; con datos no', () async {
    var calls = 0;
    when(() => getCashFlow.execute(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const ApiException(httpStatus: 500, code: 'E', message: 'caído');
      return _summary();
    });
    await create();
    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();
    expect(viewModel!.state.summary, isNull);

    network.add([ConnectivityResult.none]);
    await _settle();
    expect(viewModel!.state.isOnline, isFalse);

    network.add([ConnectivityResult.wifi]);
    await _settle();
    await _settle();
    expect(viewModel!.state.isOnline, isTrue);
    expect(calls, 2);
    expect(viewModel!.state.summary, isNotNull);
  });

  test('una respuesta vieja no pisa a la última carga', () async {
    final first = Completer<CashFlowSummary>();
    final second = Completer<CashFlowSummary>();
    final answers = [first, second];
    when(() => getCashFlow.execute(any())).thenAnswer((_) => answers.removeAt(0).future);
    await create();
    sessions.add(_session({'invoicing:cashflow:export_pdf'}));
    await _settle();

    viewModel!.onChoice(PeriodChoice.thisYear);
    await _settle();
    second.complete(_summary());
    await _settle();
    first.completeError(const ApiException(httpStatus: 500, code: 'E', message: 'tarde'));
    await _settle();

    expect(viewModel!.state.summary, isNotNull);
    expect(viewModel!.state.error, isNull);
  });
}
