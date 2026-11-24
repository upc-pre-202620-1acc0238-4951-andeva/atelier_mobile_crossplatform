import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/get_current_location_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/is_location_permission_granted_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_attendance_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_weekly_schedule_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/submit_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/work_shift.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockObserveSession extends Mock implements ObserveSessionUseCase {}

class _MockObserveToday extends Mock implements ObserveTodayAttendanceUseCase {}

class _MockObserveHistory extends Mock implements ObserveAttendanceHistoryUseCase {}

class _MockObserveSchedule extends Mock implements ObserveWeeklyScheduleUseCase {}

class _MockRefresh extends Mock implements RefreshAttendanceUseCase {}

class _MockClockIn extends Mock implements ClockInUseCase {}

class _MockClockOut extends Mock implements ClockOutUseCase {}

class _MockSubmit extends Mock implements SubmitJustificationUseCase {}

class _MockLocation extends Mock implements GetCurrentLocationUseCase {}

class _MockPermission extends Mock implements IsLocationPermissionGrantedUseCase {}

const _branch = Branch(
  id: 'b1',
  name: 'Sede',
  latitude: -12.0464,
  longitude: -77.0428,
  geofenceRadiusMeters: 100,
  isActive: true,
);

const _schedule = WeeklySchedule(
  branchId: 'b1',
  shiftId: 's1',
  shift: WorkShift(
    id: 's1',
    name: 'Turno',
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
    email: 'a@b.pe',
    fullName: 'Andrés',
    tenantId: 't1',
    tenantName: 'Taller',
    membershipId: 'm1',
    permissions: permissions,
    plan: null,
    branchId: 'b1',
    shiftId: 's1',
  );
}

void main() {
  final strings = lookupAppLocalizations(const Locale('es'));

  late _MockObserveSession observeSession;
  late _MockRefresh refresh;
  late _MockClockIn clockIn;
  late _MockClockOut clockOut;
  late _MockSubmit submit;
  late _MockLocation location;
  late _MockPermission permission;

  AttendanceViewModel build(Session? session) {
    final observeToday = _MockObserveToday();
    final observeHistory = _MockObserveHistory();
    final observeSchedule = _MockObserveSchedule();
    when(() => observeSession.execute()).thenAnswer((_) => Stream.value(session));
    when(() => observeToday.execute()).thenAnswer((_) => Stream.value(const NotClockedIn()));
    when(() => observeHistory.execute()).thenAnswer((_) => Stream.value(const <Attendance>[]));
    when(() => observeSchedule.execute()).thenAnswer((_) => Stream.value(_schedule));
    return AttendanceViewModel(
      observeSession: observeSession,
      observeToday: observeToday,
      observeHistory: observeHistory,
      observeSchedule: observeSchedule,
      refreshAttendance: refresh,
      clockInUseCase: clockIn,
      clockOutUseCase: clockOut,
      submitJustificationUseCase: submit,
      getCurrentLocation: location,
      isLocationPermissionGranted: permission,
    );
  }

  setUp(() {
    observeSession = _MockObserveSession();
    refresh = _MockRefresh();
    clockIn = _MockClockIn();
    clockOut = _MockClockOut();
    submit = _MockSubmit();
    location = _MockLocation();
    permission = _MockPermission();
    when(() => refresh.execute()).thenAnswer((_) async {});
    when(() => permission.execute()).thenAnswer((_) async => true);
  });

  const full = {
    'hr:attendance:clock_in',
    'hr:attendance:clock_out',
    'hr:justifications:create',
  };

  test('al abrir refresca y arma el estado con la sesión, el turno y la jornada', () async {
    final viewModel = build(_session(full));
    addTearDown(viewModel.dispose);
    await pumpEventQueue();

    final state = viewModel.state;
    expect(state.isRefreshing, isFalse);
    expect(state.schedule?.branch?.name, 'Sede');
    expect(state.canClockIn, isTrue);
    verify(() => refresh.execute()).called(1);
  });

  test('marcar ingreso sin red avisa que quedó guardado', () async {
    when(() => clockIn.execute(any(), any())).thenAnswer(
      (_) async => const ClockInResult(
        outcome: Queued(),
        geofence: GeofenceCheck(distanceMeters: 12, isInside: true, isMock: false),
      ),
    );
    final viewModel = build(_session(full));
    addTearDown(viewModel.dispose);
    await pumpEventQueue();

    await viewModel.clockIn();

    expect(viewModel.state.notice!.asString(strings), strings.attendanceClockInQueued);
    expect(viewModel.state.error, isNull);
    expect(viewModel.state.isSubmitting, isFalse);
    verify(() => clockIn.execute('b1', 's1')).called(1);
  });

  test('marcar fuera de la geocerca muestra la distancia y el radio', () async {
    when(() => clockIn.execute(any(), any())).thenThrow(
      const LocationOutsideGeofenceException(250.4, 100),
    );
    final viewModel = build(_session(full));
    addTearDown(viewModel.dispose);
    await pumpEventQueue();

    await viewModel.clockIn();

    expect(
      viewModel.state.error!.asString(strings),
      strings.attendanceOutsideGeofenceBlocked(250, 100),
    );
    expect(viewModel.state.notice, isNull);
  });

  test('cada error de ubicación tiene su mensaje', () {
    expect(
      toAttendanceUiText(const LocationPermissionDeniedException()).asString(strings),
      strings.attendanceLocationPermissionRequired,
    );
    expect(
      toAttendanceUiText(const LocationUnavailableException()).asString(strings),
      strings.attendanceLocationUnavailable,
    );
    expect(
      toAttendanceUiText(const LocationTooInaccurateException(63.7)).asString(strings),
      strings.attendanceLocationInaccurate(63),
    );
    expect(
      toAttendanceUiText(const MockLocationException()).asString(strings),
      strings.attendanceMockLocationBlocked,
    );
    expect(
      toAttendanceUiText(const BranchGeofenceUnavailableException()).asString(strings),
      strings.attendanceBranchGeofenceUnavailable,
    );
    expect(
      toAttendanceUiText(Exception('x')).asString(strings),
      strings.errorGeneric,
    );
  });

  test('sin permiso de marcar no llama al caso de uso', () async {
    final viewModel = build(_session({'hr:attendance:clock_out'}));
    addTearDown(viewModel.dispose);
    await pumpEventQueue();

    await viewModel.clockIn();

    expect(viewModel.state.error!.asString(strings), strings.attendancePermissionClockIn);
    verifyNever(() => clockIn.execute(any(), any()));
  });

  test('marcar salida confirma el registro', () async {
    when(() => clockOut.execute()).thenAnswer((_) async => const AlreadyQueued());
    final viewModel = build(_session(full));
    addTearDown(viewModel.dispose);
    await pumpEventQueue();

    await viewModel.clockOut();

    expect(viewModel.state.notice!.asString(strings), strings.attendanceAlreadyQueued);
  });

  group('descargo', () {
    final attendance = Attendance(
      id: AttendanceId('a1'),
      branchId: 'b1',
      shiftId: 's1',
      clockIn: DateTime.utc(2026, 11, 16, 13, 18),
      clockOut: null,
      status: null,
      distanceToBranchMeters: 10,
      workedMinutes: null,
      regularMinutes: null,
      overtimeMinutes: null,
      justificationReason: null,
      justificationStatus: null,
      syncedAt: DateTime.utc(2026, 11, 16, 13, 18),
    );

    test('el texto se corta a 500 caracteres y se envía con la jornada', () async {
      when(() => submit.execute(any(), any())).thenAnswer((_) async => const Queued());
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.requestJustification(attendance);
      viewModel.onJustificationChange('a' * 600);
      expect(viewModel.state.justification.length, 500);

      await viewModel.submitJustification();

      expect(viewModel.state.justificationFor, isNull);
      expect(viewModel.state.justification, isEmpty);
      expect(viewModel.state.notice!.asString(strings), strings.attendanceJustificationQueued);
      final captured = verify(() => submit.execute(captureAny(), captureAny())).captured;
      expect((captured[0] as AttendanceId).value, 'a1');
      expect((captured[1] as String).length, 500);
    });

    test('sin permiso de justificar no abre la hoja', () async {
      final viewModel = build(_session({'hr:attendance:clock_in'}));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.requestJustification(attendance);

      expect(viewModel.state.justificationFor, isNull);
      expect(viewModel.state.error!.asString(strings), strings.attendancePermissionJustification);
    });

    test('un descargo inválido deja la hoja abierta con el error', () async {
      when(() => submit.execute(any(), any())).thenThrow(const InvalidJustificationException());
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      viewModel.requestJustification(attendance);
      await viewModel.submitJustification();

      expect(viewModel.state.justificationFor, isNotNull);
      expect(viewModel.state.error!.asString(strings), strings.attendanceJustificationInvalid);
    });
  });

  group('vista previa de la geocerca', () {
    test('fuera del radio avisa con la distancia y guarda la ubicación', () async {
      when(() => location.execute()).thenAnswer(
        (_) async => const DeviceLocation(
          latitude: -12.0600,
          longitude: -77.0428,
          accuracyMeters: 10,
          isMock: false,
        ),
      );
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      await viewModel.previewLocation();

      expect(viewModel.state.deviceLocation, isNotNull);
      expect(viewModel.state.isLocating, isFalse);
      expect(viewModel.state.locationWarning, isNotNull);
      expect(viewModel.state.locationWarning!.asString(strings), contains('radio permitido es 100 m'));
    });

    test('dentro del radio no avisa', () async {
      when(() => location.execute()).thenAnswer(
        (_) async => const DeviceLocation(
          latitude: -12.0464,
          longitude: -77.0428,
          accuracyMeters: 10,
          isMock: false,
        ),
      );
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      await viewModel.previewLocation();

      expect(viewModel.state.locationWarning, isNull);
    });

    test('sin permiso o sin GPS muestra el error y limpia la ubicación', () async {
      when(() => location.execute()).thenThrow(const LocationUnavailableException());
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      await viewModel.previewLocation();

      expect(viewModel.state.deviceLocation, isNull);
      expect(viewModel.state.error!.asString(strings), strings.attendanceLocationUnavailable);
    });

    test('al abrir solo muestra la vista previa si el permiso ya estaba concedido', () async {
      when(() => permission.execute()).thenAnswer((_) async => false);
      final viewModel = build(_session(full));
      addTearDown(viewModel.dispose);
      await pumpEventQueue();

      await viewModel.previewLocationIfGranted();

      verifyNever(() => location.execute());
    });
  });
}
