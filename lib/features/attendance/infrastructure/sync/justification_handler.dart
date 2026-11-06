import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/justify_attendance_request_dto.dart';

/// `SUBMIT_JUSTIFICATION`: 422 "ya justificada" → aplicada (docs/06-offline-sync.md §3). El payload
/// es `{ attendanceId, reason }`: el id va en la ruta y el body es `{ reason }`.
class JustificationHandler implements OperationHandler {
  static const type = 'SUBMIT_JUSTIFICATION';

  final AttendanceApi api;
  final AttendanceCache cache;
  final AttendanceDao dao;
  final SessionManager session;

  const JustificationHandler({
    required this.api,
    required this.cache,
    required this.dao,
    required this.session,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final Map<String, dynamic> payload = jsonDecode(operation.payload);
    final attendanceId = payload['attendanceId'] as String;
    final reason = payload['reason'] as String;
    AttendanceDto? dto;
    final result = await OperationResult.from(
      () async => dto = await api.submitJustification(
        attendanceId,
        JustifyAttendanceRequestDto(reason: reason),
      ),
      alreadyApplied: (e) => e.httpStatus == 422,
    );
    if (result is! Applied) return result;

    final membershipId = (await session.getSession())?.membershipId;
    if (membershipId == null) return result;
    final saved = dto;
    await AttendanceCache.quietly(() async {
      if (saved != null) {
        await cache.save(saved, membershipId);
        return;
      }
      // 422 no trae la jornada: se recarga el día de esa asistencia.
      final row = await dao.findById(attendanceId);
      if (row == null) return;
      final clockIn = DateTime.fromMillisecondsSinceEpoch(
        row.clockIn,
        isUtc: true,
      );
      await cache.refreshDay(membershipId, BusinessTime.limaDate(clockIn));
    });
    return result;
  }
}
