import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/reports/application/download_fleet_health_pdf_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/cash_flow.dart';
import 'package:atelier_mobile_crossplatform/features/reports/domain/reports_repository.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../support/step9_test_env.dart';

class _MockReports extends Mock implements ReportsRepository {}

Map<String, Object?> _cashFlow({String? currency = 'PEN', num? income = 100}) {
  return {
    'totalIncome': income,
    'totalExpenses': 0,
    'accountsReceivable': 0,
    'netCashFlow': -20.5,
    'currency': currency,
    'movements': [
      {
        'transactionId': 'p1',
        'movementDate': '2026-11-06T15:00:00Z',
        'type': 'INFLOW',
        'amount': 100,
        'runningBalance': -20.5,
      },
    ],
  };
}

void main() {
  test('periodos de mes y año; un rango invertido falla', () {
    final feb = ReportPeriod.month(2028, 2);
    expect((feb.from, feb.to), ('2028-02-01', '2028-02-29'));
    final year = ReportPeriod.year(2026);
    expect((year.from, year.to), ('2026-01-01', '2026-12-31'));
    final current = ReportPeriod.currentMonth(
      BusinessTime(now: () => DateTime.utc(2026, 12, 1, 3)), // 30 nov en Lima
    );
    expect(current.from, '2026-11-01');
    expect(
      () => ReportPeriod('2026-02-01', '2026-01-31'),
      throwsA(isA<InvalidReportInputException>()),
    );
  });

  test('PDF de flota con id vacío falla sin llamar', () async {
    final repository = _MockReports();
    await expectLater(
      DownloadFleetHealthPdfUseCase(repository: repository).execute('  '),
      throwsA(isA<InvalidReportInputException>()),
    );
    verifyNever(() => repository.downloadFleetHealthPdf(any()));
  });

  group('repositorio', () {
    late Step9TestEnv env;

    setUp(() async => env = await Step9TestEnv.create());
    tearDown(() => env.close());

    test('flujo de caja con from y to; montos negativos se aceptan', () async {
      env.responses['GET /api/v1/invoicing/financial-reports/cash-flow'] =
          (request) {
            expect(request.url.queryParameters, {
              'from': '2026-11-01',
              'to': '2026-11-30',
            });
            return json(_cashFlow());
          };
      final summary = await env.reports.getCashFlow(
        ReportPeriod.month(2026, 11),
      );
      expect(summary.netCashFlow, Decimal.parse('-20.5'));
      expect(summary.movements.single.runningBalance, Decimal.parse('-20.5'));
    });

    test('sin moneda, con una desconocida o sin un monto, falla en vez de mostrar PEN', () async {
      for (final body in [
        _cashFlow(currency: null),
        _cashFlow(currency: 'EUR'),
        _cashFlow(income: null),
      ]) {
        env.responses['GET /api/v1/invoicing/financial-reports/cash-flow'] = (
          _,
        ) => json(body);
        await expectLater(
          env.reports.getCashFlow(ReportPeriod.month(2026, 11)),
          throwsA(anyOf(isA<FormatException>(), isA<ArgumentError>())),
        );
      }
    });

    test('PDF de flota: se guarda en la caché; otro taller da el 404 con su message', () async {
      env.responses['GET /api/v1/iot/health-reports/fleet/pdf'] = (request) {
        expect(request.url.queryParameters['customerId'], 'c1');
        return http.Response.bytes([37, 80, 68, 70], 200);
      };
      final File file = await env.reports.downloadFleetHealthPdf('c1');
      expect(file.path, endsWith('salud-flota-c1.pdf'));

      env.responses['GET /api/v1/iot/health-reports/fleet/pdf'] = (_) =>
          apiError(404, 'Cliente no encontrado');
      await expectLater(
        env.reports.downloadFleetHealthPdf('c9'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'm',
            'Cliente no encontrado',
          ),
        ),
      );
    });
  });
}
