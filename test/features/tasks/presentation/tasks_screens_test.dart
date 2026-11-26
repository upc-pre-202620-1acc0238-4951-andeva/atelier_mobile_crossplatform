import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/hold_reason.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_detail.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/components/chronometer_timer.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_actions.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_screen.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/detail/task_detail_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_screen.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/presentation/mytasks/my_tasks_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:decimal/decimal.dart';
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

/// Quita del árbol las animaciones infinitas (balizas, huesos, cronómetro) antes de cerrar la prueba.
Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

Task _task(
  String id, {
  String? plate = 'BKL482',
  TaskStatus status = TaskStatus.assigned,
  HoldReason? hold,
  String? pendingSuspension,
  String? serviceName,
}) {
  return Task(
    id: TaskId(id),
    workOrderId: 'wo1',
    workOrderNumber: 1042,
    vehicleId: 'v1',
    plate: plate,
    bayName: 'B-2',
    serviceName: serviceName,
    status: status,
    description: 'Cambio de pastillas de freno delanteras',
    estimatedHours: Decimal.parse('1.5'),
    holdReason: hold,
    pendingSuspensionReason: pendingSuspension,
    totalPausedSeconds: 0,
  );
}

MyTasksContent _myTasks(MyTasksUiState state, {void Function(Task)? onOpen, ValueChanged<TaskFilter>? onFilter}) {
  return MyTasksContent(
    state: state,
    onBack: null,
    onRefresh: () async {},
    onFilterChange: onFilter ?? (_) {},
    onOpenTask: onOpen ?? (_) {},
  );
}

TaskDetail _detail({
  TaskStatus status = TaskStatus.inProgress,
  HoldReason? hold,
  List<TaskProduct> products = const [],
}) {
  return TaskDetail(
    id: TaskId('t1'),
    workOrderId: 'wo1',
    serviceName: 'Cambio de pastillas y rectificado',
    mechanicName: 'Andrés Vílchez',
    status: status,
    description: 'Cambio de pastillas delanteras y purga de líquido.',
    holdReason: hold,
    totalPausedSeconds: 300,
    startedAt: DateTime.now().subtract(const Duration(seconds: 3725)),
    products: products,
  );
}

void main() {
  setUpAll(_loadSatoshi);

  group('MyTasksContent', () {
    testWidgets('cargado: panel, filtros, filas con estado y tarea sin placa', (tester) async {
      Task? opened;
      await _pump(
        tester,
        _myTasks(
          MyTasksUiState(
            isLoaded: true,
            tenantName: 'Taller Suárez · Chorrillos',
            tasks: [
              _task('t1', status: TaskStatus.inProgress),
              _task('t2', status: TaskStatus.onHold, hold: HoldReason.breakTime),
              _task('t3', plate: null),
              _task('t4', status: TaskStatus.onHold, hold: HoldReason.waitingParts, pendingSuspension: 'Falta retén'),
            ],
          ),
          onOpen: (task) => opened = task,
        ),
      );

      expect(find.text('Mis tareas'), findsOneWidget);
      expect(find.text('Taller Suárez · Chorrillos'), findsOneWidget);
      expect(find.text('4 tareas'), findsOneWidget);
      expect(find.text('asignadas en tu turno'), findsOneWidget);
      expect(find.text('Suspendidas'), findsOneWidget);
      expect(find.text('Bahía B-2 · OT #1042 · 1.5 h estimadas'), findsWidgets);
      expect(find.text('En curso'), findsWidgets);
      expect(find.text('En pausa'), findsWidgets);
      expect(find.text('Suspensión por aprobar'), findsOneWidget);
      expect(find.text('Sin placa'), findsOneWidget);

      await tester.tap(find.text('Suspensión por aprobar'));
      expect(opened?.id.value, 't4');
      await _teardown(tester);
    });

    testWidgets('alcance de taller cambia el título y el pie del panel', (tester) async {
      await _pump(
        tester,
        _myTasks(MyTasksUiState(isLoaded: true, isWorkshopScope: true, tasks: [_task('t1')])),
      );
      expect(find.text('Tareas del taller'), findsOneWidget);
      expect(find.text('activas en la sede'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('vacío: texto y acción para actualizar', (tester) async {
      await _pump(tester, _myTasks(const MyTasksUiState(isLoaded: true, tenantName: 'Taller')));
      expect(find.text('No tienes tareas asignadas.'), findsOneWidget);
      expect(find.text('Actualizar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('filtro sin coincidencias ofrece quitar filtros', (tester) async {
      TaskFilter? chosen;
      await _pump(
        tester,
        _myTasks(
          MyTasksUiState(isLoaded: true, tasks: [_task('t1')], selectedFilter: TaskFilter.inProgress),
          onFilter: (f) => chosen = f,
        ),
      );
      expect(find.text('Ninguna tarea coincide con este filtro.'), findsOneWidget);
      await tester.tap(find.text('Quitar filtros'));
      expect(chosen, TaskFilter.all);
      await _teardown(tester);
    });

    testWidgets('error sin caché con red: mensaje y reintento', (tester) async {
      await _pump(
        tester,
        _myTasks(
          const MyTasksUiState(isLoaded: true, error: UiText.dynamic('Servidor caído'), showingCache: true),
        ),
      );
      expect(find.text('Servidor caído'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('con caché y sin red avisa y conserva las filas', (tester) async {
      await _pump(
        tester,
        _myTasks(
          MyTasksUiState(isLoaded: true, tasks: [_task('t1')], showingCache: true, isOnline: false),
        ),
      );
      expect(find.text('Sin conexión: mostrando las tareas guardadas.'), findsOneWidget);
      expect(find.text('Cambio de pastillas de freno delanteras'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('sin permiso de lectura solo muestra el aviso', (tester) async {
      await _pump(tester, _myTasks(const MyTasksUiState(isLoaded: true, canRead: false)));
      expect(find.text('Tu perfil no tiene permiso para ver tareas.'), findsOneWidget);
      expect(find.text('Asignadas'), findsNothing);
      await _teardown(tester);
    });
  });

  group('TaskDetailContent', () {
    TaskDetailContent content(TaskDetailUiState state, {TaskDetailActions? actions}) =>
        TaskDetailContent(state: state, actions: actions ?? const TaskDetailActions());

    testWidgets('en curso: ficha, cronómetro, dock con Pausar, accesos y repuestos; sin controles excluidos', (
      tester,
    ) async {
      var paused = false;
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.inProgress, serviceName: 'Cambio de pastillas y rectificado'),
            detail: _detail(
              products: [
                TaskProduct(id: 'tp1', productId: 'p1', productName: 'Juego de pastillas Bosch', quantity: Decimal.one),
              ],
            ),
            isLoading: false,
            canTrackTime: true,
            canChargeParts: true,
            canEditParts: true,
            canReportFinding: true,
            canOpenObd: true,
          ),
          actions: TaskDetailActions(onPauseClick: () => paused = true, onReportFinding: (_) {}),
        ),
      );

      expect(find.text('Cambio de pastillas y rectificado'), findsOneWidget);
      expect(find.text('Bahía B-2 · OT #1042 · Mecánico: Andrés Vílchez'), findsOneWidget);
      expect(find.text('Detalle técnico'), findsOneWidget);
      expect(find.text('En pausa acumulada: 00:05:00'), findsOneWidget);
      expect(find.text('Accesos rápidos'), findsOneWidget);
      expect(find.text('Escáner OBD-II'), findsOneWidget);
      expect(find.text('Reportar hallazgo'), findsOneWidget);
      expect(find.text('Repuestos de la tarea · 1'), findsOneWidget);
      expect(find.text('Juego de pastillas Bosch'), findsOneWidget);
      expect(find.text('Corregir cantidad'), findsOneWidget);
      expect(find.text('Imputar repuesto'), findsOneWidget);
      expect(find.text('Pausar'), findsOneWidget);
      // Sin sus permisos no hay cierre (US30), suspensión (US29) ni captura (US28).
      expect(find.text('Terminar tarea'), findsNothing);
      expect(find.text('Solicitar suspensión'), findsNothing);
      expect(find.text('Control de labor'), findsNothing);
      expect(find.text('Evidencias fotográficas'), findsNothing);
      expect(find.text('Tomar foto'), findsNothing);

      await tester.tap(find.text('Pausar'));
      expect(paused, isTrue);
      await _teardown(tester);
    });

    testWidgets('US28–US30 con permisos: cerrar, solicitar suspensión y tomar foto sin red', (tester) async {
      final tapped = <String>[];
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.inProgress),
            detail: _detail(),
            isLoading: false,
            canCompleteTask: true,
            canRequestSuspensionPermission: true,
            canUploadPhotos: true,
          ),
          actions: TaskDetailActions(
            onCompleteClick: () => tapped.add('complete'),
            onRequestSuspensionClick: () => tapped.add('suspend'),
            onAddEvidenceClick: () => tapped.add('photo'),
          ),
        ),
      );
      await tester.tap(find.text('Terminar tarea'));
      await tester.tap(find.text('Solicitar suspensión'));
      await tester.tap(find.text('Tomar foto'));
      expect(tapped, ['complete', 'suspend', 'photo']);
      await _teardown(tester);
    });

    testWidgets('US29: el supervisor revisa la solicitud pendiente y reanuda la suspendida', (tester) async {
      var reviewed = false;
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.inProgress, pendingSuspension: 'Falta retén'),
            isLoading: false,
            canValidateSuspension: true,
          ),
          actions: TaskDetailActions(onReviewSuspensionClick: () => reviewed = true),
        ),
      );
      await tester.tap(find.text('Suspensión por validar'));
      expect(reviewed, isTrue);
      await _teardown(tester);

      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.onHold, hold: HoldReason.waitingParts),
            isLoading: false,
            canValidateSuspension: true,
          ),
        ),
      );
      expect(find.text('Suspensión activa por repuesto'), findsOneWidget);
      expect(find.text('Tarea suspendida: solo un supervisor puede levantarla.'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('asignada: ofrece Iniciar faena y sin conexión lo deshabilita con el motivo', (tester) async {
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1'),
            detail: _detail(status: TaskStatus.assigned),
            isLoading: false,
            isOnline: false,
            canTrackTime: true,
          ),
        ),
      );
      expect(find.text('Iniciar faena'), findsOneWidget);
      expect(find.text('Pausar'), findsNothing);
      expect(find.text('Imputar repuesto'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('pausa del mecánico muestra Reanudar y el tiempo desconocido sin valor guardado', (tester) async {
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.onHold, hold: HoldReason.breakTime),
            detail: _detail(status: TaskStatus.onHold, hold: HoldReason.breakTime),
            isLoading: false,
            canTrackTime: true,
          ),
        ),
      );
      expect(find.text('Reanudar'), findsOneWidget);
      expect(find.text('--:--:--'), findsOneWidget);
      expect(find.text('El tiempo al pausar no está disponible en este teléfono.'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('suspendida: avisa que solo un supervisor la levanta, sin acciones de revisión', (tester) async {
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.onHold, hold: HoldReason.waitingParts),
            detail: _detail(status: TaskStatus.onHold, hold: HoldReason.waitingParts),
            isLoading: false,
            canTrackTime: true,
          ),
        ),
      );
      expect(find.text('Tarea suspendida: solo un supervisor puede levantarla.'), findsOneWidget);
      expect(find.text('Levantar suspensión'), findsNothing);
      expect(find.text('Esperan tu decisión'), findsNothing);
      expect(find.text('Reanudar'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('completada con permiso de supervisión: Reabrir tarea', (tester) async {
      var reopened = false;
      await _pump(
        tester,
        content(
          TaskDetailUiState(
            task: _task('t1', status: TaskStatus.completed),
            detail: _detail(status: TaskStatus.completed),
            isLoading: false,
            canReopenTask: true,
            canEditParts: true,
          ),
          actions: TaskDetailActions(onReopenClick: () => reopened = true),
        ),
      );
      expect(find.text('Control de labor'), findsOneWidget);
      await tester.tap(find.text('Reabrir tarea'));
      expect(reopened, isTrue);
      await _teardown(tester);
    });

    testWidgets('sin permisos de acción avisa que el perfil no puede operar', (tester) async {
      await _pump(
        tester,
        content(TaskDetailUiState(task: _task('t1'), detail: _detail(), isLoading: false)),
      );
      expect(find.text('Tu perfil no tiene permiso para esta acción.'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('sin detalle en línea los repuestos se consultan con conexión y se puede reintentar', (tester) async {
      await _pump(
        tester,
        content(TaskDetailUiState(task: _task('t1'), isLoading: false, canChargeParts: true)),
      );
      expect(find.text('Los repuestos imputados se consultan con conexión.'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('error sin datos: mensaje con reintento y sin secciones', (tester) async {
      await _pump(
        tester,
        content(const TaskDetailUiState(isLoading: false, error: UiText.dynamic('No existe la tarea'))),
      );
      expect(find.text('No existe la tarea'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Detalle técnico'), findsNothing);
      await _teardown(tester);
    });
  });

  group('cronómetro', () {
    final startedAt = DateTime.utc(2026, 11, 24, 10);

    test('formatea horas sin tope y nunca negativo', () {
      expect(formatElapsed(3725), '01:02:05');
      expect(formatElapsed(360000), '100:00:00');
      expect(formatElapsed(-5), '00:00:00');
    });

    test('en marcha cuenta desde startedAt menos lo pausado', () {
      final display = timerDisplay(
        startedAt: startedAt,
        totalPausedSeconds: 300,
        running: true,
        paused: false,
        pausedElapsedSeconds: null,
        now: startedAt.add(const Duration(seconds: 3725)),
      );
      expect(display.text, '00:57:05');
      expect(display.unknown, isFalse);
    });

    test('en pausa muestra lo guardado o declara que se desconoce', () {
      final known = timerDisplay(
        startedAt: startedAt,
        totalPausedSeconds: 0,
        running: false,
        paused: true,
        pausedElapsedSeconds: 2400,
        now: startedAt,
      );
      expect(known.text, '00:40:00');
      final unknown = timerDisplay(
        startedAt: startedAt,
        totalPausedSeconds: 0,
        running: false,
        paused: true,
        pausedElapsedSeconds: null,
        now: startedAt,
      );
      expect(unknown.text, unknownElapsed);
      expect(unknown.unknown, isTrue);
    });

    testWidgets('avanza cada segundo mientras corre', (tester) async {
      var now = startedAt.add(const Duration(seconds: 10));
      await _pump(
        tester,
        Scaffold(
          body: ChronometerTimer(
            startedAt: startedAt,
            totalPausedSeconds: 0,
            running: true,
            paused: false,
            pausedElapsedSeconds: null,
            status: TaskStatus.inProgress,
            nowProvider: () => now,
          ),
        ),
      );
      expect(find.text('00:00:10'), findsOneWidget);
      now = startedAt.add(const Duration(seconds: 11));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('00:00:11'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
