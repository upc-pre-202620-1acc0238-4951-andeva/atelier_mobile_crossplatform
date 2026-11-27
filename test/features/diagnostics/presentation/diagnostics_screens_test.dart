import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/health_report.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
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

Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

const _vehicle = Vehicle(
  id: 'v1',
  plate: 'BKR418',
  brand: 'Toyota',
  model: 'Hilux',
  year: 2022,
  engineType: EngineType.diesel,
);

void main() {
  setUpAll(_loadSatoshi);

  group('DiagnosticsHubContent', () {
    testWidgets('cargado sin telemetría en vivo (US18) ni envío en lote (US19)', (tester) async {
      await _pump(
        tester,
        DiagnosticsHubContent(
          state: DiagnosticsHubUiState(
            selectedVehicleId: 'v1',
            workshopVehicles: const [VehicleWithOwner(vehicle: _vehicle)],
            canUseTelemetry: true,
            canReadFaults: true,
            canUseAiDiagnostics: true,
            canReadAiReports: true,
            devices: const [
              ObdDevice(
                id: 'd1',
                deviceIdentifier: 'ELM327',
                hardwareModel: 'Vgate',
                status: DeviceStatus.active,
              ),
            ],
          ),
          actions: DiagnosticsHubActions.none(),
        ),
      );

      expect(find.text('Toyota Hilux'), findsOneWidget);
      expect(find.text('Códigos de falla (DTC)'), findsOneWidget);
      expect(find.text('Informe de salud con IA'), findsOneWidget);
      // US18 ya está en el hub; sin nada pendiente no hay aviso de sincronización (US19).
      expect(find.text('Telemetría en vivo'), findsOneWidget);
      expect(find.text('Sincronizar telemetría'), findsNothing);
      expect(find.textContaining('pendientes de sincronizar'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('US19 E1: el vehículo muestra lo capturado sin señal que espera sincronizar', (tester) async {
      await _pump(
        tester,
        DiagnosticsHubContent(
          state: DiagnosticsHubUiState(
            selectedVehicleId: 'v1',
            workshopVehicles: const [VehicleWithOwner(vehicle: _vehicle)],
            canUseTelemetry: true,
            canReadFaults: true,
            vehicleSyncState: const DiagnosticsSyncState(pendingReadings: 12, pendingFaults: 2),
          ),
          actions: DiagnosticsHubActions.none(),
        ),
      );

      expect(find.text('14 lecturas pendientes de sincronizar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('plan bloqueado y sin permiso', (tester) async {
      await _pump(
        tester,
        DiagnosticsHubContent(
          state: const DiagnosticsHubUiState(planIncludesTelemetry: false, planIncludesAi: false),
          actions: DiagnosticsHubActions.none(),
        ),
      );
      expect(find.textContaining('plan'), findsWidgets);

      await _pump(
        tester,
        DiagnosticsHubContent(
          state: const DiagnosticsHubUiState(),
          actions: DiagnosticsHubActions.none(),
        ),
      );
      expect(find.text('Tu perfil no tiene permiso para operar el módulo de diagnóstico OBD-II.'), findsOneWidget);
      await _teardown(tester);
    });
  });

  group('VehicleFaultsContent & AiHealthReportContent', () {
    testWidgets('fallas DTC cargadas, vacías y error', (tester) async {
      await _pump(
        tester,
        VehicleFaultsContent(
          state: VehicleFaultsUiState(
            vehicleId: 'v1',
            vehicle: _vehicle,
            canReadFaults: true,
            canScanFaults: true,
            isLoaded: true,
            faults: const [
              VehicleFault(
                id: 'f1',
                vehicleId: 'v1',
                dtcCode: 'P0300',
                severity: FaultSeverity.critical,
                description: 'Fallo de encendido múltiple',
                isResolved: false,
              ),
            ],
          ),
          onBack: () {},
          onRefresh: () async {},
          onScanDtcs: () {},
          onOpenClearConfirm: () {},
        ),
      );
      expect(find.text('P0300'), findsOneWidget);
      expect(find.text('Fallo de encendido múltiple'), findsOneWidget);

      await _pump(
        tester,
        VehicleFaultsContent(
          state: const VehicleFaultsUiState(
            vehicleId: 'v1',
            canReadFaults: true,
            isLoaded: true,
            error: UiText.dynamic('Error DTC'),
          ),
          onBack: () {},
          onRefresh: () async {},
          onScanDtcs: () {},
          onOpenClearConfirm: () {},
        ),
      );
      expect(find.text('Error DTC'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('informe IA cargado sin botón PDF (US43)', (tester) async {
      await _pump(
        tester,
        AiHealthReportContent(
          state: const AiHealthReportUiState(
            vehicleId: 'v1',
            vehicle: _vehicle,
            canRead: true,
            canGenerate: true,
            detail: HealthReportDetail(
              reportId: 'r1',
              vehicleId: 'v1',
              daysAnalyzed: 30,
              diagnosis: HealthDiagnosis(
                healthScore: 86,
                overallCondition: 'GOOD',
                executiveSummary: 'Motor en buen estado general.',
              ),
            ),
          ),
          onBack: () {},
          onRefresh: () async {},
          onOpenGenerate: () {},
        ),
      );
      expect(find.text('86'), findsOneWidget);
      expect(find.text('Motor en buen estado general.'), findsOneWidget);
      expect(find.text('Descargar PDF'), findsNothing);
      await _teardown(tester);
    });
  });
}
