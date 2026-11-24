import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_router.dart';
import 'package:atelier_mobile_crossplatform/main.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSession extends ChangeNotifier implements SessionManager {
  Session? current;
  int reads = 0;
  Completer<void>? gate;
  bool unreadable = false;

  @override
  Future<Session?> getSession() async {
    reads++;
    await gate?.future;
    if (unreadable) throw Exception('Keystore dañado');
    return current;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _session = Session(
  userId: 'u1',
  email: 'm@taller.pe',
  fullName: 'Andrés',
  tenantId: 't1',
  tenantName: 'Taller',
  membershipId: 'm1',
  permissions: {},
  plan: null,
);

/// Las pantallas reales las registra cada feature: aquí solo importa a cuál cambia la raíz.
void _registerStubs() {
  for (final route in AppRoute.values) {
    AppNavigator.register(route, (context, args) => Center(child: Text('destino:${route.name}')));
  }
}

void main() {
  late _FakeSession session;

  setUp(() {
    _registerStubs();
    session = _FakeSession();
  });

  testWidgets('sin sesión muestra el grafo de acceso, en español', (tester) async {
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  testWidgets('mientras lee la sesión muestra el fondo, sin spinner', (tester) async {
    session.gate = Completer();
    await tester.pumpWidget(MainApp(session: session));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('destino:'), findsNothing);

    session.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  testWidgets('si no puede leer la sesión muestra el acceso, sin spinner', (tester) async {
    session.unreadable = true;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  testWidgets('con sesión muestra el shell de la app', (tester) async {
    session.current = _session;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('destino:mainShell'), findsOneWidget);
  });

  testWidgets('sin perfil laboral muestra elegir sede, y luego la app', (tester) async {
    session.current = const Session(
      userId: 'u1',
      email: 'm@taller.pe',
      fullName: 'Andrés',
      tenantId: 't1',
      tenantName: 'Taller',
      membershipId: 'm1',
      permissions: {},
      plan: null,
      needsBranchChoice: true,
    );

    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();
    expect(find.text('destino:branchSelection'), findsOneWidget);

    session.current = _session;
    session.notifyListeners();
    await tester.pumpAndSettle();
    expect(find.text('destino:mainShell'), findsOneWidget);
  });

  testWidgets('si otro motor borra la sesión vuelve al acceso', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    session.current = null;
    session.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  testWidgets('un cambio de sesión limpia lo apilado encima', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(navigator.push(AppNavigator.routeOf(AppRoute.workOrderDetail, 'wo-1')));
    await tester.pumpAndSettle();
    expect(find.text('destino:workOrderDetail'), findsOneWidget);

    session.current = null;
    session.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('destino:workOrderDetail'), findsNothing);
    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  testWidgets('reconstruir no relee ni vuelve al fondo en blanco', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();
    final reads = session.reads;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pump();

    expect(session.reads, reads);
    expect(find.text('destino:mainShell'), findsOneWidget);
  });

  testWidgets('al releer mantiene la pantalla hasta tener el dato', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    session.gate = Completer();
    session.notifyListeners();
    await tester.pump();
    expect(find.text('destino:mainShell'), findsOneWidget);

    session.current = null;
    session.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('destino:authGraph'), findsOneWidget);
  });

  group('push', () {
    testWidgets('abre el detalle de la orden con la sesión iniciada', (tester) async {
      session.current = _session;
      final inbox = PushInbox();
      await tester.pumpWidget(MainApp(session: session, pushInbox: inbox));
      await tester.pumpAndSettle();

      inbox.post(const WorkOrderDetailDestination('wo-1'));
      await tester.pumpAndSettle();

      expect(find.text('destino:workOrderDetail'), findsOneWidget);
      expect(inbox.pending, isNull);
    });

    testWidgets('las alertas de stock (US34) no navegan a ninguna parte', (tester) async {
      session.current = _session;
      final inbox = PushInbox();
      await tester.pumpWidget(MainApp(session: session, pushInbox: inbox));
      await tester.pumpAndSettle();

      inbox.post(const LowStockAlertsDestination('item-1'));
      await tester.pumpAndSettle();

      expect(find.text('destino:mainShell'), findsOneWidget);
      expect(inbox.pending, isNull);
    });

    testWidgets('sin sesión espera: no consume el push', (tester) async {
      final inbox = PushInbox();
      await tester.pumpWidget(MainApp(session: session, pushInbox: inbox));
      await tester.pumpAndSettle();

      inbox.post(const WorkOrderDetailDestination('wo-1'));
      await tester.pumpAndSettle();

      expect(find.text('destino:workOrderDetail'), findsNothing);
      expect(inbox.pending, isNotNull);
    });
  });
}
