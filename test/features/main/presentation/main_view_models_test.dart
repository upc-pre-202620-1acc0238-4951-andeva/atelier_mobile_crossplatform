import 'dart:async';
import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/auth/domain/branch_option.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/discard_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operations_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/retry_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/sync_now_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockGetBranches extends Mock implements GetSelectableBranchesUseCase {}

class _MockBranchDaily extends Mock implements GetBranchDailyAttendanceUseCase {}

class _MockPending extends Mock implements GetPendingJustificationsUseCase {}

class _MockApprove extends Mock implements ApproveJustificationUseCase {}

class _MockReject extends Mock implements RejectJustificationUseCase {}

class _MockObserveOperations extends Mock implements ObservePendingOperationsUseCase {}

class _MockRetry extends Mock implements RetryPendingOperationUseCase {}

class _MockDiscard extends Mock implements DiscardPendingOperationUseCase {}

class _MockSyncNow extends Mock implements SyncNowUseCase {}

Session _session(Set<String> permissions) {
  return Session(
    userId: 'u1',
    email: 'carlos@motorescusco.pe',
    fullName: 'Carlos Mendoza',
    tenantId: 't1',
    tenantName: 'Motores Cusco',
    membershipId: 'm9',
    permissions: permissions,
    plan: null,
    branchId: 'b1',
  );
}

TeamAttendance _row(String id, {JustificationStatus? status, String membershipId = 'm1'}) {
  return TeamAttendance(
    id: id,
    membershipId: membershipId,
    branchId: 'b1',
    clockIn: DateTime.utc(2026, 11, 16, 13, 42),
    status: AttendanceStatus.late,
    justificationStatus: status,
  );
}

ConnectivityObserver _online() => ConnectivityObserver(
  changes: const Stream.empty(),
  current: () async => [ConnectivityResult.wifi],
);

void main() {
  setUpAll(() => registerFallbackValue(const <String>[]));

  group('AdminAttendanceViewModel', () {
    late _MockObserveSession observeSession;
    late _MockGetBranches getBranches;
    late _MockBranchDaily branchDaily;
    late _MockPending pending;
    late _MockApprove approve;
    late _MockReject reject;

    AdminAttendanceViewModel build(Session? session) {
      when(() => observeSession.execute()).thenAnswer((_) => Stream.value(session));
      return AdminAttendanceViewModel(
        observeSession: observeSession,
        getBranches: getBranches,
        getBranchDaily: branchDaily,
        getPendingJustifications: pending,
        approveJustification: approve,
        rejectJustification: reject,
        connectivity: _online(),
        time: BusinessTime(now: () => DateTime.utc(2026, 11, 16, 15)),
        linger: const Duration(milliseconds: 60),
      );
    }

    setUp(() {
      observeSession = _MockObserveSession();
      getBranches = _MockGetBranches();
      branchDaily = _MockBranchDaily();
      pending = _MockPending();
      approve = _MockApprove();
      reject = _MockReject();
      when(() => getBranches.execute()).thenAnswer(
        (_) async => const [BranchOption(id: 'b1', name: 'Sede Surco', geofenceRadiusMeters: 100)],
      );
      when(() => branchDaily.execute(any())).thenAnswer((_) async => [_row('r1'), _row('r2')]);
      when(() => pending.execute()).thenAnswer(
        (_) async => PendingJustifications(
          items: [_row('r1', status: JustificationStatus.pending), _row('r3')],
          failedDates: const ['2026-11-14'],
        ),
      );
      when(() => approve.execute(any())).thenAnswer((_) async => _row('r1'));
      when(() => reject.execute(any())).thenAnswer((_) async => _row('r1'));
    });

    const audit = {
      'hr:attendance:audit_all',
      'hr:justifications:approve',
      'iam:branches:read',
    };

    test('carga la asistencia del día, la sede y los descargos que esperan decisión', () async {
      final viewModel = build(_session(audit));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      final state = viewModel.state;
      expect(state.hasLoaded, isTrue);
      expect(state.isRefreshing, isFalse);
      expect(state.branchName, 'Sede Surco');
      expect(state.records.map((r) => r.id), ['r1', 'r2']);
      expect(state.justifications.map((j) => j.id), ['r1']);
      expect(state.failedJustificationDays, 1);
      verify(() => branchDaily.execute('2026-11-16')).called(1);
    });

    test('un error de lectura queda en el estado y no oculta lo ya cargado', () async {
      when(() => branchDaily.execute(any())).thenThrow(Exception('boom'));
      final viewModel = build(_session(audit));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.hasLoaded, isTrue);
      expect(viewModel.state.records, isEmpty);
    });

    test('aprobar un descargo lo muestra resuelto y luego lo retira de la lista', () async {
      final viewModel = build(_session(audit));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.onOpenJustification(viewModel.state.justifications.single);
      expect(viewModel.state.reviewing?.id, 'r1');

      unawaited(viewModel.onReviewJustification(true));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(viewModel.state.reviewing, isNull);
      expect(viewModel.state.resolved, {'r1': true});
      expect(viewModel.state.justifications, hasLength(1));

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(viewModel.state.justifications, isEmpty);
      expect(viewModel.state.resolved, isEmpty);
      verify(() => approve.execute('r1')).called(1);
      verifyNever(() => reject.execute(any()));
    });

    test('un error al decidir deja el descargo en revisión con el mensaje', () async {
      when(() => reject.execute(any())).thenThrow(Exception('sin red'));
      final viewModel = build(_session(audit));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.onOpenJustification(viewModel.state.justifications.single);
      await viewModel.onReviewJustification(false);

      expect(viewModel.state.reviewing?.id, 'r1');
      expect(viewModel.state.reviewError, isNotNull);
      expect(viewModel.state.isSubmittingReview, isFalse);
      expect(viewModel.state.justifications, hasLength(1));
    });

    test('sin permiso de aprobar no llama al caso de uso', () async {
      final viewModel = build(_session({'hr:attendance:audit_all'}));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.onOpenJustification(viewModel.state.justifications.single);
      await viewModel.onReviewJustification(true);

      verifyNever(() => approve.execute(any()));
      expect(viewModel.state.reviewing, isNotNull);
    });

    test('sin permiso de auditar queda en "Mi asistencia" y no consulta al equipo', () async {
      final viewModel = build(_session({'hr:attendance:clock_in'}));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      expect(viewModel.state.tab, TeamTab.mine);
      expect(viewModel.state.hasTabs, isFalse);
      verifyNever(() => branchDaily.execute(any()));
    });

    test('quien supervisa y marca tiene pestañas y puede cambiar de una a otra', () async {
      final viewModel = build(_session({...audit, 'hr:attendance:clock_in'}));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      expect(viewModel.state.hasTabs, isTrue);
      expect(viewModel.state.tab, TeamTab.team);
      viewModel.onTabChange(TeamTab.mine);
      expect(viewModel.state.tab, TeamTab.mine);
    });

    test('un descargo ya resuelto no se vuelve a abrir', () async {
      final viewModel = build(_session(audit));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      final item = viewModel.state.justifications.single;
      viewModel.onOpenJustification(item);
      unawaited(viewModel.onReviewJustification(true));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      viewModel.onOpenJustification(item);

      expect(viewModel.state.reviewing, isNull);
    });
  });

  group('PendingOperationsViewModel', () {
    late _MockObserveOperations observe;
    late _MockRetry retry;
    late _MockDiscard discard;
    late _MockSyncNow syncNow;
    late StreamController<List<PendingOperation>> operations;

    PendingOperation op(String id, PendingOperationStatus status) {
      return PendingOperation(
        id: id,
        type: 'CLOCK_IN',
        status: status,
        attempts: 1,
        lastErrorMessage: null,
        createdAt: DateTime.utc(2026, 11, 16, 13),
        dependsOn: null,
      );
    }

    PendingOperationsViewModel build() {
      return PendingOperationsViewModel(
        observeOperations: observe,
        retryOperation: retry,
        discardOperation: discard,
        syncNow: syncNow,
        connectivity: _online(),
      );
    }

    setUp(() {
      observe = _MockObserveOperations();
      retry = _MockRetry();
      discard = _MockDiscard();
      syncNow = _MockSyncNow();
      operations = StreamController<List<PendingOperation>>.broadcast();
      when(() => observe.execute()).thenAnswer((_) => operations.stream);
      when(() => retry.execute(any())).thenAnswer((_) async => true);
      when(() => discard.execute(any())).thenAnswer((_) async => true);
      when(() => syncNow.execute()).thenAnswer((_) async {});
    });

    tearDown(() => operations.close());

    test('espera a Drift antes de decir que todo está sincronizado', () async {
      final viewModel = build();
      addTearDown(viewModel.dispose);
      expect(viewModel.state.hasLoaded, isFalse);

      operations.add([
        op('1', PendingOperationStatus.pending),
        op('2', PendingOperationStatus.syncing),
        op('3', PendingOperationStatus.failed),
      ]);
      await pumpEventQueue();

      final state = viewModel.state;
      expect(state.hasLoaded, isTrue);
      expect([state.pendingCount, state.syncingCount, state.failedCount], [1, 1, 1]);
    });

    test('"Sincronizar ahora" reactiva solo las que fallaron y pide enviar la cola', () async {
      final viewModel = build();
      addTearDown(viewModel.dispose);
      operations.add([op('1', PendingOperationStatus.pending), op('3', PendingOperationStatus.failed)]);
      await pumpEventQueue();

      await viewModel.onSyncNow();

      expect(viewModel.state.isSyncingNow, isTrue);
      expect(
        viewModel.state.notice!.asString(lookupAppLocalizations(const Locale('es'))),
        'Sincronización iniciada en segundo plano.',
      );
      verify(() => retry.execute('3')).called(1);
      verifyNever(() => retry.execute('1'));
      verify(() => syncNow.execute()).called(1);

      // Al cambiar la cola termina el aviso.
      operations.add([op('1', PendingOperationStatus.syncing)]);
      await pumpEventQueue();
      expect(viewModel.state.isSyncingNow, isFalse);
    });

    test('reintentar una operación la reactiva y pide sincronizar', () async {
      final viewModel = build();
      addTearDown(viewModel.dispose);

      await viewModel.onRetry('3');

      verify(() => retry.execute('3')).called(1);
      verify(() => syncNow.execute()).called(1);
    });

    test('descartar delega en el caso de uso', () async {
      final viewModel = build();
      addTearDown(viewModel.dispose);

      await viewModel.onDiscard('3');

      verify(() => discard.execute('3')).called(1);
    });
  });
}
