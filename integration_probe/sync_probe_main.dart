import 'dart:async';
import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/authenticated_user_dto.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_worker.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

/// Prueba del paso 1 con la UI y el worker en motores reales (docs/06-offline-sync.md §8.11).
/// No se publica: se ejecuta con `-t` contra `tool/sync_mock_server.dart`.
const _probe = 'PROBE';

class _ProbeHandler implements OperationHandler {
  final String engine;

  const _ProbeHandler(this.engine);

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    debugPrint('PROBE $engine envía ${operation.id}');
    return OperationResult.from(
      () => getIt<ApiClient>().post(
        '/api/v1/probe',
        body: {'id': operation.id, 'engine': engine},
      ),
    );
  }
}

@pragma('vm:entry-point')
void probeDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('PROBE worker arranca $task');
    setupDependencies();
    getIt<OperationHandlerRegistry>().register(
      _probe,
      () => const _ProbeHandler('worker'),
    );
    final ok = await runSyncTask();
    debugPrint('PROBE worker termina ok=$ok');
    return ok;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  getIt<OperationHandlerRegistry>().register(
    _probe,
    () => const _ProbeHandler('ui'),
  );
  final session = getIt<SessionManager>();
  debugPrint('PROBE etapa 1 reinstalación');
  await session.clearIfReinstalled();
  debugPrint('PROBE etapa 2 base');
  final database = getIt<AppDatabase>();
  await database.customSelect('SELECT 1').get();
  debugPrint('PROBE etapa 3 workmanager');
  await Workmanager().initialize(probeDispatcher);
  debugPrint('PROBE etapa 4 sesión');
  LocalChangeNotifier.listenInUi(database, session);

  if (await session.getSession() == null) {
    final seed = await http.get(_control('/control/session'));
    await session.save(
      AuthenticatedUserDto.fromJson(jsonDecode(utf8.decode(seed.bodyBytes))),
    );
    debugPrint('PROBE ui sesión sembrada');
  }

  getIt<PendingOperationDao>().watchPendingCount('probe-user').listen((count) {
    debugPrint('PROBE ui ve pendientes=$count');
  });
  session.addListener(() => unawaited(_printSession('aviso')));
  await _printSession('arranque');

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _button('Encolar: worker en 20 s', () => _enqueueForWorker(20)),
              _button('Vencer token y encolar: worker en 20 s', () async {
                await http.post(_control('/control/expire'));
                await _enqueueForWorker(20);
              }),
              _button('Leer sesión', () => _printSession('botón')),
              _button('Refresh simultáneo UI + worker', _simultaneousRefresh),
            ],
          ),
        ),
      ),
    ),
  );
}

Uri _control(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

Widget _button(String label, Future<void> Function() onTap) {
  return Expanded(
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(onPressed: onTap, child: Text(label)),
    ),
  );
}

Future<void> _printSession(String reason) async {
  final session = getIt<SessionManager>();
  final current = await session.getSession();
  debugPrint(
    'PROBE ui sesión ($reason): usuario=${current?.userId} '
    'refresh=${await session.getRefreshToken()} '
    'nombre=${current?.fullName}',
  );
}

/// Solo a la base y al worker, sin `SyncProcessor` en la UI: así lo envía el otro motor.
Future<String> _insert() async {
  final id = const Uuid().v4();
  final now = DateTime.now().millisecondsSinceEpoch;
  await getIt<PendingOperationDao>().enqueue(
    PendingOperationsCompanion.insert(
      id: id,
      type: _probe,
      payload: '{}',
      dedupeKey: id,
      userId: 'probe-user',
      tenantId: 'probe-tenant',
      nextAttemptAt: now,
      createdAt: now,
    ),
  );
  debugPrint('PROBE ui encoló $id');
  return id;
}

Future<void> _enqueueForWorker(int seconds) async {
  await _insert();
  final at = DateTime.now().add(Duration(seconds: seconds));
  await getIt<SyncScheduler>().requestSyncAt(at.millisecondsSinceEpoch);
  debugPrint('PROBE ui worker programado para $at');
}

/// El refresh del servidor tarda 8 s: las peticiones de la UI y del worker se solapan seguro.
Future<void> _simultaneousRefresh() async {
  await http.post(_control('/control/expire?refreshDelayMs=8000'));
  await _insert();
  await getIt<SyncScheduler>().requestSync();
  for (var i = 0; i < 6; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    unawaited(
      getIt<ApiClient>()
          .post('/api/v1/probe', body: {'id': 'directa-$i', 'engine': 'ui'})
          .then(
            (_) => debugPrint('PROBE ui petición $i ok'),
            onError: (Object e) => debugPrint('PROBE ui petición $i error: $e'),
          ),
    );
  }
}
