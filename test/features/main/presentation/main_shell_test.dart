import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/session_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_shell_controller.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/main_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/navigation/main_tab.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSessionRepository extends Mock implements SessionRepository {}

class _MockPendingRepository extends Mock implements PendingOperationRepository {}

Session _session(Iterable<Permission> permissions, {String email = 'm@taller.pe'}) => Session(
  userId: 'u1',
  email: email,
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: {for (final p in permissions) p.value},
  plan: null,
);

final _admin = _session([
  Permission.attendanceAuditAll,
  Permission.workOrdersRead,
  Permission.workOrdersCreate,
  Permission.customersRead,
  Permission.invoicesRead,
  Permission.cashflowExportPdf,
  Permission.fiscalConfigManage,
  Permission.baysRead,
  Permission.alertsRead,
  Permission.partsRead,
]);

void main() {
  late StreamController<Session?> sessions;
  late StreamController<int> pending;

  setUp(() {
    for (final route in AppRoute.values) {
      AppNavigator.register(route, (context, args) => Scaffold(body: Center(child: Text('pantalla:${route.name}'))));
    }
    sessions = StreamController<Session?>.broadcast();
    pending = StreamController<int>.broadcast();
  });

  tearDown(() async {
    await sessions.close();
    await pending.close();
  });

  MainViewModel viewModel(Session session) {
    final sessionRepository = _MockSessionRepository();
    when(sessionRepository.watchSession).thenAnswer((_) => sessions.stream);
    final pendingRepository = _MockPendingRepository();
    when(pendingRepository.watchCount).thenAnswer((_) => pending.stream);
    return MainViewModel(
      observeSessionUseCase: ObserveSessionUseCase(repository: sessionRepository),
      observePendingCountUseCase: ObservePendingOperationCountUseCase(repository: pendingRepository),
      initialSession: session,
    );
  }

  Widget host(MainViewModel vm) => MaterialApp(
    theme: AtelierTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: MainShell(viewModel: vm),
  );

  testWidgets('arranca en la primera pestaña con la barra de la sesión y "Módulos"', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();

    expect(find.text('pantalla:adminDashboard'), findsOneWidget);
    for (final label in ['Hoy', 'Órdenes', 'Equipo', 'Módulos']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Bahías no existe como pestaña aunque la sesión tenga el permiso.
    expect(find.text('Bahías'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('cambiar de pestaña conserva la anterior y construye la nueva una vez', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Órdenes'));
    await tester.pumpAndSettle();
    expect(find.text('pantalla:workOrders'), findsOneWidget);
    // La anterior sigue viva, fuera de la vista.
    expect(find.text('pantalla:adminDashboard', skipOffstage: false), findsOneWidget);
    expect(find.text('pantalla:adminDashboard'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('un detalle empujado al Navigator raíz cubre la barra; navigateToTab vuelve a ella', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();

    MainShellController.current!.openRoute(AppRoute.workOrderDetail, args: 'wo-1');
    await tester.pumpAndSettle();
    expect(find.text('pantalla:workOrderDetail'), findsOneWidget);
    expect(find.text('Módulos'), findsNothing);

    expect(MainShellController.current!.navigateToTab(MainTab.team), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('pantalla:workOrderDetail'), findsNothing);
    expect(find.text('pantalla:adminAttendance'), findsOneWidget);
    expect(find.text('Módulos'), findsOneWidget);

    // Una pestaña que la sesión no tiene no hace nada.
    expect(MainShellController.current!.navigateToTab(MainTab.cash), isFalse);

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('"Módulos" abre la hoja con Comprobantes SUNAT (US37) y sin Bahías, series ni alertas', (
    tester,
  ) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Módulos'));
    await tester.pumpAndSettle();

    expect(find.text('Todos los módulos'), findsOneWidget);
    expect(find.text('Caja del día'), findsOneWidget);
    expect(find.text('Comprobantes SUNAT'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Catálogo de repuestos'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('m@taller.pe'), findsOneWidget);
    for (final excluded in ['Bahías', 'Series de comprobantes', 'Alertas de stock']) {
      expect(find.text(excluded), findsNothing, reason: excluded);
    }

    // Un módulo que no es pestaña se empuja al raíz y cierra la hoja.
    await tester.tap(find.text('Catálogo de repuestos'));
    await tester.pumpAndSettle();
    expect(find.text('Todos los módulos'), findsNothing);
    expect(find.text('pantalla:partsCatalog'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('un módulo que es pestaña de la barra cambia de pestaña en vez de apilarse', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Módulos'));
    await tester.pumpAndSettle();
    expect(find.text('Órdenes de trabajo'), findsNothing); // Órdenes ya está en la barra.

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('el contador de pendientes aparece sobre "Módulos" y en la hoja', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    pending.add(3);
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('Módulos'));
    await tester.pumpAndSettle();
    expect(find.text('Pendientes de sincronizar'), findsOneWidget);
    expect(find.text('3'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });

  testWidgets('si la sesión pierde la pestaña a la vista, vuelve a la primera', (tester) async {
    final vm = viewModel(_admin);
    await tester.pumpWidget(host(vm));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
    expect(find.text('pantalla:adminAttendance'), findsOneWidget);

    sessions.add(_session([Permission.workOrdersCreate, Permission.workOrdersRead, Permission.customersRead]));
    await tester.pumpAndSettle();

    expect(find.text('Equipo'), findsNothing);
    expect(find.text('Recepción'), findsOneWidget);
    expect(find.text('pantalla:adminDashboard'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    vm.dispose();
  });
}
