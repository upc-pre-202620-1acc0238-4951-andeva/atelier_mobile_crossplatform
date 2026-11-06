import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

AttendanceEntity _row(
  String id, {
  String membershipId = 'm1',
  required int clockIn,
  int? clockOut,
}) {
  return AttendanceEntity(
    id: id,
    branchId: 'b1',
    membershipId: membershipId,
    shiftId: 's1',
    clockIn: clockIn,
    clockOut: clockOut,
    status: 'ON_TIME',
    latitude: 0,
    longitude: 0,
    distanceToBranchMeters: 0,
    syncedAt: 0,
  );
}

void main() {
  late AppDatabase database;
  late AttendanceDao dao;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dao = database.attendanceDao;
  });
  tearDown(() => database.close());

  test('replaceRange solo toca el rango y el colaborador', () async {
    await dao.upsert(_row('antes', clockIn: 50));
    await dao.upsert(_row('dentro', clockIn: 100));
    await dao.upsert(_row('borde', clockIn: 200));
    await dao.upsert(_row('otro', membershipId: 'm2', clockIn: 150));

    await dao.replaceRange('m1', 100, 200, [_row('nueva', clockIn: 150)]);

    final m1 = await dao.watchSince('m1', 0).first;
    expect(m1.map((r) => r.id), ['borde', 'nueva', 'antes']);
    expect(await dao.findById('otro'), isNotNull);
  });

  test('upsert deja lo que manda el backend, también los nulos', () async {
    await dao.upsert(_row('a', clockIn: 100, clockOut: 300));
    await dao.upsert(_row('a', clockIn: 100));
    expect((await dao.findById('a'))!.clockOut, isNull);

    await dao.upsert(_row('a', clockIn: 100, clockOut: 300));
    await dao.replaceRange('m1', 0, 200, [_row('a', clockIn: 100)]);
    expect((await dao.findById('a'))!.clockOut, isNull);
  });

  test('la más reciente y la abierta son por colaborador', () async {
    await dao.upsert(_row('vieja', clockIn: 100));
    await dao.upsert(_row('nueva', clockIn: 200, clockOut: 300));
    await dao.upsert(_row('ajena', membershipId: 'm2', clockIn: 400));

    expect((await dao.watchLatest('m1').first)!.id, 'nueva');
    expect((await dao.findOpen('m1'))!.id, 'vieja');
    expect(await dao.findOpen('m3'), isNull);
    expect(await dao.watchLatest('m3').first, isNull);
  });

  test('el historial va del más reciente al más antiguo desde la fecha', () async {
    await dao.upsert(_row('a', clockIn: 100));
    await dao.upsert(_row('b', clockIn: 200));
    await dao.upsert(_row('c', clockIn: 300));

    final rows = await dao.watchSince('m1', 200).first;

    expect(rows.map((r) => r.id), ['c', 'b']);
  });
}
