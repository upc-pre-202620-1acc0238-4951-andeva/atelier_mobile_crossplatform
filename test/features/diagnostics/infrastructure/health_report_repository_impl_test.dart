import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../support/diagnostics_test_env.dart';

void main() {
  const generatePath = '/api/v1/iot/health-reports/generate';
  late DiagnosticsTestEnv env;

  setUp(() async {
    env = await DiagnosticsTestEnv.create();
    await env.signIn();
  });

  tearDown(() => env.close());

  test('generar envía el vehículo y los días a analizar', () async {
    env.responses['POST $generatePath'] = (_) =>
        jsonResponse(healthReportJson(), 201);

    final report = await env.healthReports.generate(
      'v1',
      daysToAnalyze: 30,
      includeResolvedDtcHistory: true,
    );

    expect(report.overallHealthScore, 78);
    final request = env.requested('POST', generatePath).single;
    expect(request.url.queryParameters['vehicleId'], 'v1');
    expect(request.body, '{"daysToAnalyze":30,"includeResolvedDtcHistory":true}');
  });

  test('422 y 502 llegan con su código HTTP y el message', () async {
    env.responses['POST $generatePath'] = (_) =>
        apiError(422, 'Telemetría insuficiente en el período');
    await expectLater(
      env.healthReports.generate('v1', daysToAnalyze: 7),
      throwsA(
        isA<ApiException>().having((e) => e.httpStatus, 'httpStatus', 422),
      ),
    );

    env.responses['POST $generatePath'] = (_) =>
        apiError(502, 'IA no disponible');
    await expectLater(
      env.healthReports.generate('v1', daysToAnalyze: 7),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', 'IA no disponible'),
      ),
    );
  });

  test('último informe, detalle y PDF', () async {
    expect(await env.healthReports.getLatest('v1'), isNull);

    env.responses['GET /api/v1/iot/health-reports/latest'] = (_) =>
        jsonResponse(healthReportJson());
    expect((await env.healthReports.getLatest('v1'))?.reportId, 'r1');

    env.responses['GET /api/v1/iot/health-reports/r1'] = (_) => jsonResponse({
      'reportId': 'r1',
      'vehicleId': 'v1',
      'daysAnalyzed': 30,
      'generatedAt': '2026-10-24T14:00:00Z',
      'diagnosis': {
        'healthScore': 78,
        'overallCondition': 'GOOD',
        'recommendedActions': [
          {'serviceName': 'Cambio de refrigerante', 'estimatedCost': 180.5},
        ],
      },
    });
    final detail = await env.healthReports.getDetail('r1');
    final action = detail.diagnosis!.recommendedActions.single;
    expect(action.serviceName, 'Cambio de refrigerante');
    expect(action.estimatedCost.toString(), '180.5');
    expect(detail.diagnosis!.predictiveRisks, isEmpty);

    env.responses['GET /api/v1/iot/health-reports/r1/pdf'] = (_) => http.Response(
      '%PDF-1.7',
      200,
      headers: {'content-disposition': 'attachment; filename="informe-ABC123.pdf"'},
    );
    final pdf = await env.healthReports.downloadPdf('r1');
    expect(pdf.path, endsWith('informe-ABC123.pdf'));
    expect(await pdf.readAsString(), '%PDF-1.7');
  });
}
