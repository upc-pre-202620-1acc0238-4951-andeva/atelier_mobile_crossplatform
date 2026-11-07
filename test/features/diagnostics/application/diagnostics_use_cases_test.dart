import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/clear_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/freeze_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/generate_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/install_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/scan_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/uninstall_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements DiagnosticsRepository {}

class _MockReports extends Mock implements HealthReportRepository {}

class _MockLink extends Mock implements ObdLink {}

class _FakeSession extends Fake implements DiagnosticSession {
  final ObdLink link;

  @override
  String? sessionId = 's1';

  _FakeSession(this.link);

  @override
  Future<T> withLink<T>(Future<T> Function(ObdLink link) block) => block(link);

  @override
  TelemetrySnapshot? freeze() => null;
}

Dtc _dtc(String code) => Dtc.of(code)!;

VehicleFault _fault(String id, String code) {
  return VehicleFault(
    id: id,
    vehicleId: 'v1',
    dtc: _dtc(code),
    dtcCode: code,
    description: '',
    isResolved: false,
  );
}

Matcher _invalid(String field) {
  return isA<InvalidDiagnosticsInputException>().having(
    (e) => e.field,
    'field',
    field,
  );
}

void main() {
  late _MockRepository repository;
  late _MockLink link;
  late _FakeSession session;

  setUp(() {
    repository = _MockRepository();
    link = _MockLink();
    session = _FakeSession(link);
  });

  test('escanear sin conexión falla y sin códigos queda limpio', () async {
    final useCase = ScanFaultsUseCase(session: session, repository: repository);
    session.sessionId = null;
    await expectLater(
      useCase.execute('v1'),
      throwsA(isA<ObdNotConnectedException>()),
    );

    session.sessionId = 's1';
    when(() => link.readDtcs()).thenAnswer((_) async => const []);
    when(
      () => repository.registerDetectedFaults('v1', const [], 's1'),
    ).thenAnswer((_) async => const []);

    final result = await useCase.execute('v1');

    expect(result.isClean, isTrue);
    expect(result.freezeFrame, isNull);
    verifyNever(() => link.readFreezeFrame());
  });

  test('escanear registra los códigos con la sesión y trae el cuadro congelado', () async {
    final dtcs = [_dtc('P0304')];
    final frame = FreezeFrame(dtc: dtcs.first);
    when(() => link.readDtcs()).thenAnswer((_) async => dtcs);
    when(() => link.readFreezeFrame()).thenAnswer((_) async => frame);
    when(
      () => repository.registerDetectedFaults('v1', dtcs, 's1'),
    ).thenAnswer((_) async => [_fault('local-1', 'P0304')]);

    final result = await ScanFaultsUseCase(
      session: session,
      repository: repository,
    ).execute('v1');

    expect(result.faults.single.id, 'local-1');
    expect(result.freezeFrame, frame);
  });

  test('si falla el cuadro congelado los códigos valen igual', () async {
    final dtcs = [_dtc('P0304')];
    when(() => link.readDtcs()).thenAnswer((_) async => dtcs);
    when(
      () => link.readFreezeFrame(),
    ).thenThrow(const ObdConnectionLostException());
    when(
      () => repository.registerDetectedFaults('v1', dtcs, 's1'),
    ).thenAnswer((_) async => [_fault('local-1', 'P0304')]);

    final result = await ScanFaultsUseCase(
      session: session,
      repository: repository,
    ).execute('v1');

    expect(result.faults, hasLength(1));
    expect(result.freezeFrame, isNull);
  });

  test('borrar re-lee los códigos y pasa los que persisten', () async {
    final remaining = [_dtc('P0420')];
    when(() => link.clearDtcs()).thenAnswer((_) async {});
    when(() => link.readDtcs()).thenAnswer((_) async => remaining);
    when(() => repository.applyClearedFaults('v1', remaining, 's1')).thenAnswer(
      (_) async => ClearFaultsResult(
        cleared: [_fault('f1', 'P0304')],
        persistent: [_fault('f2', 'P0420')],
      ),
    );

    final result = await ClearFaultsUseCase(
      session: session,
      repository: repository,
    ).execute('v1');

    expect(result.persistent.map((f) => f.id), ['f2']);
    expect(result.isClean, isFalse);
    verifyInOrder([() => link.clearDtcs(), () => link.readDtcs()]);
  });

  test('informe IA valida los días y traduce el 422', () async {
    final reports = _MockReports();
    final generate = GenerateHealthReportUseCase(repository: reports);

    await expectLater(
      generate.execute('v1', daysToAnalyze: 5),
      throwsA(_invalid('daysToAnalyze')),
    );
    verifyZeroInteractions(reports);

    when(() => reports.generate('v1', daysToAnalyze: 30)).thenThrow(
      const ApiException(
        httpStatus: 422,
        code: 'ERR_INSUFFICIENT_TELEMETRY',
        message: 'Telemetría insuficiente',
      ),
    );
    await expectLater(
      generate.execute('v1', daysToAnalyze: 30),
      throwsA(
        isA<InsufficientTelemetryException>().having(
          (e) => e.message,
          'message',
          'Telemetría insuficiente',
        ),
      ),
    );

    when(() => reports.generate('v1', daysToAnalyze: 30)).thenThrow(
      const ApiException(
        httpStatus: 403,
        code: 'QUOTA_EXCEEDED',
        message: 'Cuota de IA agotada',
      ),
    );
    await expectLater(
      generate.execute('v1', daysToAnalyze: 30),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Cuota de IA agotada',
        ),
      ),
    );
  });

  test('odómetro negativo y congelar sin muestra', () async {
    await expectLater(
      InstallObdDeviceUseCase(repository: repository).execute(
        deviceId: 'd1',
        vehicleId: 'v1',
        currentOdometerKm: -5,
      ),
      throwsA(_invalid('currentOdometerKm')),
    );
    await expectLater(
      UninstallObdDeviceUseCase(
        repository: repository,
      ).execute('i1', finalOdometerKm: -1),
      throwsA(_invalid('finalOdometerKm')),
    );
    verifyZeroInteractions(repository);

    expect(
      () => FreezeTelemetryUseCase(session: session).execute(),
      throwsA(isA<ObdNotConnectedException>()),
    );
  });
}
