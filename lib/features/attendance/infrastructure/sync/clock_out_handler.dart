import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_out_request_dto.dart';

/// `CLOCK_OUT`. 400 ("salida ya registrada", pero también reloj desajustado) y 404 ("sin jornada
/// abierta", pero también salida sin ingreso, US08 E3) son ambiguos: se verifican con `history`
/// (docs/06-offline-sync.md §3). Si la jornada ya tiene salida → aplicada; si no → FAILED con el
/// `message` del backend.
class ClockOutHandler implements OperationHandler {
  static const type = 'CLOCK_OUT';
  static const _ambiguous = {400, 404};

  final AttendanceApi api;
  final AttendanceCache cache;
  final SessionManager session;
  final DateTime Function() now;

  const ClockOutHandler({
    required this.api,
    required this.cache,
    required this.session,
    this.now = DateTime.now,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final body = ClockOutRequestDto.fromJson(jsonDecode(operation.payload));
    AttendanceDto? dto;
    final result = await OperationResult.from(
      () async => dto = await api.clockOut(body),
    );
    final membershipId = (await session.getSession())?.membershipId;
    if (membershipId == null) return result;

    if (result is Applied) {
      final saved = dto;
      if (saved != null) {
        await AttendanceCache.quietly(() => cache.save(saved, membershipId));
      }
      return result;
    }
    if (result is Failed && _ambiguous.contains(result.httpStatus)) {
      return _verify(body, membershipId, result);
    }
    return result;
  }

  /// Con el día anterior: una jornada nocturna empezó ayer y `history` puede filtrar por ingreso.
  Future<OperationResult> _verify(
    ClockOutRequestDto body,
    String membershipId,
    Failed original,
  ) async {
    final capturedAt = DateTime.tryParse(body.clockOutTime ?? '') ?? now();
    final day = BusinessTime.limaDate(capturedAt);
    var rows = const <AttendanceEntity>[];
    final check = await OperationResult.from(() async {
      rows = await cache.refreshRange(
        membershipId,
        BusinessTime.addDays(day, -1),
        day,
      );
    });
    // Un 403 o 400 al verificar no dice nada de la salida: vale el error original.
    if (check is Failed) return original;
    if (check is! Applied) return check;

    final millis = capturedAt.millisecondsSinceEpoch;
    final capturedSecond = millis - millis % 1000;
    final attendanceId = body.attendanceId;
    final closed = rows.any((row) {
      final clockOut = row.clockOut;
      if (clockOut == null) return false;
      // Sin id, la jornada cerrada de ayer terminó antes de esta salida y no se confunde con ella.
      return attendanceId != null
          ? row.id == attendanceId
          : clockOut >= capturedSecond;
    });
    return closed ? const Applied() : original;
  }
}
