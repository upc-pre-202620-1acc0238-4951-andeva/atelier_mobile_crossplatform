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
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

/// Prueba del paso 4 con GPS y worker reales, contra `tool/sync_mock_server.dart`. No se publica.
/// `setupDependencies` registra los handlers: el worker no necesita nada más.
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

  getIt<ObserveTodayAttendanceUseCase>().execute().listen((state) {
    debugPrint('PROBE hoy=${state.runtimeType}');
  });
  getIt<PendingOperationDao>().watchForUser('probe-user').listen((rows) {
    for (final row in rows) {
      debugPrint(
        'PROBE cola ${row.type} ${row.status} clave=${row.dedupeKey} '
        'depende=${row.dependsOn != null} intentos=${row.attempts}',
      );
    }
    debugPrint('PROBE cola total=${rows.length}');
  });

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('Actualizar', () async {
                await getIt<RefreshAttendanceUseCase>().execute();
                final current = await session.getSession();
                debugPrint(
                  'PROBE actualizado sede=${current?.branchId} turno=${current?.shiftId}',
                );
              }),
              _button('Marcar ingreso', () async {
                final current = await session.getSession();
                final result = await getIt<ClockInUseCase>().execute(
                  current?.branchId,
                  current?.shiftId,
                );
                debugPrint(
                  'PROBE ingreso=${result.outcome.runtimeType} '
                  'distancia=${result.geofence?.distanceMeters.round()} '
                  'dentro=${result.geofence?.isInside} '
                  'simulada=${result.isMockLocation}',
                );
              }),
              _button('Marcar salida', () async {
                final outcome = await getIt<ClockOutUseCase>().execute();
                debugPrint('PROBE salida=${outcome.runtimeType}');
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _button(String label, Future<void> Function() onTap) {
  return Expanded(
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          try {
            await onTap();
          } on Exception catch (e) {
            debugPrint('PROBE error en "$label": ${e.runtimeType} $e');
          }
        },
        child: Text(label),
      ),
    ),
  );
}
