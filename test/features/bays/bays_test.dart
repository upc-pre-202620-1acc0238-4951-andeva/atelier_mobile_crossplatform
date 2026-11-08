import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/poll_bay_board_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/application/reassign_bay_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_board.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_errors.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/bay_repository.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:decimal/decimal.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../support/step9_test_env.dart';

class _MockBays extends Mock implements BayRepository {}

TaskDetail _task(TaskStatus status, {DateTime? startedAt, int paused = 0}) {
  return TaskDetail(
    id: TaskId('t'),
    workOrderId: 'wo1',
    status: status,
    description: '',
    price: Money(amount: Decimal.one, currency: Money.pen),
    totalPausedSeconds: paused,
    startedAt: startedAt,
  );
}

const _bayPermissions = [
  Permission.baysRead,
  Permission.baysReassign,
  Permission.workOrdersRead,
];

void main() {
  group('dominio', () {
    test('laborElapsed suma solo las tareas en curso y resta sus pausas', () {
      final now = DateTime.utc(2026, 11, 6, 14);
      final tasks = [
        _task(
          TaskStatus.inProgress,
          startedAt: now.subtract(const Duration(hours: 1)),
          paused: 600,
        ),
        _task(
          TaskStatus.onHold,
          startedAt: now.subtract(const Duration(hours: 5)),
        ),
        _task(TaskStatus.inProgress),
      ];
      expect(laborElapsed(tasks, now), const Duration(minutes: 50));
      expect(laborElapsed([_task(TaskStatus.onHold)], now), isNull);
    });

    test('solo una bahía disponible recibe órdenes; tipos y estados desconocidos son null', () {
      expect(
        const WorkBay(
          id: 'b',
          branchId: 'x',
          name: 'n',
          status: BayStatus.available,
        ).canReceive,
        isTrue,
      );
      expect(
        const WorkBay(
          id: 'b',
          branchId: 'x',
          name: 'n',
          status: BayStatus.maintenance,
        ).canReceive,
        isFalse,
      );
      expect(
        const WorkBay(id: 'b', branchId: 'x', name: 'n').canReceive,
        isFalse,
      );
      expect(BayType.fromString('NUEVO'), isNull);
      expect(BayType.fromString('DIAGNOSTIC_PIT'), BayType.diagnosticPit);
    });
  });

  group('casos de uso', () {
    late _MockBays repository;

    setUp(() => repository = _MockBays());

    test('una bahía ocupada falla sin llamar al backend', () async {
      final useCase = ReassignBayUseCase(repository: repository);
      const busy = WorkBay(
        id: 'b2',
        branchId: 'x',
        name: 'n',
        status: BayStatus.occupied,
      );
      await expectLater(
        useCase.execute('wo1', busy),
        throwsA(isA<BayUnavailableException>()),
      );
      verifyNever(() => repository.reassignBay(any(), any()));
    });

    test('el sondeo refresca ya y cada 30 s, y sigue tras un fallo', () {
      fakeAsync((async) {
        var calls = 0;
        when(() => repository.canReadBoard()).thenAnswer((_) async => true);
        when(() => repository.refreshBranchBays()).thenAnswer((_) async {
          calls++;
          if (calls == 2) {
            throw const ApiException(
              httpStatus: 500,
              code: 'X',
              message: 'caído',
            );
          }
        });
        final events = <String>[];
        final subscription = PollBayBoardUseCase(repository: repository)
            .execute()
            .listen(
              (_) => events.add('ok'),
              onError: (_) => events.add('error'),
            );
        async.elapse(const Duration(seconds: 61));
        expect(calls, 3);
        expect(events, ['ok', 'error', 'ok']);
        subscription.cancel();
        async.elapse(const Duration(minutes: 5));
        expect(calls, 3);
      });
    });

    test('sin permiso el sondeo termina sin emitir ni llamar', () async {
      when(() => repository.canReadBoard()).thenAnswer((_) async => false);
      final events = await PollBayBoardUseCase(repository: repository)
          .execute()
          .toList();
      expect(events, isEmpty);
      verifyNever(() => repository.refreshBranchBays());
    });
  });

  group('repositorio', () {
    late Step9TestEnv env;

    setUp(() async => env = await Step9TestEnv.create());
    tearDown(() => env.close());

    test(
      'refresca las bahías de la sede y deja el alcance en cache_metadata',
      () async {
        await env.signIn(permissions: _bayPermissions);
        env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
        await env.bays.refreshBranchBays();
        expect(
          env
              .requested('GET', '/api/v1/work-bays')
              .single
              .url
              .queryParameters['branchId'],
          'b1',
        );
        expect(await env.db.cacheMetadataDao.get('bays:b1'), isNotNull);
      },
    );

    test('sin sede falla sin llamar', () async {
      await env.signIn(permissions: _bayPermissions, branchId: null);
      await expectLater(
        env.bays.refreshBranchBays(),
        throwsA(isA<MissingBranchException>()),
      );
      expect(env.requests, isEmpty);
    });

    test('el tablero sale enseguida y completa número, mecánicos y tiempo con el detalle', () async {
      await env.signIn(permissions: _bayPermissions);
      env.responses['GET /api/v1/work-bays'] = (_) => json([
        bayJson(),
        bayJson(
          id: 'bay2',
          name: 'Bahía 2',
          status: 'AVAILABLE',
          currentWorkOrderId: null,
        ),
      ]);
      final detail = Completer<http.Response>();
      env.responses['GET /api/v1/work-orders/wo1'] = (_) => detail.future;
      await env.bays.refreshBranchBays();

      final boards = <List<BayBoardItem>>[];
      final subscription = env.bays.observeBoard().listen(boards.add);
      await pumpEventQueue();
      expect(boards.last.first.occupant?.mechanicIds, isEmpty);
      expect(boards.last.last.occupant, isNull);

      detail.complete(json(workOrderJson(tasks: [taskJson()])));
      await pumpEventQueue();
      final occupant = boards.last.first.occupant!;
      expect(occupant.internalNumber, 101);
      expect(occupant.mechanicIds, ['m1']);
      expect(occupant.laborElapsed, const Duration(minutes: 50));
      await subscription.cancel();
    });

    test('un detalle que falla no tumba el tablero ni se reintenta en la misma suscripción', () async {
      await env.signIn(permissions: _bayPermissions);
      env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
      env.responses['GET /api/v1/work-orders/wo1'] = (_) =>
          http.Response('<html>', 200);
      await env.bays.refreshBranchBays();

      final boards = <List<BayBoardItem>>[];
      final subscription = env.bays.observeBoard().listen(boards.add);
      await pumpEventQueue();
      await env.bays.refreshBranchBays();
      await pumpEventQueue();
      expect(boards, isNotEmpty);
      expect(boards.last.single.occupant?.laborElapsed, isNull);
      expect(env.requested('GET', '/api/v1/work-orders/wo1'), hasLength(1));
      await subscription.cancel();
    });

    test(
      'reasignar un mecánico vuelve a leer el detalle del tablero observado',
      () async {
        await env.signIn(permissions: _bayPermissions);
        env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
        env.responses['GET /api/v1/work-orders/wo1'] = (_) =>
            json(workOrderJson(tasks: [taskJson()]));
        env.responses['PUT /api/v1/tasks/t1/mechanic'] = (_) =>
            json(taskJson(mechanicId: 'm2'));
        await env.bays.refreshBranchBays();

        final subscription = env.bays.observeBoard().listen((_) {});
        await pumpEventQueue();
        await env.bays.reassignMechanic('t1', 'm2');
        await pumpEventQueue();
        expect(env.requested('GET', '/api/v1/work-orders/wo1'), hasLength(2));
        await subscription.cancel();
      },
    );

    test('una bahía ya ocupada da el 409 y la caché no cambia', () async {
      await env.signIn(permissions: _bayPermissions);
      env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
      env.responses['PUT /api/v1/work-orders/wo1/bay'] = (_) =>
          apiError(409, 'Bahía ocupada');
      await env.bays.refreshBranchBays();
      await expectLater(
        env.bays.reassignBay('wo1', 'bay2'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Bahía ocupada',
          ),
        ),
      );
      expect(env.requested('GET', '/api/v1/work-bays'), hasLength(1));
    });

    test('reasignar guarda la cabecera y recarga las bahías', () async {
      await env.signIn(permissions: _bayPermissions);
      env.responses['GET /api/v1/work-bays'] = (_) => json([bayJson()]);
      env.responses['PUT /api/v1/work-orders/wo1/bay'] = (request) {
        expect(request.body, '{"bayId":"bay2"}');
        return json(workOrderJson());
      };
      await env.bays.reassignBay('wo1', 'bay2');
      expect(await env.db.workOrderDao.findById('wo1'), isNotNull);
      expect(env.requested('GET', '/api/v1/work-bays'), hasLength(1));
    });
  });
}
