import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/faults/vehicle_faults_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/live/live_telemetry_screen.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/report/ai_health_report_screen.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';

/// Destinos de diagnóstico OBD-II (equivale a `diagnosticsNavGraph`). Hub, telemetría en vivo (US18), fallas DTC
/// e informe IA sin PDF.
void registerDiagnosticsRoutes() {
  AppNavigator.register(AppRoute.diagnosticsHub, (context, args) {
    final hubArgs = args as DiagnosticsHubArgs?;
    return DiagnosticsHubScreen(initialVehicleId: hubArgs?.initialVehicleId);
  });
  AppNavigator.register(
    AppRoute.liveTelemetry,
    (context, args) => LiveTelemetryScreen(args: args as VehicleArgs),
  );
  AppNavigator.register(
    AppRoute.vehicleFaults,
    (context, args) => VehicleFaultsScreen(args: args as VehicleArgs),
  );
  AppNavigator.register(
    AppRoute.aiHealthReport,
    (context, args) => AiHealthReportScreen(args: args as VehicleArgs),
  );
}
