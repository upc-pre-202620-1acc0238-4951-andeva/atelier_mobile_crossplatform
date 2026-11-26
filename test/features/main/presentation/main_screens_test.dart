import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/notification_record.dart';
import 'package:atelier_mobile_crossplatform/core/domain/plan.dart';
import 'package:atelier_mobile_crossplatform/core/domain/push_destination.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/dashboard/admin_dashboard_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/notifications/notifications_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_screen.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AtelierTheme.dark : AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Quita del árbol las animaciones infinitas (balizas, huesos) antes de cerrar la prueba.
Future<void> _teardown(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox());

WorkOrder _order(
  String id,
  int number,
  WorkOrderStatus status, {
  String? customer = 'Rosa Quispe',
}) {
  return WorkOrder(
    id: WorkOrderId(id),
    internalNumber: number,
    branchId: 'b1',
    vehicleId: 'v$id',
    customerId: 'c$id',
    status: status,
    plate: 'BKR418',
    customerName: customer,
  );
}

TeamAttendance _late({String id = 'a1', String membershipId = 'm1'}) {
  return TeamAttendance(
    id: id,
    membershipId: membershipId,
    branchId: 'b1',
    clockIn: DateTime.utc(2026, 11, 16, 13, 42),
    status: AttendanceStatus.late,
    justificationReason: 'Paro de transporte',
    justificationStatus: JustificationStatus.pending,
    jobTitle: 'Mecánico',
  );
}

Session _session({Set<String> permissions = const {}, Plan? plan}) {
  return Session(
    userId: 'u1',
    email: 'carlos@motorescusco.pe',
    fullName: 'Carlos Mendoza',
    tenantId: 't1',
    tenantName: 'Motores Cusco',
    membershipId: 'm9',
    permissions: permissions,
    plan: plan,
    branchId: 'b1',
  );
}

/// Satoshi real: con la tipografía por defecto de las pruebas (Ahem) los textos ocupan mucho más y desbordan.
Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadSatoshi);

  group('AdminDashboardContent', () {
    testWidgets('cargado: parte, decisiones y órdenes, sin módulos excluidos', (
      tester,
    ) async {
      final state = AdminDashboardUiState(
        today: '2026-11-16',
        fullName: 'Carlos Mendoza',
        tenantName: 'Motores Cusco',
        branchName: 'Sede Surco',
        canChangeBranch: true,
        orders: [
          _order('1', 1042, WorkOrderStatus.draft),
          _order('2', 1041, WorkOrderStatus.inProgress),
          _order('3', 1038, WorkOrderStatus.completed),
        ],
        justifications: [_late()],
        hasLoaded: true,
        pendingSyncCount: 2,
        unreadNotificationsCount: 3,
        canCreateWorkOrder: true,
        canReadWorkOrders: true,
        canStartWorkOrders: true,
        canReadCustomers: true,
        canRegisterCustomers: true,
        canAuditAttendance: true,
        canApproveJustifications: true,
      );
      await _pump(
        tester,
        AdminDashboardContent(state: state, actions: DashboardActions()),
      );

      expect(find.text('Motores Cusco'), findsOneWidget);
      expect(find.text('3 autos'), findsOneWidget);
      expect(find.text('Esperan tu decisión · 2'), findsOneWidget);
      expect(find.text('Orden sin iniciar'), findsOneWidget);
      expect(find.text('Descargo por tardanza'), findsOneWidget);
      expect(find.text('Órdenes abiertas'), findsOneWidget);
      expect(find.text('Rosa Quispe'), findsWidgets);
      // El tablero no trae bahías ni alertas de stock: viven en la hoja de módulos.
      expect(find.textContaining('Bahías'), findsNothing);
      expect(find.textContaining('Alertas de stock'), findsNothing);
      expect(find.textContaining('Cerrar sesión'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('vacío: dice que no hay órdenes', (tester) async {
      final state = AdminDashboardUiState(
        today: '2026-11-16',
        hasLoaded: true,
        canReadWorkOrders: true,
      );
      await _pump(
        tester,
        AdminDashboardContent(state: state, actions: DashboardActions()),
      );

      expect(find.text('Sin autos'), findsOneWidget);
      expect(
        find.text('No hay órdenes abiertas en esta sede.'),
        findsOneWidget,
      );
      expect(find.text('Esperan tu decisión'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('error sin caché: muestra el mensaje y reintenta', (
      tester,
    ) async {
      var retried = 0;
      final state = AdminDashboardUiState(
        today: '2026-11-16',
        hasLoaded: true,
        canReadWorkOrders: true,
        error: const UiText.dynamic('El servidor no responde'),
      );
      await _pump(
        tester,
        AdminDashboardContent(
          state: state,
          actions: DashboardActions(onRefresh: () async => retried++),
        ),
      );

      expect(find.text('El servidor no responde'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(retried, 1);
      await _teardown(tester);
    });

    testWidgets(
      'sin permiso de órdenes y sin conexión: avisa y no muestra decisiones',
      (tester) async {
        const state = AdminDashboardUiState(hasLoaded: true, isOnline: false);
        await _pump(
          tester,
          AdminDashboardContent(state: state, actions: DashboardActions()),
        );

        expect(
          find.text(
            'Sin conexión. Ves lo último que se guardó en este teléfono.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Tu cuenta no puede ver las órdenes de la sede.'),
          findsOneWidget,
        );
        await _teardown(tester);
      },
    );

    test(
      'las decisiones cuentan órdenes sin iniciar y descargos sin resolver',
      () {
        final state = AdminDashboardUiState(
          orders: [
            _order('1', 1, WorkOrderStatus.draft),
            _order('2', 2, WorkOrderStatus.draft),
          ],
          justifications: [
            _late(),
            _late(id: 'a2'),
          ],
          resolved: const {'a2': true},
          canStartWorkOrders: true,
        );
        expect(state.decisionsCount, 3);
        expect(state.copyWith(canStartWorkOrders: false).decisionsCount, 1);
      },
    );
  });

  group('AdminAttendanceContent', () {
    AdminAttendanceContent content(
      AdminAttendanceUiState state, {
      VoidCallback? onBack,
    }) {
      return AdminAttendanceContent(
        state: state,
        onBack: onBack,
        onTabChange: (_) {},
        onRefresh: () async {},
        onOpenJustification: (_) {},
        myAttendanceBuilder: (_) => const Text('Mi asistencia embebida'),
      );
    }

    testWidgets('cargado: cifras del día, descargos y colaboradores', (
      tester,
    ) async {
      final state = AdminAttendanceUiState(
        today: '2026-11-16',
        branchName: 'Sede Surco',
        session: _session(),
        records: [
          TeamAttendance(
            id: 'r1',
            membershipId: 'm1',
            branchId: 'b1',
            clockIn: DateTime.utc(2026, 11, 16, 13),
            status: AttendanceStatus.onTime,
            jobTitle: 'Mecánico',
          ),
          TeamAttendance(
            id: 'r2',
            membershipId: 'm2',
            branchId: 'b1',
            clockIn: DateTime.utc(2026, 11, 16, 13, 40),
            clockOut: DateTime.utc(2026, 11, 16, 22),
            status: AttendanceStatus.late,
          ),
        ],
        justifications: [_late()],
        failedJustificationDays: 1,
        hasLoaded: true,
        canAuditAll: true,
        canApproveJustifications: true,
      );
      await _pump(tester, content(state));

      expect(find.text('Equipo'), findsOneWidget);
      expect(find.text('1 de 2'), findsOneWidget);
      expect(find.text('Asistencia de hoy · 2'), findsOneWidget);
      expect(find.text('Entró 08:00 · en turno'), findsOneWidget);
      expect(find.text('Entró 08:40 · salió 17:00'), findsOneWidget);
      expect(find.text('Descargo por tardanza'), findsOneWidget);
      expect(find.text('Colaborador · m2'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('vacío: nadie ha marcado', (tester) async {
      final state = AdminAttendanceUiState(
        today: '2026-11-16',
        hasLoaded: true,
        canAuditAll: true,
      );
      await _pump(tester, content(state));

      expect(
        find.text('Nadie ha marcado asistencia hoy en esta sede.'),
        findsOneWidget,
      );
      await _teardown(tester);
    });

    testWidgets('error sin registros: mensaje del backend', (tester) async {
      final state = AdminAttendanceUiState(
        today: '2026-11-16',
        hasLoaded: true,
        canAuditAll: true,
        error: const UiText.dynamic('Sede sin asignar'),
      );
      await _pump(tester, content(state));

      expect(find.text('Sede sin asignar'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets(
      'sin permisos: lo explica; con ambos, pestañas y asistencia propia',
      (tester) async {
        await _pump(
          tester,
          content(const AdminAttendanceUiState(hasLoaded: true)),
        );
        expect(
          find.text('Tu cuenta no puede ver la asistencia del equipo.'),
          findsOneWidget,
        );

        await _pump(
          tester,
          content(
            const AdminAttendanceUiState(
              hasLoaded: true,
              canAuditAll: true,
              canClockIn: true,
              tab: TeamTab.mine,
            ),
          ),
        );
        expect(find.text('Mi asistencia'), findsOneWidget);
        expect(find.text('Mi asistencia embebida'), findsOneWidget);
        await _teardown(tester);
      },
    );
  });

  group('NotificationsContent', () {
    NotificationsContent content(NotificationsUiState state) {
      return NotificationsContent(
        state: state,
        onEnableNotifications: () {},
        onBack: () {},
        onRefresh: () async {},
        onMarkAllRead: () {},
        onOpenPushRecord: (_) {},
        onOpenOrder: (_) {},
        onOpenAttendanceReview: () {},
        onOpenSyncQueue: () {},
      );
    }

    testWidgets(
      'cargado: atención y avisos con el título por defecto del destino',
      (tester) async {
        final state = NotificationsUiState(
          isLoading: false,
          session: _session(),
          pushHistory: [
            NotificationRecord(
              id: 'n1',
              title: null,
              body: 'Pastillas gastadas en BKR418',
              destination: const WorkOrderDetailDestination('o1'),
              channel: PushChannel.tasks,
              receivedAt: DateTime.utc(2026, 11, 16, 19, 32),
            ),
            NotificationRecord(
              id: 'n2',
              title: 'Propuesta pendiente',
              body: '',
              destination: null,
              channel: PushChannel.tasks,
              receivedAt: DateTime.utc(2026, 11, 16, 15),
              read: true,
            ),
          ],
          pendingJustifications: [_late()],
          draftOrdersWaitingApproval: [
            _order('1', 1042, WorkOrderStatus.draft),
          ],
          pendingSyncCount: 2,
          notificationsEnabled: false,
        );
        await _pump(tester, content(state));

        expect(find.text('Notificaciones'), findsOneWidget);
        expect(
          find.textContaining(
            'Notificaciones desactivadas en el teléfono',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(find.text('Piden tu atención · 3'), findsOneWidget);
        expect(find.text('2 registros sin enviar'), findsOneWidget);
        expect(find.text('Orden de trabajo actualizada'), findsOneWidget);
        expect(find.text('Propuesta pendiente'), findsOneWidget);
        expect(find.text('Nuevo'), findsOneWidget);
        expect(find.text('Marcar leídos'), findsOneWidget);
        expect(find.textContaining('Stock bajo'), findsNothing);
        await _teardown(tester);
      },
    );

    testWidgets('vacío', (tester) async {
      await _pump(
        tester,
        content(const NotificationsUiState(isLoading: false)),
      );

      expect(
        find.text(
          'Aquí verás los avisos de tareas, stock y asistencia cuando lleguen.',
        ),
        findsOneWidget,
      );
      expect(find.text('Piden tu atención'), findsNothing);
      await _teardown(tester);
    });

    test('el total de atención suma descargos, órdenes y la cola', () {
      final state = NotificationsUiState(
        pendingJustifications: [_late()],
        draftOrdersWaitingApproval: [_order('1', 1, WorkOrderStatus.draft)],
        pendingSyncCount: 4,
      );
      expect(state.totalActiveAlerts, 3);
      expect(const NotificationsUiState().totalActiveAlerts, 0);
    });
  });

  group('ProfileContent', () {
    ProfileContent content(
      ProfileUiState state, {
      VoidCallback? onBack,
      VoidCallback? onSignOut,
    }) {
      return ProfileContent(
        state: state,
        onBack: onBack,
        onSelectBranch: () {},
        onOpenSyncQueue: () {},
        onOpenNotifications: () {},
        onSignOutClick: onSignOut ?? () {},
      );
    }

    const loaded = ProfileUiState(
      fullName: 'Carlos Mendoza Rivas',
      email: 'carlos@motorescusco.pe',
      tenantName: 'Motores Cusco S.A.C.',
      branchName: 'Sede Surco',
      canChangeBranch: true,
      planTier: 'Pro',
      iotTelemetryEnabled: true,
      pendingCount: 2,
      unreadNotificationsCount: 3,
      version: '0.10.0',
    );

    testWidgets(
      'como pestaña: identidad, taller, plan y cerrar sesión (US04)',
      (tester) async {
        await _pump(tester, content(loaded));

        expect(find.text('Carlos Mendoza Rivas'), findsOneWidget);
        expect(find.text('Sede actual · Cambiar sede'), findsOneWidget);
        expect(find.text('Plan Pro'), findsOneWidget);
        expect(find.text('Escáneres OBD-II'), findsOneWidget);
        expect(
          find.text('2 registros pendientes de sincronizar'),
          findsOneWidget,
        );
        expect(find.text('3 avisos sin leer'), findsOneWidget);
        expect(
          find.text('Atelier Workshop Mobile · versión 0.10.0'),
          findsOneWidget,
        );
        expect(find.text('Seguridad y sesión'), findsOneWidget);
        expect(find.text('Cerrar sesión'), findsOneWidget);
        expect(find.text('Salir de Atelier en este teléfono'), findsOneWidget);
        await _teardown(tester);
      },
    );

    testWidgets('tocar Cerrar sesión pide confirmación (US04)', (tester) async {
      var taps = 0;
      await _pump(tester, content(loaded, onSignOut: () => taps++));

      await tester.tap(find.text('Cerrar sesión'));
      expect(taps, 1);
      await _teardown(tester);
    });

    testWidgets(
      'con Atrás: resumen de cuenta; sin datos: sede desconocida y todo sincronizado',
      (tester) async {
        await _pump(tester, content(const ProfileUiState(), onBack: () {}));

        expect(find.text('Resumen de cuenta'), findsOneWidget);
        expect(find.text('Sin sede elegida'), findsWidgets);
        expect(find.text('Todo sincronizado con el servidor'), findsOneWidget);
        expect(find.text('Sin avisos nuevos'), findsOneWidget);
        await _teardown(tester);
      },
    );
  });

  group('PendingOperationsContent', () {
    PendingOperationsContent content(PendingOperationsUiState state) {
      return PendingOperationsContent(
        state: state,
        onBack: () {},
        onSyncNow: () {},
        onRetry: (_) {},
        onDiscard: (_) {},
      );
    }

    PendingOperation op(String id, String type, PendingOperationStatus status) {
      return PendingOperation(
        id: id,
        type: type,
        status: status,
        attempts: 3,
        lastErrorMessage: status == PendingOperationStatus.failed
            ? 'La foto ya no está'
            : null,
        createdAt: DateTime.utc(2026, 11, 16, 13, 2),
        dependsOn: null,
      );
    }

    testWidgets(
      'cargado: resumen, filas y hoja de detalle con reintentar y descartar',
      (tester) async {
        final state = PendingOperationsUiState(
          hasLoaded: true,
          isOnline: false,
          operations: [
            op('1', 'ATTACH_INTAKE_IMAGE', PendingOperationStatus.failed),
            op('2', 'CLOCK_IN', PendingOperationStatus.pending),
          ],
        );
        await _pump(tester, content(state));

        expect(
          find.text('1 en cola · 0 enviando · 1 con error'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Sin conexión: los registros se enviarán en cuanto vuelva la red.',
          ),
          findsOneWidget,
        );
        expect(find.text('Evidencia fotográfica de recepción'), findsOneWidget);
        expect(find.text('Creado: 16/11 08:02 · Intentos: 3'), findsWidgets);
        expect(find.text('Con error'), findsOneWidget);

        await tester.tap(find.text('Evidencia fotográfica de recepción'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('La foto ya no está'), findsOneWidget);
        expect(find.text('Reintentar'), findsOneWidget);
        expect(find.text('Descartar'), findsOneWidget);
        await _teardown(tester);
      },
    );

    testWidgets('vacío: todo sincronizado', (tester) async {
      await _pump(
        tester,
        content(const PendingOperationsUiState(hasLoaded: true)),
      );

      expect(
        find.text('Todo sincronizado. No hay nada pendiente de envío.'),
        findsOneWidget,
      );
      expect(find.textContaining('Sincronizar ahora'), findsNothing);
      await _teardown(tester);
    });
  });
}
