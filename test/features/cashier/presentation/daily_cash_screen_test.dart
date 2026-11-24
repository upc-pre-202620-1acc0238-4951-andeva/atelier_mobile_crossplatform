import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_screen.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/presentation/dailycash/daily_cash_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: child,
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// Quita del árbol las animaciones infinitas (huesos) antes de cerrar la prueba.
Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

Money _soles(String amount) => Money.of(amount, 'PEN');

DailyCashSummary _summary() {
  return DailyCashSummary(
    date: '2026-11-16',
    totalCollected: _soles('2840.00'),
    paymentCount: 3,
    byMethod: {
      PaymentMethod.cash: _soles('1200.00'),
      PaymentMethod.yape: _soles('940.00'),
      PaymentMethod.creditCard: _soles('700.00'),
    },
    payments: [
      Payment(
        id: 'p1',
        amount: _soles('1200.00'),
        method: PaymentMethod.cash,
        paidAt: DateTime.utc(2026, 11, 16, 15, 10),
      ),
      Payment(
        id: 'p2',
        amount: _soles('940.00'),
        method: PaymentMethod.yape,
        transactionReference: 'YP-883201',
        paidAt: DateTime.utc(2026, 11, 16, 17, 42),
      ),
      Payment(id: 'p3', amount: _soles('700.00'), method: PaymentMethod.creditCard, transactionReference: '  '),
    ],
  );
}

DailyCashUiState _state({
  DailyCashSummary? summary,
  String date = '2026-11-16',
  bool isLoading = false,
  bool isOnline = true,
  UiText? error,
  bool canRead = true,
}) {
  return DailyCashUiState(
    today: '2026-11-16',
    date: date,
    summary: summary,
    isLoading: isLoading,
    isOnline: isOnline,
    error: error,
    canRead: canRead,
  );
}

DailyCashContent _content(
  DailyCashUiState state, {
  bool showBack = true,
  VoidCallback? onPrevious,
  VoidCallback? onNext,
  VoidCallback? onToday,
}) {
  return DailyCashContent(
    state: state,
    showBack: showBack,
    onBack: () {},
    onRetry: () {},
    onPreviousDay: onPrevious ?? () {},
    onNextDay: onNext ?? () {},
    onToday: onToday ?? () {},
  );
}

void main() {
  setUpAll(_loadSatoshi);

  group('DailyCashContent', () {
    testWidgets('cargado: panel, fecha, medios de pago y cobros; sin acceso a comprobantes', (tester) async {
      await _pump(tester, _content(_state(summary: _summary())));

      expect(find.text('Caja del día'), findsOneWidget);
      expect(find.text('Caja de la sede · lun 16 nov'), findsOneWidget);
      expect(find.text('S/ 2,840.00'), findsOneWidget);
      expect(find.text('cobros'), findsOneWidget);
      expect(find.text('lunes 16 de noviembre'), findsOneWidget);
      expect(find.text('Por medio de pago'), findsOneWidget);
      // 1200 / 2840 = 42 %, 940 / 2840 = 33 %, 700 / 2840 = 25 %
      expect(find.text('42 %'), findsOneWidget);
      expect(find.text('33 %'), findsOneWidget);
      expect(find.text('25 %'), findsOneWidget);
      expect(find.text('Cobros · 3'), findsOneWidget);
      expect(find.text('16/11 10:10'), findsOneWidget);
      expect(find.text('16/11 12:42 · YP-883201'), findsOneWidget);
      // es hoy: ni "Hoy" ni día siguiente habilitado.
      expect(find.text('Hoy'), findsNothing);

      // US37: la tarjeta de comprobantes SUNAT no existe.
      expect(find.text('Comprobantes SUNAT'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('otro día: aparece "Hoy" y los botones de día avisan', (tester) async {
      var previous = 0;
      var next = 0;
      var today = 0;
      await _pump(
        tester,
        _content(
          _state(summary: _summary(), date: '2026-11-15'),
          onPrevious: () => previous++,
          onNext: () => next++,
          onToday: () => today++,
        ),
      );

      await tester.tap(find.byTooltip('Día anterior'));
      await tester.tap(find.byTooltip('Día siguiente'));
      await tester.tap(find.text('Hoy'));
      expect([previous, next, today], [1, 1, 1]);
      await _teardown(tester);
    });

    testWidgets('hoy: el día siguiente está deshabilitado', (tester) async {
      var next = 0;
      await _pump(tester, _content(_state(summary: _summary()), onNext: () => next++));

      await tester.tap(find.byTooltip('Día siguiente'));
      expect(next, 0);
      await _teardown(tester);
    });

    testWidgets('vacío: dice que no hay cobros', (tester) async {
      final empty = DailyCashSummary(
        date: '2026-11-16',
        totalCollected: _soles('0.00'),
        paymentCount: 0,
        byMethod: const {},
        payments: const [],
      );
      await _pump(tester, _content(_state(summary: empty)));

      expect(find.text('No hay cobros registrados este día.'), findsOneWidget);
      expect(find.text('Por medio de pago'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('error: muestra el mensaje y Reintentar', (tester) async {
      await _pump(tester, _content(_state(error: const UiText.dynamic('Sin sede activa'))));

      expect(find.text('Sin sede activa'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('sin red y sin datos: estado sin conexión', (tester) async {
      await _pump(tester, _content(_state(isOnline: false)));

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('sin permiso: solo el panel y el aviso', (tester) async {
      await _pump(tester, _content(_state(canRead: false)));

      expect(find.text('Tu cuenta no puede ver la caja del día.'), findsOneWidget);
      expect(find.text('lunes 16 de noviembre'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('cargando: tres filas de esqueleto', (tester) async {
      await _pump(tester, _content(_state(isLoading: true)));

      expect(find.text('Efectivo'), findsNWidgets(3));
      await _teardown(tester);
    });

    testWidgets('raíz de pestaña: sin botón Atrás', (tester) async {
      await _pump(tester, _content(_state(summary: _summary()), showBack: false));

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Caja del día'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
