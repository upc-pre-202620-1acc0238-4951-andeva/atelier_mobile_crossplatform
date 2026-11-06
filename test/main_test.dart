import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/main.dart';
import 'package:flutter/foundation.dart';
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

void main() {
  late _FakeSession session;

  setUp(() => session = _FakeSession());

  testWidgets('sin sesión muestra el login, en español', (tester) async {
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión'), findsOneWidget);
  });

  testWidgets('si no puede leer la sesión muestra el login, sin spinner', (
    tester,
  ) async {
    session.unreadable = true;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión'), findsOneWidget);
  });

  testWidgets('con sesión muestra la app', (tester) async {
    session.current = _session;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    expect(find.text('Sesión iniciada'), findsOneWidget);
  });

  testWidgets('si otro motor borra la sesión vuelve al login', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    session.current = null;
    session.notifyListeners();
    await tester.pumpAndSettle();

    expect(find.text('Inicio de sesión'), findsOneWidget);
  });

  testWidgets('reconstruir no relee ni vuelve al spinner', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();
    final reads = session.reads;

    await tester.pumpWidget(MainApp(session: session));
    await tester.pump();

    expect(session.reads, reads);
    expect(find.text('Sesión iniciada'), findsOneWidget);
  });

  testWidgets('al releer mantiene la pantalla hasta tener el dato', (tester) async {
    session.current = _session;
    await tester.pumpWidget(MainApp(session: session));
    await tester.pumpAndSettle();

    session.gate = Completer();
    session.notifyListeners();
    await tester.pump();
    expect(find.text('Sesión iniciada'), findsOneWidget);

    session.current = null;
    session.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Inicio de sesión'), findsOneWidget);
  });
}
