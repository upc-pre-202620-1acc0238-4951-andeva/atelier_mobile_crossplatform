import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

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
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/add_part_to_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/approve_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/attach_task_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/complete_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/get_task_detail_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/observe_pending_evidence_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/pause_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/refresh_my_tasks_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/reject_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/remove_part_from_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/request_suspension_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/resume_suspended_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/search_parts_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/start_task_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/suggest_labor_hours_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/application/update_task_part_quantity_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/evidence_kind.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/pause_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart' hide TaskStatus;

const _t1 = TaskId('t1');
const _t2 = TaskId('t2');

/// Prueba del paso 5 con worker y compresión reales, contra `tool/sync_mock_server.dart`. No se publica.
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

  getIt<ObservePendingEvidenceUseCase>().execute(_t2).listen((rows) {
    for (final row in rows) {
      final path = row.localFilePath;
      debugPrint(
        'PROBE foto ${row.status} archivo=${path != null && File(path).existsSync()} '
        'descripcion=${row.description}',
      );
    }
    debugPrint('PROBE fotos pendientes=${rows.length}');
  });
  getIt<PendingOperationDao>().watchForUser('probe-user').listen((rows) {
    for (final row in rows) {
      debugPrint(
        'PROBE cola ${row.type} ${row.status} depende=${row.dependsOn != null} '
        'intentos=${row.attempts} error=${row.lastErrorMessage}',
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
              _button('En linea', _online),
              _button('Sin red', _offline),
              _button('Foto', _photo),
              _button('Ver', _show),
            ],
          ),
        ),
      ),
    ),
  );
}

void _check(String name, bool passed, [Object? detail]) {
  debugPrint('PROBE ${passed ? 'OK' : 'FALLA'} $name ${detail ?? ''}');
}

Future<List<Task>> _myTasks() => getIt<ObserveMyTasksUseCase>().execute().first;

Future<void> _expectApiError(String name, int status, Future<void> Function() call) async {
  try {
    await call();
    _check(name, false, 'no falló');
  } on ApiException catch (e) {
    _check(name, e.httpStatus == status, '${e.httpStatus} "${e.message}"');
  }
}

Future<void> _online() async {
  await getIt<RefreshMyTasksUseCase>().execute();
  var mine = await _myTasks();
  _check(
    'orden en curso, pausa, resto',
    mine.map((t) => t.id.value).join(',') == 't2,t3,t1',
    mine.map((t) => '${t.id.value}:${t.status?.value}').join(' '),
  );
  _check(
    'placa y bahia',
    mine.first.plate == 'ABC-123' && mine.first.bayName == 'Bahía 1',
    '${mine.first.plate} ${mine.first.bayName}',
  );
  _check('horas decimales', mine.first.estimatedHours == Decimal.parse('1.5'));

  final start = getIt<StartTaskUseCase>();
  final pause = getIt<PauseTaskUseCase>();
  var detail = await start.execute(_t1);
  _check('iniciar', detail.status == TaskStatus.inProgress, detail.startedAt);
  _check('precio con moneda', detail.price?.amount == Decimal.parse('120.5'));
  detail = await pause.execute(_t1, PauseReason.breakTime);
  _check('pausar', detail.isPausedByMechanic);
  detail = await start.execute(_t1);
  _check('reanudar', detail.status == TaskStatus.inProgress, 'pausa=${detail.totalPausedSeconds}s');
  await _expectApiError('fin de turno anticipado', 422, () async {
    await pause.execute(_t1, PauseReason.endOfShift);
  });
  mine = await _myTasks();
  _check(
    'sigue en curso tras el rechazo',
    mine.firstWhere((t) => t.id == _t1).status == TaskStatus.inProgress,
  );

  final request = getIt<RequestSuspensionUseCase>();
  detail = await request.execute(_t1, '  Bomba de agua  ');
  _check(
    'solicitar suspension recortada',
    detail.pendingSuspensionReason == 'Bomba de agua',
    detail.pendingSuspensionReason,
  );
  mine = await _myTasks();
  _check('pendiente en cache', mine.firstWhere((t) => t.id == _t1).hasPendingSuspension);
  detail = await getIt<RejectSuspensionUseCase>().execute(_t1);
  _check('rechazar', !detail.hasPendingSuspension && detail.status == TaskStatus.inProgress);
  await request.execute(_t1, 'Bomba de agua');
  detail = await getIt<ApproveSuspensionUseCase>().execute(_t1);
  _check('aprobar', detail.isSuspended);
  await _expectApiError('el mecanico no levanta la suspension', 422, () async {
    await start.execute(_t1);
  });
  detail = await getIt<ResumeSuspendedTaskUseCase>().execute(_t1);
  _check('levantar', detail.status == TaskStatus.inProgress);

  final parts = await getIt<SearchPartsUseCase>().execute(' filtro ');
  _check(
    'buscar con nombre nulo y sin saldo',
    parts.length == 2 && parts[0].isAvailable && !parts[1].isAvailable && parts[1].name.isEmpty,
    'base=${parts[0].basePrice}',
  );
  final line = await getIt<AddPartToTaskUseCase>().execute(_t1, 'p1', Decimal.parse('1.5'));
  _check('imputar', line.quantity == Decimal.parse('1.5'), line.unitPrice?.amount);
  await _expectApiError('stock insuficiente', 409, () async {
    await getIt<AddPartToTaskUseCase>().execute(_t1, 'p1', Decimal.fromInt(999));
  });
  detail = await getIt<UpdateTaskPartQuantityUseCase>().execute(_t1, 'p1', Decimal.fromInt(3));
  _check(
    'corregir cantidad ignora el PUT (H9) y no cambia (H38)',
    detail.products.single.quantity == Decimal.parse('1.5'),
    detail.products.single.productName,
  );
  await getIt<RemovePartFromTaskUseCase>().execute(_t1, 'p1');
  detail = await getIt<GetTaskDetailUseCase>().execute(_t1);
  _check('devolver deja la linea visible (H37)', detail.products.length == 1);

  mine = await _myTasks();
  final hours = getIt<SuggestLaborHoursUseCase>().execute(
    mine.firstWhere((t) => t.id == _t1),
  );
  _check('horas sugeridas', hours != null, hours);
  detail = await getIt<CompleteTaskUseCase>().execute(_t1, Decimal.parse('1.25'), notes: '  Listo  ');
  _check('cerrar', detail.status == TaskStatus.completed);
  mine = await _myTasks();
  _check('sale de la lista', mine.every((t) => t.id != _t1), mine.map((t) => t.id.value).join(','));
  debugPrint('PROBE en linea terminado');
}

Future<void> _offline() async {
  final before = (await _myTasks()).length;
  try {
    await getIt<RefreshMyTasksUseCase>().execute();
    _check('refresh sin red', false, 'no falló');
  } on NetworkException {
    _check('refresh sin red', true);
  }
  _check('cache visible sin red', (await _myTasks()).length == before, before);
  final queue = getIt<PendingOperationDao>().watchForUser('probe-user');
  final queued = (await queue.first).length;
  try {
    await getIt<PauseTaskUseCase>().execute(_t2, PauseReason.breakTime);
    _check('accion sin red', false, 'no falló');
  } on NetworkException {
    _check('accion sin red', true);
  }
  _check('no se encola', (await queue.first).length == queued);
  debugPrint('PROBE sin red terminado');
}

/// Imagen real generada aquí: pasa por la misma compresión y subida que una de la cámara.
Future<File> _generatedPhoto() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 2400, 1200),
    ui.Paint()..color = const ui.Color(0xFF336699),
  );
  final image = await recorder.endRecording().toImage(2400, 1200);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/probe_${DateTime.now().millisecondsSinceEpoch}.png');
  return file.writeAsBytes(png!.buffer.asUint8List());
}

Future<void> _photo() async {
  final photo = await _generatedPhoto();
  await getIt<AttachTaskEvidenceUseCase>().execute(
    _t2,
    'wo2',
    photo,
    EvidenceKind.disassembly,
    note: 'Filtro usado',
  );
  debugPrint('PROBE foto capturada');
}

Future<void> _show() async {
  final detail = await getIt<GetTaskDetailUseCase>().execute(_t2);
  debugPrint('PROBE evidencias en el backend=${detail.evidenceImages.length}');
  for (final image in detail.evidenceImages) {
    debugPrint('PROBE evidencia ${image.description} ${image.imageUrl}');
  }
}

Widget _button(String label, Future<void> Function() onTap) {
  return Expanded(
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          try {
            await onTap();
          } on Object catch (e) {
            debugPrint('PROBE FALLA excepcion en "$label": ${e.runtimeType} $e');
          }
        },
        child: Text(label),
      ),
    ),
  );
}
