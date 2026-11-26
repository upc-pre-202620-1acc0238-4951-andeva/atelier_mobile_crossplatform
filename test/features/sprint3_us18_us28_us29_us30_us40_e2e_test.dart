import 'dart:convert';
import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/create_work_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/observe_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_task_mechanic_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/release_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/restore_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/set_bay_maintenance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_screen.dart';
import 'package:atelier_mobile_crossplatform/features/bays/presentation/bays_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/diagnostics_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pending_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_evidence.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_evidence_section.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/task_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_actions.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_branch_mechanics_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/observe_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/refresh_branch_work_orders_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

import 'support/step9_test_env.dart';

class _TelemetryDao extends Mock implements TelemetryReadingDao {}

class _FaultDao extends Mock implements VehicleFaultDao {}

class _AlertDao extends Mock implements PredictiveAlertDao {}

class _OperationDao extends Mock implements PendingOperationDao {}

class _Queue extends Mock implements PendingOperationQueue {}

class _Session extends Mock implements SessionManager {}

class _BayRepository extends Mock implements BayRepository {}

class _ObserveSession extends Mock implements ObserveSessionUseCase {}

class _ObserveOrders extends Mock implements ObserveBranchWorkOrdersUseCase {}

class _RefreshOrders extends Mock implements RefreshBranchWorkOrdersUseCase {}

class _Mechanics extends Mock implements GetBranchMechanicsUseCase {}

Widget _app(Widget home) => MaterialApp(
  theme: AtelierTheme.light,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: home,
);

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(home));
  await tester.pump(const Duration(milliseconds: 400));
}

DiagnosticsRepositoryImpl _diagnostics(MockClientHandler handler) {
  return DiagnosticsRepositoryImpl(
    api: IotApi(client: ApiClient(client: MockClient(handler), baseUrl: 'https://api.test')),
    readingDao: _TelemetryDao(),
    faultDao: _FaultDao(),
    alertDao: _AlertDao(),
    pendingOperationDao: _OperationDao(),
    queue: _Queue(),
    session: _Session(),
  );
}

void main() {
  setUpAll(() => registerFallbackValue(BayType.lift));

  group('E2E Sprint 3 — US40 contra el contrato HTTP', () {
    late Step9TestEnv env;

    setUp(() async => env = await Step9TestEnv.create());
    tearDown(() => env.close());

    test('registrar, mantenimiento, restaurar y liberar usan el método, ruta y cuerpo documentados', () async {
      await env.signIn(permissions: const []);
      env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
      env.responses['POST /api/v1/work-bays'] = (_) => json(bayJson(), 201);
      env.responses['PUT /api/v1/work-bays/bay1/maintenance'] = (_) => json(bayJson(status: 'MAINTENANCE'));
      env.responses['PUT /api/v1/work-bays/bay1/restore'] = (_) => json(bayJson(status: 'AVAILABLE'));
      env.responses['DELETE /api/v1/work-orders/wo1/bay'] = (_) => http.Response('', 204);

      await env.bays.createBay('Elevador 3', BayType.mechanicalLift);
      await env.bays.setMaintenance('bay1', 'Calibración');
      await env.bays.restoreBay('bay1');
      await env.bays.releaseBay('wo1');

      Object? body(String method, String path) => jsonDecode(env.requested(method, path).single.body);
      expect(body('POST', '/api/v1/work-bays'), {
        'branchId': 'b1',
        'name': 'Elevador 3',
        'bayType': 'MECHANICAL_LIFT',
      });
      expect(body('PUT', '/api/v1/work-bays/bay1/maintenance'), {'reason': 'Calibración'});
      expect(env.requested('PUT', '/api/v1/work-bays/bay1/restore'), hasLength(1));
      expect(env.requested('DELETE', '/api/v1/work-orders/wo1/bay'), hasLength(1));
      // Cada escritura refresca el tablero.
      expect(env.requested('GET', '/api/v1/work-bays'), hasLength(4));
    });

    test('un 409 al liberar sube con el message y no refresca', () async {
      await env.signIn(permissions: const []);
      env.responses['DELETE /api/v1/work-orders/wo1/bay'] = (_) => apiError(409, 'La orden ya no tiene bahía');

      await expectLater(
        env.bays.releaseBay('wo1'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'La orden ya no tiene bahía')),
      );
      expect(env.requested('GET', '/api/v1/work-bays'), isEmpty);
    });
  });

  group('E2E Sprint 3 — US18 lectura remota', () {
    test('lee la última telemetría del vehículo', () async {
      late Uri called;
      final repository = _diagnostics((request) async {
        called = request.url;
        return json({
          'vehicleId': 'v1',
          'timestamp': '2026-11-25T15:00:00Z',
          'engineTempCelsius': 92,
          'engineRpm': 2100,
          'batteryVoltage': 13.9,
          'speedKmh': 0,
          'fuelPercentage': 55,
          'latitude': null,
          'longitude': null,
        });
      });

      final sample = await repository.getLatestTelemetry('v1');

      expect(called.path, '/api/v1/iot/telemetry/vehicle/v1/latest');
      expect(sample!.engineTempCelsius, 92.0);
      expect(sample.engineRpm, 2100);
      expect(sample.timestamp, DateTime.utc(2026, 11, 25, 15));
      expect(sample.intakePressureKpa, isNull);
    });

    test('404 es "sin lecturas"; otro error sube', () async {
      expect(await _diagnostics((_) async => apiError(404)).getLatestTelemetry('v1'), isNull);
      await expectLater(
        _diagnostics((_) async => apiError(403, 'Sin acceso')).getLatestTelemetry('v1'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('E2E Sprint 3 — US28, US29 y US30 en pantalla', () {
    testWidgets('US28: junta fotos confirmadas y en cola sin repetir, y permite añadir y revisar fallas', (tester) async {
      var added = false;
      PendingEvidence? selected;
      final kinds = <EvidenceKind>[];
      final notes = <String>[];
      await _pump(
        tester,
        Scaffold(
          body: SingleChildScrollView(
            child: TaskEvidenceSection(
              state: TaskDetailUiState(
                canUploadPhotos: true,
                evidenceNote: 'Pastilla',
                detail: TaskDetail(
                  id: TaskId('t1'),
                  workOrderId: 'wo1',
                  status: TaskStatus.inProgress,
                  description: 'Frenos',
                  totalPausedSeconds: 0,
                  evidenceImages: const [TaskEvidence(id: 'e1', imageUrl: 'https://x/1.jpg', description: 'Desmontaje')],
                ),
                pendingEvidence: [
                  PendingEvidence(
                    operationId: 'op1',
                    imageUrl: 'https://x/1.jpg',
                    description: 'Desmontaje',
                    status: 'PENDING',
                    capturedAt: DateTime.utc(2026, 11, 25),
                  ),
                  PendingEvidence(
                    operationId: 'op2',
                    imageUrl: '',
                    description: 'Montaje: pastilla nueva',
                    status: 'FAILED',
                    lastErrorMessage: 'La tarea ya está cerrada',
                    capturedAt: DateTime.utc(2026, 11, 25),
                  ),
                ],
              ),
              onKindChange: kinds.add,
              onNoteChange: notes.add,
              onTakePhoto: () => added = true,
              onSelectFailedEvidence: (pending) => selected = pending,
            ),
          ),
        ),
      );

      expect(find.text('Desmontaje'), findsWidgets);
      expect(find.text('Montaje: pastilla nueva'), findsOneWidget);
      expect(find.text('Falló'), findsOneWidget);
      expect(find.text('8 / 488 caracteres disponibles'), findsOneWidget);
      await tester.tap(find.text('Montaje').first);
      expect(kinds, [EvidenceKind.assembly]);
      await tester.tap(find.text('Montaje: pastilla nueva'));
      expect(selected?.operationId, 'op2');
      await tester.tap(find.text('Tomar foto'));
      expect(added, isTrue);
    });

    testWidgets('US28: la hoja de foto fallida ofrece reintentar y descartar', (tester) async {
      var retried = 0;
      var discarded = 0;
      await _pump(
        tester,
        Scaffold(
          body: FailedEvidenceSheet(
            evidence: PendingEvidence(
              operationId: 'op2',
              imageUrl: '',
              description: 'Montaje: pastilla nueva',
              status: 'FAILED',
              lastErrorMessage: 'La tarea ya está cerrada',
              capturedAt: DateTime.utc(2026, 11, 25),
            ),
            onRetry: () => retried++,
            onDiscard: () => discarded++,
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('La tarea ya está cerrada'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.tap(find.text('Descartar'));
      expect(retried, 1);
      expect(discarded, 1);
    });

    testWidgets('US29 y US30: sin conexión las hojas no dejan confirmar', (tester) async {
      var confirmed = 0;
      await _pump(
        tester,
        Scaffold(
          body: CompleteTaskSheet(
            form: const CompleteTaskForm(hours: '1.5'),
            isOnline: false,
            isSaving: false,
            invalidField: null,
            error: null,
            onHoursChange: (_) {},
            onNotesChange: (_) {},
            onConfirm: () => confirmed++,
            onDismiss: () {},
          ),
        ),
      );
      await tester.tap(find.text('Confirmar cierre'), warnIfMissed: false);
      expect(confirmed, 0);

      await _pump(
        tester,
        Scaffold(
          body: ReviewSuspensionSheet(
            reason: 'Retén roto',
            requestedAt: DateTime.utc(2026, 11, 25, 15),
            isOnline: false,
            busyAction: null,
            error: null,
            onApprove: () => confirmed++,
            onReject: () => confirmed++,
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('Retén roto'), findsOneWidget);
      await tester.tap(find.text('Aprobar suspensión'), warnIfMissed: false);
      await tester.tap(find.text('Rechazar suspensión'), warnIfMissed: false);
      expect(confirmed, 0);
    });

    testWidgets('US30: una tarea en pausa propia ofrece cerrar; una suspendida no', (tester) async {
      Future<void> show(HoldReason hold) => _pump(
        tester,
        TaskDetailContent(
          state: TaskDetailUiState(
            detail: TaskDetail(
              id: const TaskId('t1'),
              workOrderId: 'wo1',
              status: TaskStatus.onHold,
              holdReason: hold,
              description: 'Cambio de pastillas',
              totalPausedSeconds: 0,
            ),
            isLoading: false,
            canCompleteTask: true,
          ),
          actions: const TaskDetailActions(),
        ),
      );

      await show(HoldReason.breakTime);
      expect(find.text('Terminar tarea'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());

      await show(HoldReason.waitingParts);
      expect(find.text('Terminar tarea'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('E2E Sprint 3 — US40 pantalla y sondeo', () {
    tearDown(() => getIt.reset());

    testWidgets('sondea mientras se ve, se detiene al taparla y reanuda al volver', (tester) async {
      final repository = _BayRepository();
      var refreshes = 0;
      when(() => repository.observeBoard()).thenAnswer(
        (_) => Stream.value(const [
          BayBoardItem(bay: WorkBay(id: 'b1', branchId: 's', name: 'Elevador 1', status: BayStatus.available)),
        ]),
      );
      when(() => repository.canReadBoard()).thenAnswer((_) async => true);
      when(() => repository.refreshBranchBays()).thenAnswer((_) async => refreshes++);
      final session = _ObserveSession();
      when(() => session.execute()).thenAnswer(
        (_) => Stream.value(
          const Session(
            userId: 'u1',
            email: 'a@b.pe',
            fullName: 'Ana',
            tenantId: 't1',
            tenantName: 'Taller',
            membershipId: 'm1',
            permissions: {'operations:bays:read', 'operations:bays:manage'},
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
      getIt.registerFactory<BaysViewModel>(
        () => BaysViewModel(
          observeSession: session,
          observeBoard: ObserveBayBoardUseCase(repository: repository),
          pollBoard: PollBayBoardUseCase(repository: repository),
          observeOrders: orders,
          refreshOrders: refreshOrders,
          getMechanics: mechanics,
          reassignBay: ReassignBayUseCase(repository: repository),
          reassignTaskMechanic: ReassignTaskMechanicUseCase(repository: repository),
          releaseBay: ReleaseBayUseCase(repository: repository),
          createBay: CreateWorkBayUseCase(repository: repository),
          setBayMaintenance: SetBayMaintenanceUseCase(repository: repository),
          restoreBay: RestoreBayUseCase(repository: repository),
          connectivity: ConnectivityObserver(
            changes: const Stream.empty(),
            current: () async => [ConnectivityResult.wifi],
          ),
        ),
      );

      await _pump(tester, const BaysScreen());
      await tester.pump();
      expect(refreshes, 1);
      await tester.pump(const Duration(seconds: 30));
      expect(refreshes, 2);

      // Una hoja encima no detiene el sondeo.
      await tester.tap(find.text('Elevador 1'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 30));
      expect(refreshes, 3);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
      navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('otra'))));
      await tester.pumpAndSettle();
      final covered = refreshes;
      await tester.pump(const Duration(minutes: 2));
      expect(refreshes, covered, reason: 'tapada no sondea');

      navigator.pop();
      await tester.pumpAndSettle();
      await tester.pump();
      expect(refreshes, covered + 1, reason: 'al volver refresca ya');

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(minutes: 2));
      expect(refreshes, covered + 1);
    });
  });
}
