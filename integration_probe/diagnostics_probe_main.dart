import 'dart:async';
import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_worker.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/clear_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/connect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/disconnect_obd_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/generate_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_active_installation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_latest_health_report_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/get_obd_devices_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/install_obd_device_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_diagnostics_sync_state_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/observe_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/refresh_vehicle_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/scan_faults_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/start_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/application/stop_live_telemetry_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostic_session.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/elm327_obd_link.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/obd_foreground_controller.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/bluetooth/spp_obd_transport.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/session/live_diagnostic_session.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

const _user = 'probe-user';
const _adapter = ObdAdapter(
  name: 'ECU simulada',
  address: 'SIM:OB:D2:00:00:01',
  kind: ObdAdapterKind.classic,
);

/// ELM327 y ECU simulados: el emulador no tiene Bluetooth. Por encima todo es real.
class _SimulatedEcu implements ObdTransport {
  final _incoming = StreamController<String>.broadcast();
  List<String> dtcs = const [];
  Set<String> persistent = const {};
  bool withTemperature = true;

  @override
  Stream<String> get incoming => _incoming.stream;

  @override
  Future<void> connect(String address) async {}

  @override
  Future<void> disconnect() async {}

  String _respond(String command) {
    switch (command) {
      case 'ATZ':
        return 'ELM327 v1.5';
      case '0100':
        return 'SEARCHING...\r4100BE3EB811';
      case 'ATDPN':
        return 'A6';
      case '0902':
        return '014\r0:490201314731\r1:4A433534343452\r2:37323532333637';
      case '03':
        if (dtcs.isEmpty) return 'NO DATA';
        final count = dtcs.length.toRadixString(16).padLeft(2, '0');
        return '43$count${dtcs.map((code) => code.substring(1)).join()}';
      case '04':
        dtcs = dtcs.where(persistent.contains).toList();
        return '44';
      case '0105':
        return withTemperature ? '41057B' : 'NO DATA';
      case '010C':
        return '410C1AF8';
      case '010D':
        return '410D00';
      case 'ATRV':
        return '13.9V';
      case '012F':
        return '412F9C';
      case '010B':
        return '410B23';
      case 'ATE0' || 'ATL0' || 'ATS0' || 'ATH0' || 'ATSP0':
        return 'OK';
      default:
        return 'NO DATA';
    }
  }

  @override
  Future<void> send(String command) async {
    final response = '${_respond(command)}\r\r>';
    scheduleMicrotask(() => _incoming.add(response));
  }
}

final _ecu = _SimulatedEcu();

/// Prueba del paso 8 con worker, cola, Drift, servicio y canal SPP reales; solo la ECU es simulada. No se publica.
@pragma('vm:entry-point')
void probeDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('PROBE worker arranca $task');
    setupDependencies();
    final ok = await runSyncTask();
    debugPrint('PROBE worker termina ok=$ok');
    return ok;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  // Solo cambian el transporte y el ritmo: 2 s por muestra harían falta 7 minutos para cruzar un lote.
  getIt.unregister<ObdLink>();
  getIt.registerLazySingleton<ObdLink>(
    () => Elm327ObdLink(transportFor: (_) => _ecu),
  );
  getIt.unregister<DiagnosticSession>();
  getIt.registerLazySingleton<DiagnosticSession>(
    () => LiveDiagnosticSession(
      link: getIt<ObdLink>(),
      repository: getIt<DiagnosticsRepository>(),
      locationProvider: getIt<LocationProvider>(),
      foreground: getIt<ObdForegroundController>(),
      sampleInterval: const Duration(milliseconds: 5),
    ),
  );

  final session = getIt<SessionManager>();
  await session.clearIfReinstalled();
  final database = getIt<AppDatabase>();
  await database.customSelect('SELECT 1').get();
  await Workmanager().initialize(probeDispatcher);
  await getIt<ConnectivityObserver>().start();
  LocalChangeNotifier.listenInUi(
    database,
    session,
    sync: getIt<SyncProcessor>().runDetached,
  );

  if (await session.getSession() == null) {
    final seed = await http.get(
      Uri.parse('${AppConfig.apiBaseUrl}/control/session'),
    );
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(utf8.decode(seed.bodyBytes))),
    );
    debugPrint('PROBE sesión sembrada');
  }

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('En linea', _guarded(_online)),
              _button('Sin red', _guarded(_offline)),
              _button('Ver', _guarded(_show)),
              _button('Servicio', _guarded(_service)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _button(String label, VoidCallback onPressed) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      height: 96,
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    ),
  );
}

VoidCallback _guarded(Future<void> Function() run) {
  return () async {
    try {
      await run();
    } catch (error, stack) {
      debugPrint('PROBE FALLA excepción $error\n$stack');
    }
  };
}

void _check(String name, bool passed, [Object? detail]) {
  debugPrint('PROBE ${passed ? 'OK' : 'FALLA'} $name ${detail ?? ''}');
}

Future<Map<String, dynamic>> _stats() async {
  final response = await http.get(
    Uri.parse('${AppConfig.apiBaseUrl}/control/iot'),
  );
  return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
}

Future<bool> _until(
  FutureOr<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 60),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return false;
}

Future<List<PendingOperationEntity>> _queue() {
  return getIt<PendingOperationDao>().watchForUser(_user).first;
}

Future<int> _rows(String vehicleId) async {
  return (await getIt<TelemetryReadingDao>().findForVehicle(vehicleId)).length;
}

/// Muestrea hasta guardar [count] lecturas más y detiene la sesión, que encola el resto.
Future<void> _sample(String vehicleId, int count) async {
  final target = await _rows(vehicleId) + count;
  await getIt<StartLiveTelemetryUseCase>().execute(vehicleId);
  await _until(() async => await _rows(vehicleId) >= target);
  await getIt<StopLiveTelemetryUseCase>().execute();
}

Future<void> _online() async {
  await _installation();
  await getIt<ConnectObdUseCase>().execute(_adapter);
  await _telemetry();
  await _noTemperature();
  await _faults();
  await _noInstallation();
  await _reports();
  await _realSpp();
  await getIt<DisconnectObdUseCase>().execute();
  debugPrint('PROBE en linea terminado');
}

Future<void> _installation() async {
  final devices = await getIt<GetObdDevicesUseCase>().execute();
  _check('dispositivos', devices.single.matches(_adapter.address), devices.length);
  final none = await getIt<GetActiveInstallationUseCase>().execute('v1');
  _check('sin instalacion da null', none == null);

  final install = getIt<InstallObdDeviceUseCase>();
  for (final vehicleId in ['v1', 'v2']) {
    await install.execute(deviceId: 'd1', vehicleId: vehicleId, currentOdometerKm: 45000);
  }
  try {
    await install.execute(deviceId: 'd1', vehicleId: 'v1');
    _check('409 de instalacion', false, 'no falló');
  } on ApiException catch (e) {
    _check('409 de instalacion con su message', e.httpStatus == 409, e.message);
  }
}

Future<void> _telemetry() async {
  await _sample('v1', 450);
  final rows = await _rows('v1');
  final queued = await _until(() async => (await _queue()).isEmpty);
  final stats = await _stats();
  final sent = (stats['readings'] as Map)['v1'];
  _check('lecturas guardadas y enviadas en lotes', queued && sent == rows, 'filas=$rows backend=$sent lotes=${stats['batches']}');
  _check('mas de un lote de 200', (stats['batches'] as int) >= 3, stats['batches']);
  _check('ninguna lectura repetida', stats['duplicates'] == 0, stats['duplicates']);
  final state = await getIt<ObserveDiagnosticsSyncStateUseCase>().execute('v1').first;
  _check('nada pendiente', state.pendingReadings == 0, state.pendingReadings);
}

Future<void> _noTemperature() async {
  final before = await _rows('v1');
  _ecu.withTemperature = false;
  await getIt<StartLiveTelemetryUseCase>().execute('v1');
  final sampled = await _until(() async {
    final live = await getIt<ObserveLiveTelemetryUseCase>().execute().first;
    return live.sample?.engineTempCelsius == null && live.sample?.engineRpm != null;
  }, timeout: const Duration(seconds: 10));
  await Future<void>.delayed(const Duration(milliseconds: 300));
  await getIt<StopLiveTelemetryUseCase>().execute();
  _ecu.withTemperature = true;
  _check('H23 sin temperatura no se guarda', sampled && await _rows('v1') == before, await _rows('v1') - before);
}

Future<void> _faults() async {
  _ecu
    ..dtcs = ['P0304', 'P0420']
    ..persistent = {'P0420'};
  final scan = getIt<ScanFaultsUseCase>();
  final first = await scan.execute('v1');
  _check('escaneo deja las fallas locales', first.faults.every((f) => f.isPending), first.faults.map((f) => f.id).toList());
  await _until(() async => (await _queue()).isEmpty);
  var active = await getIt<ObserveVehicleFaultsUseCase>().execute('v1').first;
  _check('REGISTER_FAULT reemplaza el id', active.length == 2 && active.every((f) => !f.isPending), active.map((f) => f.id).toList());

  await scan.execute('v1');
  await _until(() async => (await _queue()).isEmpty);
  _check('volver a escanear no repite', (await _stats())['faultPosts'] == 2);

  // R3: el DTC ya está activo en el backend, pero esta caché no lo sabe.
  await getIt<VehicleFaultDao>().deleteById(active.first.id);
  await scan.execute('v1');
  await _until(() async => (await _queue()).isEmpty);
  var stats = await _stats();
  _check('R3 devuelve la falla activa', stats['faultPosts'] == 3 && (stats['activeFaults'] as List).length == 2, stats['activeFaults']);

  final cleared = await getIt<ClearFaultsUseCase>().execute('v1');
  _check('borrar reporta la persistente', !cleared.isClean && cleared.persistent.single.dtcCode == 'P0420', cleared.persistent.map((f) => f.dtcCode).toList());
  await _until(() async => (await _queue()).isEmpty);
  stats = await _stats();
  _check('RESOLVE_FAULT llega', (stats['resolvedFaults'] as List).single == 'P0304' && (stats['activeFaults'] as List).single == 'P0420', stats);

  await getIt<RefreshVehicleFaultsUseCase>().execute('v1');
  active = await getIt<ObserveVehicleFaultsUseCase>().execute('v1').first;
  _check('recarga coincide con el backend', active.single.dtcCode == 'P0420', active.length);
  _ecu.dtcs = const [];
}

Future<void> _noInstallation() async {
  await _sample('v-sin-escaner', 3);
  final failed = await _until(() async {
    return (await _queue()).any((op) => op.status == 'FAILED');
  });
  final queue = await _queue();
  final operation = queue.firstWhere((op) => op.status == 'FAILED', orElse: () => queue.first);
  _check('H16 lote sin instalacion queda FAILED con su message', failed, operation.lastErrorMessage);
  await getIt<PendingOperationDao>().discardUnlessSyncing([operation.id]);
}

Future<void> _reports() async {
  final generate = getIt<GenerateHealthReportUseCase>();
  final report = await generate.execute('v1', daysToAnalyze: 30);
  _check('informe 201', report.overallHealthScore == 78, report.reportId);
  final latest = await getIt<GetLatestHealthReportUseCase>().execute('v1');
  _check('ultimo informe', latest?.reportId == report.reportId, latest?.reportId);
  try {
    await generate.execute('v-corto', daysToAnalyze: 30);
    _check('informe 422', false, 'no falló');
  } on InsufficientTelemetryException catch (e) {
    _check('informe 422', true, e.message);
  }
  try {
    await generate.execute('v-sin-cuota', daysToAnalyze: 30);
    _check('informe 403', false, 'no falló');
  } on ApiException catch (e) {
    _check('informe 403 con su message', e.httpStatus == 403, e.message);
  }
  try {
    await generate.execute('v1', daysToAnalyze: 3);
    _check('dias invalidos', false, 'no falló');
  } on InvalidDiagnosticsInputException catch (e) {
    _check('dias invalidos no llaman', e.field == 'daysToAnalyze');
  }
}

/// El canal Kotlin real, sin adaptador: `BluetoothDisabled` con `cmd bluetooth_manager disable`,
/// `ObdAdapterUnreachable` con el Bluetooth del emulador prendido.
Future<void> _realSpp() async {
  const spp = SppObdTransport();
  try {
    await spp.connect('00:11:22:33:44:55');
    _check('SPP sin adaptador', false, 'conectó');
  } on Exception catch (e) {
    debugPrint('PROBE SPP connect lanza ${e.runtimeType}');
  }
  try {
    final bonded = await spp.bondedAdapters();
    _check('SPP lista de emparejados por el canal', bonded.isEmpty, bonded.length);
  } on Exception catch (e) {
    debugPrint('PROBE SPP emparejados lanza ${e.runtimeType}');
  }
}

/// Sin red: lecturas y fallas de `v2` quedan en cola; las envía el worker con la app muerta.
Future<void> _offline() async {
  await getIt<ConnectObdUseCase>().execute(_adapter);
  await _sample('v2', 250);
  _ecu.dtcs = ['P0171', 'P0300'];
  final scan = await getIt<ScanFaultsUseCase>().execute('v2');
  _check('fallas capturadas sin red', scan.faults.every((f) => f.isPending), scan.faults.length);
  await getIt<DisconnectObdUseCase>().execute();
  await _until(
    () async => (await _queue()).every((op) => op.attempts > 0),
    timeout: const Duration(seconds: 20),
  );
  final queue = await _queue();
  for (final op in queue) {
    debugPrint('PROBE cola ${op.type} ${op.status} intentos=${op.attempts} error=${op.lastErrorMessage}');
  }
  final batches = queue.where((op) => op.type == 'TELEMETRY_BATCH').length;
  final faults = queue.where((op) => op.type == 'REGISTER_FAULT').length;
  _check('cola sin red', batches == 2 && faults == 2, 'lotes=$batches fallas=$faults');
  final state = await getIt<ObserveDiagnosticsSyncStateUseCase>().execute('v2').first;
  _check('pendientes sin red', state.pendingFaults == 2 && state.pendingReadings >= 250, 'lecturas=${state.pendingReadings} fallas=${state.pendingFaults}');
  debugPrint('PROBE sin red terminado');
}

Future<void> _show() async {
  final queue = await _queue();
  debugPrint('PROBE ver cola total=${queue.length}');
  final state = await getIt<ObserveDiagnosticsSyncStateUseCase>().execute('v2').first;
  final active = await getIt<ObserveVehicleFaultsUseCase>().execute('v2').first;
  debugPrint(
    'PROBE ver v2 lecturas=${state.pendingReadings} fallasPendientes=${state.pendingFaults} '
    'activas=${active.map((f) => f.id).toList()}',
  );
  debugPrint('PROBE ver backend ${await _stats()}');
}

/// El servicio real. Entre las dos fases hay 25 s para mirar `dumpsys`.
Future<void> _service() async {
  await _realSpp();
  final controller = getIt<ObdForegroundController>();
  await controller.start();
  debugPrint('PROBE servicio arrancado');
  await Future<void>.delayed(const Duration(seconds: 25));
  await controller.stop();
  debugPrint('PROBE servicio detenido');
}
