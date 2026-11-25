import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/work_shift.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_screen.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_screen.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/dashboard/floor_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_id.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
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

/// Quita del árbol las animaciones infinitas (balizas, huesos) antes de cerrar la prueba.
Future<void> _teardown(WidgetTester tester) => tester.pumpWidget(const SizedBox());

const _branch = Branch(
  id: 'b1',
  name: 'Sede Chorrillos',
  latitude: -12.17,
  longitude: -77.01,
  geofenceRadiusMeters: 100,
  isActive: true,
);

const _schedule = WeeklySchedule(
  branchId: 'b1',
  shiftId: 's1',
  shift: WorkShift(
    id: 's1',
    name: 'Turno Mañana',
    startTime: '08:00:00',
    endTime: '17:00:00',
    gracePeriodMinutes: 10,
    workDays: {},
    restDays: {WeekDay.sunday},
    isActive: true,
  ),
  branch: _branch,
);

Session _session(Set<String> permissions) {
  return Session(
    userId: 'u1',
    email: 'andres@tallersuarez.pe',
    fullName: 'Andrés Vílchez',
    tenantId: 't1',
    tenantName: 'Taller Suárez',
    membershipId: 'm1',
    permissions: permissions,
    plan: null,
    branchId: 'b1',
    shiftId: 's1',
  );
}

Attendance _attendance({AttendanceStatus? status = AttendanceStatus.late}) {
  return Attendance(
    id: AttendanceId('a1'),
    branchId: 'b1',
    shiftId: 's1',
    clockIn: DateTime.utc(2026, 11, 16, 13, 18),
    clockOut: DateTime.utc(2026, 11, 16, 22, 5),
    status: status,
    distanceToBranchMeters: 18,
    workedMinutes: 527,
    regularMinutes: 480,
    overtimeMinutes: 47,
    justificationReason: null,
    justificationStatus: null,
    syncedAt: DateTime.utc(2026, 11, 16, 22, 6),
  );
}

AttendanceContent _attendanceContent(AttendanceUiState state, {void Function(Attendance)? onJustify}) {
  return AttendanceContent(
    state: state,
    onBack: () {},
    onRefresh: () async {},
    onLocate: () {},
    onClockIn: () {},
    onRequestClockOut: () {},
    onRequestJustification: onJustify ?? (_) {},
  );
}

void main() {
  setUpAll(_loadSatoshi);

  group('AttendanceContent', () {
    final session = _session({
      'hr:attendance:clock_in',
      'hr:attendance:clock_out',
      'hr:justifications:create',
    });

    testWidgets('cargado: turno, geocerca, semana e historial con descargo', (tester) async {
      final justified = <Attendance>[];
      await _pump(
        tester,
        _attendanceContent(
          AttendanceUiState(
            session: session,
            schedule: _schedule,
            history: [_attendance()],
            isRefreshing: false,
            deviceLocation: const DeviceLocation(
              latitude: -12.1701,
              longitude: -77.0101,
              accuracyMeters: 12,
              isMock: false,
            ),
          ),
          onJustify: justified.add,
        ),
      );

      expect(find.text('Asistencia'), findsOneWidget);
      expect(find.text('Sede Chorrillos'), findsOneWidget);
      expect(find.text('Turno Mañana · 08:00 – 17:00'), findsOneWidget);
      expect(find.text('Sin marcar'), findsOneWidget);
      expect(find.textContaining('Dentro de geocerca'), findsOneWidget);
      expect(find.text('Marcar ingreso'), findsOneWidget);
      expect(find.text('Tolerancia de ingreso: 10 min'), findsOneWidget);
      expect(find.text('Domingo'), findsOneWidget);
      expect(find.text('Descanso'), findsOneWidget);
      expect(find.text('Historial de los últimos 30 días · 1'), findsOneWidget);
      expect(find.text('Salida 17:05 · 8h 47m trabajados · +47m extra'), findsOneWidget);
      expect(find.text('Tardanza'), findsOneWidget);

      await tester.tap(find.text('Enviar descargo'));
      expect(justified, hasLength(1));
      await _teardown(tester);
    });

    testWidgets('vacío: sin sede ni historial', (tester) async {
      await _pump(
        tester,
        _attendanceContent(AttendanceUiState(session: session, isRefreshing: false)),
      );

      expect(
        find.text('Aún no tienes sede ni turno asignados. Pide al administrador que configure tu perfil laboral.'),
        findsOneWidget,
      );
      expect(find.text('Sin lectura GPS todavía'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('error y aviso de ubicación: banners y sin marcar si ya hay jornada', (tester) async {
      await _pump(
        tester,
        _attendanceContent(
          AttendanceUiState(
            session: session,
            schedule: _schedule,
            isRefreshing: false,
            today: ClockedIn(_attendance(status: AttendanceStatus.onTime)),
            error: const UiText.dynamic('Sin red'),
            locationWarning: const UiText.dynamic('Estás fuera'),
          ),
        ),
      );

      expect(find.text('Sin red'), findsOneWidget);
      expect(find.text('Estás fuera'), findsOneWidget);
      expect(find.text('En turno'), findsOneWidget);
      expect(find.text('Marcar ingreso'), findsNothing);
      expect(find.text('Marcar salida'), findsOneWidget);
      await _teardown(tester);
    });

    test('canClockIn y canClockOut siguen la jornada', () {
      final idle = AttendanceUiState(session: _session({}));
      expect(idle.canClockIn, isTrue);
      expect(idle.canClockOut, isFalse);
      expect(idle.copyWith(isSubmitting: true).canClockIn, isFalse);
      final queued = idle.copyWith(today: ClockInQueued(DateTime.utc(2026)));
      expect(queued.canClockIn, isFalse);
      expect(queued.canClockOut, isTrue);
    });
  });

  group('FloorHubContent', () {
    FloorHubContent hub(FloorHubUiState state) =>
        FloorHubContent(state: state, actions: FloorHubActions());

    Task task(String id, TaskStatus status) {
      return Task(
        id: TaskId(id),
        workOrderId: 'wo1',
        vehicleId: 'v1',
        plate: 'BKL482',
        bayName: 'Bahía 2',
        status: status,
        description: 'Cambio de pastillas',
        estimatedHours: Decimal.parse('2.0'),
        startedAt: DateTime.now().subtract(const Duration(minutes: 70)),
        totalPausedSeconds: 0,
      );
    }

    testWidgets('mecánico: tarea en curso, cola y accesos (incluye bahías), sin alertas de stock', (
      tester,
    ) async {
      await _pump(
        tester,
        hub(
          FloorHubUiState(
            todayDate: '2026-11-22',
            hasLoaded: true,
            session: _session({
              'hr:attendance:clock_in',
              'hr:attendance:clock_out',
              'operations:tasks:read',
              'operations:tasks:track_time',
              'operations:proposals:create',
              'operations:bays:read',
              'inventory:parts:read',
              'inventory:alerts:read',
              'iot:devices:read',
            }),
            schedule: _schedule,
            assignedTasks: [task('t1', TaskStatus.inProgress), task('t2', TaskStatus.pending)],
            activeObdCount: 2,
          ),
        ),
      );

      expect(find.text('Taller Suárez'), findsOneWidget);
      expect(find.text('Tarea en curso'), findsOneWidget);
      expect(find.text('Abrir tarea'), findsOneWidget);
      expect(find.text('Mis tareas de hoy · 2'), findsOneWidget);
      expect(find.text('Avance estimado'), findsOneWidget);
      expect(find.text('Diagnóstico OBD-II'), findsOneWidget);
      expect(find.text('Reportar hallazgo'), findsOneWidget);
      expect(find.text('Consultar repuestos'), findsOneWidget);
      expect(find.text('Tablero de bahías'), findsOneWidget);
      // Fuera de esta versión: alertas de stock (US34) y telemetría en vivo (US18).
      expect(find.text('Requieren reposición'), findsNothing);
      expect(find.textContaining('Telemetría en vivo'), findsNothing);
      await _teardown(tester);
    });

    testWidgets('vacío: sin tareas asignadas', (tester) async {
      await _pump(
        tester,
        hub(
          FloorHubUiState(
            hasLoaded: true,
            session: _session({'operations:tasks:read', 'operations:tasks:track_time'}),
          ),
        ),
      );

      expect(find.text('No tienes tareas asignadas por ahora.'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('error: el aviso del ViewModel se ve sobre el contenido', (tester) async {
      await _pump(
        tester,
        hub(
          FloorHubUiState(
            hasLoaded: true,
            session: _session({'hr:attendance:clock_in'}),
            schedule: _schedule,
            error: const UiText.dynamic('No tienes permiso para marcar'),
          ),
        ),
      );

      expect(find.text('No tienes permiso para marcar'), findsOneWidget);
      expect(find.text('Marcar ingreso'), findsOneWidget);
      expect(find.text('Ver turno y descargos'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('mostrador y caja: agenda y cobros sin acceso al cobro de órdenes', (tester) async {
      await _pump(
        tester,
        hub(
          FloorHubUiState(
            hasLoaded: true,
            session: _session({'crm:appointments:read', 'invoicing:payments:create'}),
            appointments: [
              Appointment(
                id: 'ap1',
                branchId: 'b1',
                customerId: 'c1',
                vehicleId: 'v1',
                scheduledAt: DateTime.utc(2026, 11, 22, 14, 30),
                reason: 'Mantenimiento',
                status: AppointmentStatus.confirmed,
                plate: 'F4T119',
                customerName: 'Luis Paredes',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Agenda de hoy · 1'), findsOneWidget);
      expect(find.text('09:30 · Luis Paredes'), findsOneWidget);
      expect(find.text('Confirmada'), findsOneWidget);
      expect(find.text('Ver caja del día'), findsOneWidget);
      expect(find.text('No hay órdenes terminadas esperando cobro.'), findsOneWidget);
      await _teardown(tester);
    });
  });
}
