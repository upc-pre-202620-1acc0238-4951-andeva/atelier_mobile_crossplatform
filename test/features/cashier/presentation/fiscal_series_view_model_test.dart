import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations_es.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSeries extends Mock implements GetBranchSeriesUseCase {}

class _MockConfigure extends Mock implements ConfigureSeriesUseCase {}

class _MockSetActive extends Mock implements SetSeriesActiveUseCase {}

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

const _f001 = FiscalSeries(
  id: 's1',
  branchId: 'b1',
  type: VoucherType.factura,
  serie: 'F001',
  currentCorrelative: 0,
  active: true,
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockGetSeries getSeries;
  late _MockConfigure configure;
  late _MockSetActive setActive;
  late _MockObserveSession observeSession;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  late FiscalSeriesViewModel viewModel;

  setUp(() async {
    getSeries = _MockGetSeries();
    configure = _MockConfigure();
    setActive = _MockSetActive();
    observeSession = _MockObserveSession();
    sessions = StreamController<Session?>();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(
      changes: network.stream,
      current: () async => [ConnectivityResult.wifi],
    );
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => sessions.stream);
    when(() => getSeries.execute()).thenAnswer((_) async => const [_f001]);
  });

  FiscalSeriesViewModel create() => viewModel = FiscalSeriesViewModel(
    observeSession: observeSession,
    getBranchSeries: getSeries,
    configureSeries: configure,
    setSeriesActive: setActive,
    connectivity: connectivity,
  );

  tearDown(() async {
    viewModel.dispose();
    connectivity.dispose();
    await sessions.close();
    await network.close();
  });

  test('carga las series de la sede al crearse', () async {
    create();
    await _settle();

    expect(viewModel.state.series.single.serie, 'F001');
    expect(viewModel.state.isLoading, isFalse);
  });

  test('solo quien tiene fiscal_config:manage puede configurar', () async {
    create();
    sessions.add(_session({}));
    await _settle();
    expect(viewModel.state.canManage, isFalse);

    sessions.add(_session({'invoicing:fiscal_config:manage'}));
    await _settle();
    expect(viewModel.state.canManage, isTrue);
  });

  test(
    'E1: agregar una serie válida la activa para la sede y recarga la lista',
    () async {
      const boleta = FiscalSeries(
        id: 's2',
        branchId: 'b1',
        type: VoucherType.boleta,
        serie: 'B001',
        currentCorrelative: 0,
        active: true,
      );
      when(
        () => configure.execute(
          any(),
          any(),
          initialCorrelative: any(named: 'initialCorrelative'),
        ),
      ).thenAnswer((_) async => boleta);
      create();
      await _settle();
      when(() => getSeries.execute())
          .thenAnswer((_) async => const [_f001, boleta]);

      viewModel.onOpenSheet();
      viewModel.onTypeChange(VoucherType.boleta);
      viewModel.onSerieChange('b001');
      await viewModel.onConfirm();
      await _settle();

      verify(
        () => configure.execute(
          VoucherType.boleta,
          'B001',
          initialCorrelative: null,
        ),
      ).called(1);
      expect(viewModel.state.showSheet, isFalse);
      expect(viewModel.state.series.map((s) => s.serie), ['F001', 'B001']);
      expect(
        viewModel.state.banner?.asString(AppLocalizationsEs()),
        contains('B001'),
      );
    },
  );

  test(
    'serie que no corresponde al tipo: error en el campo y no llama al backend',
    () async {
      create();
      await _settle();

      viewModel.onOpenSheet();
      viewModel.onSerieChange('B001'); // tipo factura pide F
      await viewModel.onConfirm();

      verifyNever(
        () => configure.execute(
          any(),
          any(),
          initialCorrelative: any(named: 'initialCorrelative'),
        ),
      );
      expect(viewModel.state.serieError, isNotNull);
      expect(viewModel.state.showSheet, isTrue);
    },
  );

  test(
    'correlativo inicial negativo o no numérico se rechaza en el campo',
    () async {
      create();
      await _settle();

      viewModel.onOpenSheet();
      viewModel.onSerieChange('F002');
      viewModel.onInitialChange('-3');
      await viewModel.onConfirm();

      expect(viewModel.state.initialError, isNotNull);
      verifyNever(
        () => configure.execute(
          any(),
          any(),
          initialCorrelative: any(named: 'initialCorrelative'),
        ),
      );
    },
  );

  test(
    'E2: una serie repetida la rechaza el backend y se muestra su mensaje',
    () async {
      when(
        () => configure.execute(
          any(),
          any(),
          initialCorrelative: any(named: 'initialCorrelative'),
        ),
      ).thenAnswer(
        (_) async => throw const ApiException(
          httpStatus: 409,
          code: 'DUPLICATE_SERIE',
          message: 'La serie F001 ya existe en esta sede.',
        ),
      );
      create();
      await _settle();

      viewModel.onOpenSheet();
      viewModel.onSerieChange('F001');
      await viewModel.onConfirm();

      expect(
        viewModel.state.formError,
        const UiText.dynamic('La serie F001 ya existe en esta sede.'),
      );
      expect(viewModel.state.showSheet, isTrue);
      expect(viewModel.state.isSaving, isFalse);
      expect(viewModel.state.series, hasLength(1));
    },
  );

  test('activar o desactivar una serie llama al backend y recarga', () async {
    when(() => setActive.execute(any(), any())).thenAnswer((_) async {});
    create();
    await _settle();
    const off = FiscalSeries(
      id: 's1',
      branchId: 'b1',
      type: VoucherType.factura,
      serie: 'F001',
      currentCorrelative: 0,
      active: false,
    );
    when(() => getSeries.execute()).thenAnswer((_) async => const [off]);

    await viewModel.onToggleActive(_f001);
    await _settle();

    verify(() => setActive.execute('s1', false)).called(1);
    expect(viewModel.state.series.single.active, isFalse);
    expect(viewModel.state.togglingId, isNull);
  });
}
