import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/create_work_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/release_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/restore_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/set_bay_maintenance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_screen.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements BayRepository {}

class _ObserveSession extends Mock implements ObserveSessionUseCase {}

class _ObserveOrders extends Mock implements ObserveBranchWorkOrdersUseCase {}

class _RefreshOrders extends Mock implements RefreshBranchWorkOrdersUseCase {}

class _Mechanics extends Mock implements GetBranchMechanicsUseCase {}

const _free = WorkBay(id: 'b1', branchId: 's', name: 'Elevador 1', status: BayStatus.available);
const _busy = WorkBay(
  id: 'b2',
  branchId: 's',
  name: 'Elevador 2',
  status: BayStatus.occupied,
  currentWorkOrderId: 'wo1',
);
const _broken = WorkBay(id: 'b3', branchId: 's', name: 'Fosa', status: BayStatus.maintenance);

const _board = [
  BayBoardItem(bay: _free),
  BayBoardItem(bay: _busy, occupant: BayOccupant(workOrderId: 'wo1', internalNumber: 7, plate: 'BKL482')),
  BayBoardItem(bay: _broken),
];

const _allPermissions = {'operations:bays:read', 'operations:bays:reassign', 'operations:bays:manage'};

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));
  late _Repository repository;

  setUpAll(() => registerFallbackValue(BayType.lift));

  setUp(() {
    repository = _Repository();
    when(() => repository.observeBoard()).thenAnswer((_) => Stream.value(_board));
    when(() => repository.canReadBoard()).thenAnswer((_) async => true);
    when(() => repository.refreshBranchBays()).thenAnswer((_) async {});
    when(() => repository.reassignBay(any(), any())).thenAnswer((_) async {});
  });

  BaysViewModel build({Set<String> permissions = _allPermissions}) {
    final session = _ObserveSession();
    when(() => session.execute()).thenAnswer(
      (_) => Stream.value(
        Session(
          userId: 'u1',
          email: 'a@b.pe',
          fullName: 'Ana',
          tenantId: 't1',
          tenantName: 'Taller',
          membershipId: 'm1',
          permissions: permissions,
          plan: null,
        ),
      ),
    );
    final orders = _ObserveOrders();
    when(() => orders.execute()).thenAnswer((_) => Stream.value(const []));
    final refreshOrders = _RefreshOrders();
    when(() => refreshOrders.execute()).thenAnswer((_) async {});
    final mechanics = _Mechanics();
    when(() => mechanics.execute()).thenAnswer((_) async => []);
    return BaysViewModel(
      observeSession: session,
      observeBoard: ObserveBayBoardUseCase(repository: repository),
      pollBoard: PollBayBoardUseCase(repository: repository),
      observeOrders: orders,
      refreshOrders: refreshOrders,
      getMechanics: mechanics,
      reassignBay: ReassignBayUseCase(repository: repository),
      releaseBay: ReleaseBayUseCase(repository: repository),
      createBay: CreateWorkBayUseCase(repository: repository),
      setBayMaintenance: SetBayMaintenanceUseCase(repository: repository),
      restoreBay: RestoreBayUseCase(repository: repository),
      connectivity: ConnectivityObserver(
        changes: const Stream.empty(),
        current: () async => [ConnectivityResult.wifi],
      ),
    );
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('BaysViewModel', () {
    test('sondea cada 30 s solo mientras es visible', () {
      fakeAsync((async) {
        final vm = build();
        async.elapse(const Duration(minutes: 2));
        verifyNever(() => repository.refreshBranchBays());

        vm.setVisible(true);
        async.elapse(const Duration(seconds: 61));
        verify(() => repository.refreshBranchBays()).called(3);

        vm.setVisible(false);
        async.elapse(const Duration(minutes: 5));
        verifyNever(() => repository.refreshBranchBays());
        vm.dispose();
      });
    });

    test('filtra y cuenta por estado', () async {
      final vm = build();
      await settle();
      expect(vm.state.countFor(BayFilter.all), 3);
      vm.onFilterChange(BayFilter.maintenance);
      expect(vm.state.visibleItems.single.bay.name, 'Fosa');
      vm.dispose();
    });

    test('mueve la orden a una bahía libre y avisa', () async {
      final vm = build();
      await settle();
      vm.onBayClick(_busy);
      await vm.onMoveOrder(_free);

      verify(() => repository.reassignBay('wo1', 'b1')).called(1);
      expect(vm.state.sheet, isNull);
      expect(vm.state.notice?.asString(strings), strings.baysMovedNotice('Elevador 1'));
      vm.dispose();
    });

    test('una bahía no libre no llega al backend (US40 E2)', () async {
      final vm = build();
      await settle();
      vm.onBayClick(_busy);
      await vm.onMoveOrder(_broken);

      verifyNever(() => repository.reassignBay(any(), any()));
      expect(vm.state.error?.asString(strings), strings.baysUnavailableError);
      expect(vm.state.sheet, isNotNull);
      vm.dispose();
    });

    test('con 409 muestra el message y deja la hoja abierta', () async {
      when(() => repository.reassignBay(any(), any()))
          .thenThrow(const ApiException(httpStatus: 409, code: 'C', message: 'Ya la ocupó otra orden'));
      final vm = build();
      await settle();
      vm.onBayClick(_free);
      await vm.onAssignOrder('wo9');

      expect(vm.state.error?.asString(strings), 'Ya la ocupó otra orden');
      expect(vm.state.sheet, isNotNull);
      vm.dispose();
    });

    test('mantenimiento exige motivo; restaurar, liberar y registrar llaman al repositorio', () async {
      when(() => repository.setMaintenance(any(), any())).thenAnswer((_) async {});
      when(() => repository.restoreBay(any())).thenAnswer((_) async {});
      when(() => repository.releaseBay(any())).thenAnswer((_) async {});
      when(() => repository.createBay(any(), any())).thenAnswer((_) async {});
      final vm = build();
      await settle();

      vm.onBayClick(_free);
      vm.onMaintenanceClick();
      await vm.onConfirmMaintenance();
      expect(vm.state.invalidField, 'reason');
      vm.onMaintenanceReasonChange(' Calibración ');
      await vm.onConfirmMaintenance();
      verify(() => repository.setMaintenance('b1', 'Calibración')).called(1);

      vm.onBayClick(_broken);
      await vm.onRestore();
      verify(() => repository.restoreBay('b3')).called(1);

      vm.onBayClick(_busy);
      await vm.onRelease();
      verify(() => repository.releaseBay('wo1')).called(1);

      vm.onCreateClick();
      vm.onCreateNameChange('Elevador 3');
      vm.onCreateTypeChange(BayType.diagnosticPit);
      await vm.onConfirmCreate();
      verify(() => repository.createBay('Elevador 3', BayType.diagnosticPit)).called(1);
      expect(vm.state.createForm, isNull);
      vm.dispose();
    });

    test('sin permisos de escritura no actúa', () async {
      final vm = build(permissions: {'operations:bays:read'});
      await settle();
      vm.onBayClick(_busy);
      await vm.onMoveOrder(_free);
      await vm.onRelease();
      vm.onCreateClick();

      verifyNever(() => repository.reassignBay(any(), any()));
      verifyNever(() => repository.releaseBay(any()));
      expect(vm.state.createForm, isNull);
      vm.dispose();
    });
  });

  group('BaysContent', () {
    Future<void> pump(WidgetTester tester, BaysUiState state, {ValueChanged<WorkBay>? onBay}) async {
      tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AtelierTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: BaysContent(
            state: state,
            onBack: () {},
            onRefresh: () async {},
            onFilterChange: (_) {},
            onBayClick: onBay ?? (_) {},
            onCreateClick: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('muestra bahías con estado, placa y número de orden', (tester) async {
      WorkBay? tapped;
      await pump(
        tester,
        const BaysUiState(items: _board, isLoading: false, canManage: true),
        onBay: (bay) => tapped = bay,
      );

      expect(find.text('Elevador 1'), findsOneWidget);
      expect(find.text('Libre'), findsOneWidget);
      expect(find.text('Ocupada'), findsOneWidget);
      expect(find.text(strings.ordersOrderNumber(7)), findsOneWidget);
      expect(find.text('Nueva bahía'), findsOneWidget);
      await tester.tap(find.text('Elevador 2'));
      expect(tapped?.id, 'b2');
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('sin permiso de lectura solo el aviso', (tester) async {
      await pump(tester, const BaysUiState(canRead: false, isLoading: false));
      expect(find.text(strings.baysNoPermission), findsOneWidget);
      expect(find.text('Nueva bahía'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
