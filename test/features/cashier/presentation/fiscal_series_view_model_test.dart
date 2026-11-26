import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/configure_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_branch_series_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/get_tenant_fiscal_profile_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/set_series_active_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/application/update_tenant_fiscal_profile_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/series/fiscal_series_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations_es.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSeries extends Mock implements GetBranchSeriesUseCase {}

class _MockConfigure extends Mock implements ConfigureSeriesUseCase {}

class _MockSetActive extends Mock implements SetSeriesActiveUseCase {}

class _MockGetTenant extends Mock implements GetTenantFiscalProfileUseCase {}

class _MockUpdateTenant extends Mock implements UpdateTenantFiscalProfileUseCase {}

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

const _manage = 'invoicing:fiscal_config:manage';
const _tenantRead = 'iam:tenants:read';
const _tenantUpdate = 'iam:tenants:update';

const _f001 = FiscalSeries(
  id: 's1',
  branchId: 'b1',
  type: VoucherType.factura,
  serie: 'F001',
  currentCorrelative: 0,
  active: true,
);

const _tenant = TenantFiscalProfile(
  id: 't1',
  name: 'Taller Suárez',
  legalName: 'Suárez Automotriz S.A.C.',
  taxId: '20123456789',
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockGetSeries getSeries;
  late _MockConfigure configure;
  late _MockSetActive setActive;
  late _MockGetTenant getTenant;
  late _MockUpdateTenant updateTenant;
  late _MockObserveSession observeSession;
  late StreamController<Session?> sessions;
  late StreamController<List<ConnectivityResult>> network;
  late ConnectivityObserver connectivity;
  FiscalSeriesViewModel? created;
  late FiscalSeriesViewModel viewModel;

  setUpAll(() => registerFallbackValue(VoucherType.factura));

  setUp(() async {
    getSeries = _MockGetSeries();
    configure = _MockConfigure();
    setActive = _MockSetActive();
    getTenant = _MockGetTenant();
    updateTenant = _MockUpdateTenant();
    observeSession = _MockObserveSession();
    sessions = StreamController<Session?>.broadcast();
    network = StreamController<List<ConnectivityResult>>.broadcast();
    connectivity = ConnectivityObserver(changes: network.stream, current: () async => [ConnectivityResult.wifi]);
    await connectivity.start();
    when(() => observeSession.execute()).thenAnswer((_) => Stream.value(_session({_manage, _tenantRead, _tenantUpdate})));
    when(() => getSeries.execute()).thenAnswer((_) async => const [_f001]);
    when(() => getTenant.execute()).thenAnswer((_) async => _tenant);
  });

  FiscalSeriesViewModel create({Set<String> permissions = const {_manage, _tenantRead, _tenantUpdate}}) {
    when(() => observeSession.execute()).thenAnswer((_) => Stream.value(_session(permissions)));
    return created = viewModel = FiscalSeriesViewModel(
      observeSession: observeSession,
      getBranchSeries: getSeries,
      configureSeries: configure,
      setSeriesActive: setActive,
      connectivity: connectivity,
      getTenantFiscalProfile: getTenant,
      updateTenantFiscalProfile: updateTenant,
    );
  }

  tearDown(() async {
    try {
      created?.dispose();
    } on Object {
      // Ya liberado dentro de la prueba.
    }
    created = null;
    connectivity.dispose();
    await sessions.close();
    await network.close();
  });

  void stubConfigure(FiscalSeries result) {
    when(
      () => configure.execute(any(), any(), initialCorrelative: any(named: 'initialCorrelative')),
    ).thenAnswer((_) async => result);
  }

  test('carga el perfil fiscal y las series de la sede al crearse', () async {
    create();
    await _settle();

    expect(viewModel.state.series.single.serie, 'F001');
    expect(viewModel.state.tenantProfile?.taxId, '20123456789');
    expect(viewModel.state.hasLoaded, isTrue);
    expect(viewModel.state.isRefreshing, isFalse);
  });

  test('los permisos se leen por separado: series, leer taller y editar taller', () async {
    create(permissions: {_manage});
    await _settle();
    expect(viewModel.state.canManage, isTrue);
    expect(viewModel.state.canReadTenant, isFalse);
    expect(viewModel.state.canUpdateTenant, isFalse);
    verifyNever(() => getTenant.execute());
    viewModel.dispose();
    clearInteractions(getSeries);
    clearInteractions(getTenant);

    create(permissions: {_tenantUpdate});
    await _settle();
    expect(viewModel.state.canManage, isFalse);
    expect(viewModel.state.hasAccess, isTrue);
    // Solo el taller: leer el perfil basta con poder editarlo y no se piden las series.
    verify(() => getTenant.execute()).called(1);
    verifyNever(() => getSeries.execute());
  });

  test('sin ningún permiso no hay acceso', () async {
    create(permissions: {});
    await _settle();
    expect(viewModel.state.hasAccess, isFalse);
  });

  test('E1: agregar una serie válida la activa para la sede y recarga la lista', () async {
    const boleta = FiscalSeries(
      id: 's2',
      branchId: 'b1',
      type: VoucherType.boleta,
      serie: 'B001',
      currentCorrelative: 0,
      active: true,
    );
    stubConfigure(boleta);
    create();
    await _settle();
    when(() => getSeries.execute()).thenAnswer((_) async => const [_f001, boleta]);

    viewModel.onAdd();
    viewModel.onType(VoucherType.boleta);
    viewModel.onSerie('b001');
    await viewModel.onSave();
    await _settle();

    verify(() => configure.execute(VoucherType.boleta, 'B001', initialCorrelative: null)).called(1);
    expect(viewModel.state.sheet, isNull);
    expect(viewModel.state.series.map((s) => s.serie), ['F001', 'B001']);
    expect(viewModel.state.notice?.asString(AppLocalizationsEs()), AppLocalizationsEs().cashierSeriesSaved);
  });

  test('la serie se limpia a 4 caracteres alfanuméricos en mayúsculas y el correlativo a 9 dígitos', () async {
    create();
    await _settle();

    viewModel.onAdd();
    viewModel.onSerie('f-0a1b2');
    viewModel.onInitial('12ab3456789012');

    final form = (viewModel.state.sheet! as CreateSeriesSheet).form;
    expect(form.serie, 'F0A1');
    expect(form.initial, '123456789');
  });

  test('reglas por tipo: F para factura, B para boleta y F o B para nota de crédito', () {
    expect(const SeriesForm(type: VoucherType.factura, serie: 'F001').serieValid, isTrue);
    expect(const SeriesForm(type: VoucherType.factura, serie: 'B001').serieValid, isFalse);
    expect(const SeriesForm(type: VoucherType.boleta, serie: 'B00A').serieValid, isTrue);
    expect(const SeriesForm(type: VoucherType.boleta, serie: 'F001').serieValid, isFalse);
    expect(const SeriesForm(type: VoucherType.notaCredito, serie: 'FC01').serieValid, isTrue);
    expect(const SeriesForm(type: VoucherType.notaCredito, serie: 'BC01').serieValid, isTrue);
    expect(const SeriesForm(type: VoucherType.notaCredito, serie: 'XC01').serieValid, isFalse);
    expect(const SeriesForm(type: VoucherType.boleta, serie: 'B001', initial: '').initialValid, isTrue);
    expect(const SeriesForm(type: VoucherType.boleta, serie: 'B001', initial: '5').initialValid, isTrue);
    expect(const SeriesForm(type: VoucherType.boleta, serie: 'B001', initial: '-3').initialValid, isFalse);
  });

  test('serie que no corresponde al tipo: no se puede guardar ni llega al backend', () async {
    create();
    await _settle();

    viewModel.onAdd();
    viewModel.onType(VoucherType.factura);
    viewModel.onSerie('B001');
    await viewModel.onSave();

    verifyNever(() => configure.execute(any(), any(), initialCorrelative: any(named: 'initialCorrelative')));
    expect((viewModel.state.sheet! as CreateSeriesSheet).form.canSubmit, isFalse);
  });

  test('E2: una serie repetida la rechaza el backend y se muestra su mensaje', () async {
    when(() => configure.execute(any(), any(), initialCorrelative: any(named: 'initialCorrelative'))).thenAnswer(
      (_) async => throw const ApiException(
        httpStatus: 409,
        code: 'DUPLICATE_SERIE',
        message: 'La serie F001 ya existe en esta sede.',
      ),
    );
    create();
    await _settle();

    viewModel.onAdd();
    viewModel.onType(VoucherType.factura);
    viewModel.onSerie('F001');
    await viewModel.onSave();

    expect(viewModel.state.sheetError, const UiText.dynamic('La serie F001 ya existe en esta sede.'));
    expect(viewModel.state.sheet, isA<CreateSeriesSheet>());
    expect(viewModel.state.isSaving, isFalse);
    expect(viewModel.state.series, hasLength(1));
  });

  test('sin conexión no se guarda', () async {
    create();
    await _settle();
    network.add([ConnectivityResult.none]);
    await _settle();

    viewModel.onAdd();
    viewModel.onSerie('B001');
    await viewModel.onSave();

    verifyNever(() => configure.execute(any(), any(), initialCorrelative: any(named: 'initialCorrelative')));
  });

  test('el detalle de la serie la desactiva y recarga', () async {
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

    viewModel.onOpenSeries(_f001);
    expect(viewModel.state.sheet, isA<SeriesDetailSheet>());
    await viewModel.onToggleActive();
    await _settle();

    verify(() => setActive.execute('s1', false)).called(1);
    expect(viewModel.state.sheet, isNull);
    expect(viewModel.state.series.single.active, isFalse);
    expect(viewModel.state.notice?.asString(AppLocalizationsEs()), AppLocalizationsEs().cashierSeriesUpdated);
  });

  test('sin permiso para configurar series no se abre la hoja', () async {
    create(permissions: {_tenantRead});
    await _settle();
    viewModel.onAdd();
    viewModel.onOpenSeries(_f001);
    expect(viewModel.state.sheet, isNull);
  });

  test('editar el taller parte del perfil, valida 1..100 y 1..150 y guarda', () async {
    const updated = TenantFiscalProfile(id: 't1', name: 'Nuevo', legalName: 'Nueva S.A.C.', taxId: '20123456789');
    when(() => updateTenant.execute(any(), any())).thenAnswer((_) async => updated);
    create();
    await _settle();

    viewModel.onEditTenant();
    var form = (viewModel.state.sheet! as EditTenantSheet).form;
    expect(form.name, 'Taller Suárez');
    expect(form.legalName, 'Suárez Automotriz S.A.C.');
    expect(form.taxId, '20123456789');

    viewModel.onTenantName('');
    expect((viewModel.state.sheet! as EditTenantSheet).form.canSubmit, isFalse);
    await viewModel.onSaveTenant();
    verifyNever(() => updateTenant.execute(any(), any()));

    viewModel.onTenantName('x' * 130);
    viewModel.onTenantLegalName('y' * 200);
    form = (viewModel.state.sheet! as EditTenantSheet).form;
    expect(form.name.length, 100);
    expect(form.legalName.length, 150);

    viewModel.onTenantName('Nuevo');
    viewModel.onTenantLegalName('Nueva S.A.C.');
    await viewModel.onSaveTenant();

    verify(() => updateTenant.execute('Nuevo', 'Nueva S.A.C.')).called(1);
    expect(viewModel.state.tenantProfile?.name, 'Nuevo');
    expect(viewModel.state.sheet, isNull);
    expect(viewModel.state.notice?.asString(AppLocalizationsEs()), AppLocalizationsEs().cashierFiscalTenantSaved);
  });

  test('sin razón social el formulario parte del nombre comercial', () async {
    when(() => getTenant.execute()).thenAnswer((_) async => const TenantFiscalProfile(id: 't1', name: 'Taller'));
    create();
    await _settle();

    viewModel.onEditTenant();
    expect((viewModel.state.sheet! as EditTenantSheet).form.legalName, 'Taller');
  });

  test('un error al guardar el taller deja la hoja abierta con el mensaje', () async {
    when(() => updateTenant.execute(any(), any())).thenAnswer(
      (_) async => throw const InvalidCashierInputException('tenantName'),
    );
    create();
    await _settle();

    viewModel.onEditTenant();
    await viewModel.onSaveTenant();

    expect(viewModel.state.sheet, isA<EditTenantSheet>());
    expect(viewModel.state.sheetError?.asString(AppLocalizationsEs()), AppLocalizationsEs().cashierErrTenantName);
    expect(viewModel.state.isSaving, isFalse);
  });

  test('sin permiso para editar el taller no se abre la hoja', () async {
    create(permissions: {_manage, _tenantRead});
    await _settle();
    viewModel.onEditTenant();
    expect(viewModel.state.sheet, isNull);
  });
}
