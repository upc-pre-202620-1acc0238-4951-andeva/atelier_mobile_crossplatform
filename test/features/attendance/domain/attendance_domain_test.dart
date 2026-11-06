import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_validation.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/work_shift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const branch = Branch(
    id: 'b1',
    name: 'Sede Lima',
    latitude: -12.0464,
    longitude: -77.0428,
    geofenceRadiusMeters: 100,
    isActive: true,
  );

  DeviceLocation location(double lat, double lon, {double accuracy = 10}) {
    return DeviceLocation(
      latitude: lat,
      longitude: lon,
      accuracyMeters: accuracy,
      isMock: false,
    );
  }

  WorkShift shift({
    Set<WeekDay> workDays = const {},
    Set<WeekDay> restDays = const {WeekDay.sunday},
  }) {
    return WorkShift(
      id: 's1',
      name: 'Mañana',
      startTime: '08:00:00',
      endTime: '17:00:00',
      gracePeriodMinutes: 15,
      workDays: workDays,
      restDays: restDays,
      isActive: true,
    );
  }

  test('haversine con una distancia conocida', () {
    // Un grado de latitud ≈ 111.2 km.
    expect(Geofence.distanceMeters(0, 0, 1, 0), closeTo(111195, 50));
  });

  test('geocerca dentro y fuera del radio', () {
    final inside = Geofence.check(branch, location(-12.0468, -77.0428));
    expect(inside.isInside, isTrue);
    expect(inside.distanceMeters, closeTo(44.5, 2));

    final outside = Geofence.check(branch, location(-12.05, -77.0428));
    expect(outside.isInside, isFalse);
  });

  test('validación del descargo y de la precisión', () {
    expect(AttendanceValidation.isJustification('Tráfico'), isTrue);
    expect(AttendanceValidation.isJustification('   '), isFalse);
    expect(AttendanceValidation.isJustification('a' * 500), isTrue);
    expect(AttendanceValidation.isJustification('a' * 501), isFalse);
    expect(
      AttendanceValidation.isJustification(' ${'a' * 500} '),
      isTrue,
      reason: 'el repositorio envía el motivo sin espacios',
    );

    expect(
      AttendanceValidation.isAccurate(location(0, 0, accuracy: 50)),
      isTrue,
    );
    expect(
      AttendanceValidation.isAccurate(location(0, 0, accuracy: 50.1)),
      isFalse,
    );
  });

  test('semana del turno con descansos', () {
    final days = WeeklySchedule(
      branchId: 'b1',
      shiftId: 's1',
      shift: shift(
        workDays: {
          WeekDay.monday,
          WeekDay.tuesday,
          WeekDay.wednesday,
          WeekDay.thursday,
          WeekDay.friday,
          WeekDay.saturday,
        },
      ),
      branch: branch,
    ).days;

    expect(days.map((d) => d.day), WeekDay.values);
    expect(days.where((d) => !d.isWorkDay).map((d) => d.day), [WeekDay.sunday]);
  });

  test('sin workDays publicados se trabaja todo menos el descanso', () {
    final days = WeeklySchedule(
      branchId: null,
      shiftId: 's1',
      shift: shift(),
      branch: null,
    ).days;

    expect(days.where((d) => d.isWorkDay), hasLength(6));
  });

  test('un valor nuevo del backend no cierra la app', () {
    expect(AttendanceStatus.fromApi('ON_TIME'), AttendanceStatus.onTime);
    expect(AttendanceStatus.fromApi('NUEVO'), isNull);
    expect(JustificationStatus.fromApi(null), isNull);
    expect(WeekDay.fromApi('NUEVO'), isNull);
  });
}
