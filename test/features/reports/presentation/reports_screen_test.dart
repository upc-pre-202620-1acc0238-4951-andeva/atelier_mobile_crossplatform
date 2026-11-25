import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_screen.dart';
import 'package:atelier_mobile_crossplatform/features/reports/presentation/reports_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
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

const _today = '2026-11-16';

ReportsUiState _state({
  CashFlowSummary? summary,
  bool isLoading = false,
  bool isOnline = true,
  UiText? error,
  bool canRead = true,
  PeriodChoice choice = PeriodChoice.thisMonth,
}) {
  return ReportsUiState(
    today: _today,
    choice: choice,
    period: periodFor(choice, _today),
    summary: summary,
    isLoading: isLoading,
    isOnline: isOnline,
    error: error,
    canReadCashFlow: canRead,
  );
}

CashFlowSummary _summary({List<CashFlowMovement>? movements}) {
  return CashFlowSummary(
    totalIncome: Money.of('18450.00', 'PEN'),
    totalExpenses: Money.of('0.00', 'PEN'),
    accountsReceivable: Money.of('0.00', 'PEN'),
    netCashFlow: Decimal.parse('18450.00'),
    currency: 'PEN',
    movements:
        movements ??
        [
          CashFlowMovement(
            transactionId: 'm1',
            movementDate: DateTime.utc(2026, 11, 14, 16, 20),
            type: 'INFLOW',
            category: 'PAYMENT',
            concept: 'Cobro boleta B001-00000944',
            referenceNumber: 'B001-944',
            amount: Decimal.parse('1200.00'),
            runningBalance: Decimal.parse('1200.00'),
          ),
          CashFlowMovement(
            transactionId: 'm2',
            movementDate: DateTime.utc(2026, 11, 15, 14, 5),
            type: 'OUTFLOW',
            category: 'REFUND',
            concept: '  ',
            referenceNumber: 'F001-128',
            amount: Decimal.parse('-354.50'),
            runningBalance: Decimal.parse('845.50'),
          ),
        ],
  );
}

ReportsContent _content(ReportsUiState state, {VoidCallback? onOpenCustomRange, ValueChanged<PeriodChoice>? onChoice}) {
  return ReportsContent(
    state: state,
    onBack: () {},
    onRetry: () async {},
    onChoice: onChoice ?? (_) {},
    onOpenCustomRange: onOpenCustomRange ?? () {},
  );
}

void main() {
  setUpAll(_loadSatoshi);

  group('ReportsContent', () {
    testWidgets('cargado: panel, avisos, periodo, descargas PDF flujo de caja (US41) y movimientos', (tester) async {
      await _pump(tester, _content(_state(summary: _summary())));

      expect(find.text('Reportes'), findsOneWidget);
      expect(find.text('S/ 18,450.00'), findsOneWidget);
      expect(find.text('movimientos'), findsOneWidget);
      expect(find.text('El reporte suma todas las sedes del taller, no solo la tuya.'), findsOneWidget);
      expect(find.textContaining('egresos y cuentas por cobrar no se contabilizan'), findsOneWidget);
      expect(find.text('Este mes'), findsOneWidget);
      expect(find.text('Rango'), findsOneWidget);
      expect(find.text('01/11/2026 al 30/11/2026'), findsOneWidget);
      expect(find.text('Movimientos · 2'), findsOneWidget);
      expect(find.text('Cobro boleta B001-00000944'), findsOneWidget);
      expect(find.text('S/ 1,200.00'), findsOneWidget);
      // concepto en blanco: cae en la categoría; el negativo lleva signo menos.
      expect(find.text('REFUND'), findsOneWidget);
      expect(find.text('−S/ 354.50'), findsOneWidget);

      // US41: descargas PDF de flujo de caja presentes; US43 (flota) sigue excluido.
      expect(find.text('Descargas'), findsOneWidget);
      expect(find.text('Abrir PDF'), findsOneWidget);
      expect(find.text('Compartir PDF'), findsOneWidget);
      expect(find.textContaining('flota'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('vacío: dice que no hay movimientos', (tester) async {
      await _pump(tester, _content(_state(summary: _summary(movements: const []))));

      expect(find.text('No hay movimientos en este periodo.'), findsOneWidget);
      expect(find.text('Movimientos · 0'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('error: muestra el mensaje y Reintentar', (tester) async {
      await _pump(tester, _content(_state(error: const UiText.dynamic('Servicio no disponible'))));

      expect(find.text('Servicio no disponible'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('sin red y sin datos: estado sin conexión', (tester) async {
      await _pump(tester, _content(_state(isOnline: false)));

      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsWidgets);
      await _teardown(tester);
    });

    testWidgets('sin permiso: solo el aviso, sin panel ni periodos', (tester) async {
      await _pump(tester, _content(_state(canRead: false)));

      expect(find.text('Tu cuenta no tiene acceso a reportes.'), findsOneWidget);
      expect(find.text('Este mes'), findsNothing);
      expect(find.textContaining('cobrado en el periodo'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('cargando: esqueleto tras 150 ms', (tester) async {
      await _pump(tester, _content(_state(isLoading: true)));

      expect(find.text('Concepto del cobro'), findsNWidgets(3));
      await _teardown(tester);
    });

    testWidgets('elegir un periodo y Rango avisan a quien llama', (tester) async {
      PeriodChoice? chosen;
      var openedRange = false;
      await _pump(
        tester,
        _content(
          _state(summary: _summary()),
          onChoice: (choice) => chosen = choice,
          onOpenCustomRange: () => openedRange = true,
        ),
      );

      await tester.tap(find.text('Este año'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(chosen, PeriodChoice.thisYear);

      await tester.tap(find.text('Rango'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(openedRange, isTrue);
      await _teardown(tester);
    });
  });
}
