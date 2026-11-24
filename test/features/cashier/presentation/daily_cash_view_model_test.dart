import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_daily_cash_summary_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations_es.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetDaily extends Mock implements GetDailyCashSummaryUseCase {}

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

Session _session(Set<String> permissions) => Session(
  userId: 'u1',
  email: 'a@b.pe',
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: permissions,
  plan: null,
  branchId: 'b1',
);

DailyCashSummary _summary(String date) => DailyCashSummary(
  date: date,
  totalCollected: Money.of('10.00', 'PEN'),
  paymentCount: 0,
  byMethod: const {},
  payments: const [],
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockGetDaily getDaily;
  late _MockObserveSession observeSession;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  late DailyCashViewModel viewModel;

  void create() {
    viewModel = DailyCashViewModel(
      getDailyCashSummary: getDaily,
      observeSession: observeSession,
      connectivity: connectivity,
      // 02:00 UTC del 16 de noviembre es el 15 en Lima (UTC−5).
      now: () => DateTime.utc(2026, 11, 16, 2),
    );
  }

  setUp(() async {
    getDaily = _MockGetDaily();
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
    viewModel.dispose();
    connectivity.dispose();
    await sessions.close();
    await network.close();
  });

  test('carga el día de hoy de Lima al crearse', () async {
    when(() => getDaily.execute(any())).thenAnswer((invocation) async => _summary(invocation.positionalArguments[0] as String));
    create();
    expect(viewModel.state.isLoading, isTrue);
    await _settle();

    verify(() => getDaily.execute('2026-11-15')).called(1);
    expect(viewModel.state.summary?.date, '2026-11-15');
    expect(viewModel.state.isLoading, isFalse);
    expect(viewModel.state.isToday, isTrue);
    expect(viewModel.state.canGoNext, isFalse);
  });

  test('el permiso de leer comprobantes habilita la pantalla', () async {
    when(() => getDaily.execute(any())).thenAnswer((_) async => _summary('2026-11-15'));
    create();

    sessions.add(_session({}));
    await _settle();
    expect(viewModel.state.canRead, isFalse);

    sessions.add(_session({'invoicing:invoices:read'}));
    await _settle();
    expect(viewModel.state.canRead, isTrue);
  });

  test('día anterior, siguiente y hoy cambian la fecha y recargan', () async {
    when(() => getDaily.execute(any())).thenAnswer((invocation) async => _summary(invocation.positionalArguments[0] as String));
    create();
    await _settle();

    viewModel.onPreviousDay();
    expect(viewModel.state.date, '2026-11-14');
    expect(viewModel.state.summary, isNull);
    expect(viewModel.state.canGoNext, isTrue);
    await _settle();
    expect(viewModel.state.summary?.date, '2026-11-14');

    viewModel.onNextDay();
    expect(viewModel.state.date, '2026-11-15');
    await _settle();

    // No se pasa de hoy.
    viewModel.onNextDay();
    expect(viewModel.state.date, '2026-11-15');

    viewModel.onPreviousDay();
    viewModel.onPreviousDay();
    expect(viewModel.state.date, '2026-11-13');
    viewModel.onToday();
    expect(viewModel.state.date, '2026-11-15');
    await _settle();
  });

  test('un fallo propio de caja usa el texto de la app; el del backend, su mensaje', () async {
    when(() => getDaily.execute(any())).thenAnswer((_) async => throw const MissingBranchException());
    create();
    await _settle();
    final strings = AppLocalizationsEs();

    expect(viewModel.state.summary, isNull);
    expect(viewModel.state.error?.asString(strings), strings.cashierErrNoBranch);

    when(() => getDaily.execute(any())).thenAnswer(
      (_) async => throw const ApiException(httpStatus: 500, code: 'E', message: 'Caja caída'),
    );
    await viewModel.load();
    expect(viewModel.state.error?.asString(strings), 'Caja caída');
  });

  test('al volver la red sin datos reintenta', () async {
    var calls = 0;
    when(() => getDaily.execute(any())).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const ApiException(httpStatus: 503, code: 'E', message: 'sin servicio');
      return _summary('2026-11-15');
    });
    create();
    await _settle();
    expect(viewModel.state.summary, isNull);

    network.add([ConnectivityResult.none]);
    await _settle();
    network.add([ConnectivityResult.wifi]);
    await _settle();
    await _settle();

    expect(calls, 2);
    expect(viewModel.state.summary, isNotNull);
  });
}
