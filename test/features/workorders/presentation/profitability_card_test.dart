import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/application/get_profitability_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_audit.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/profitability/profitability_card.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/presentation/detail/profitability/profitability_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProfitability extends Mock implements GetProfitabilityUseCase {}

Future<void> _loadSatoshi() async {
  final loader = FontLoader('Satoshi');
  for (final file in ['regular', 'medium', 'bold', 'black']) {
    loader.addFont(rootBundle.load('assets/fonts/satoshi_$file.otf'));
  }
  await loader.load();
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AtelierTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

/// US35 E2: 2 × S/ 5 + 1 × S/ 7 de costo FIFO (S/ 17) contra 3 × S/ 12 de venta (S/ 36): ganancia S/ 19.
Profitability _e2() => Profitability(
  workOrderId: 'wo1',
  currency: 'PEN',
  partsRevenue: Decimal.fromInt(36),
  partsCostOfSales: Decimal.fromInt(17),
  partsGrossProfit: Decimal.fromInt(19),
  lines: [
    PartProfitability(
      productId: 'p1',
      quantity: Decimal.fromInt(3),
      unitPrice: Decimal.fromInt(12),
      revenue: Decimal.fromInt(36),
      costOfSales: Decimal.fromInt(17),
      grossProfit: Decimal.fromInt(19),
    ),
  ],
);

void main() {
  setUpAll(_loadSatoshi);

  group('ProfitabilityViewModel', () {
    test('calcula a pedido y guarda el resultado', () async {
      final get = _MockGetProfitability();
      when(() => get.execute(any())).thenAnswer((_) async => _e2());
      final viewModel = ProfitabilityViewModel(
        workOrderId: 'wo1',
        getProfitability: get,
      );

      expect(viewModel.state.profitability, isNull);
      await viewModel.load();

      verify(() => get.execute(const WorkOrderId('wo1'))).called(1);
      expect(
        viewModel.state.profitability?.partsGrossProfit,
        Decimal.fromInt(19),
      );
      expect(viewModel.state.isLoading, isFalse);
      viewModel.dispose();
    });

    test('un error se guarda y conserva el último resultado', () async {
      final get = _MockGetProfitability();
      when(() => get.execute(any())).thenAnswer((_) async => _e2());
      final viewModel = ProfitabilityViewModel(
        workOrderId: 'wo1',
        getProfitability: get,
      );
      await viewModel.load();
      when(() => get.execute(any()))
          .thenAnswer((_) async => throw Exception('sin red'));

      await viewModel.load();

      expect(viewModel.state.error, isNotNull);
      expect(viewModel.state.profitability, isNotNull);
      viewModel.dispose();
    });
  });

  group('ProfitabilitySheet', () {
    testWidgets(
      'E2: muestra ingreso S/ 36.00, costo FIFO S/ 17.00 y ganancia S/ 19.00 con el desglose',
      (tester) async {
        await _pump(
          tester,
          SingleChildScrollView(
            child: ProfitabilitySheet(
              state: ProfitabilityUiState(profitability: _e2()),
              partNames: const {'p1': 'Bujía NGK'},
              onRetry: () {},
              onDismiss: () {},
            ),
          ),
        );

        expect(find.text('Rentabilidad'), findsOneWidget);
        expect(find.text('Ingreso por repuestos'), findsOneWidget);
        expect(find.text('Costo de los repuestos'), findsOneWidget);
        expect(find.text('Ganancia de repuestos'), findsOneWidget);
        expect(find.text('S/ 36.00'), findsOneWidget);
        expect(find.text('S/ 17.00'), findsWidgets);
        expect(find.text('S/ 19.00'), findsWidgets);
        expect(find.text('Bujía NGK'), findsOneWidget);
        expect(find.text('3 unid. · costo S/ 17.00'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('una ganancia negativa se muestra con signo menos', (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          child: ProfitabilitySheet(
            state: ProfitabilityUiState(
              profitability: Profitability(
                workOrderId: 'wo1',
                currency: 'PEN',
                partsRevenue: Decimal.fromInt(10),
                partsCostOfSales: Decimal.parse('14.50'),
                partsGrossProfit: Decimal.parse('-4.50'),
                lines: const [],
              ),
            ),
            onRetry: () {},
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('−S/ 4.50'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('un error ofrece reintentar', (tester) async {
      var retried = 0;
      await _pump(
        tester,
        SingleChildScrollView(
          child: ProfitabilitySheet(
            state: ProfitabilityUiState(error: const UiText.dynamic('Sin acceso')),
            onRetry: () => retried++,
            onDismiss: () {},
          ),
        ),
      );
      expect(find.text('Sin acceso'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(retried, 1);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
