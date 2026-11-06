import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_in_request_dto.dart';

/// `CLOCK_IN`: 409 = ya existe una jornada abierta → aplicada (docs/06-offline-sync.md §3).
class ClockInHandler implements OperationHandler {
  static const type = 'CLOCK_IN';

  final AttendanceApi api;
  final AttendanceCache cache;
  final SessionManager session;
  final DateTime Function() now;

  const ClockInHandler({
    required this.api,
    required this.cache,
    required this.session,
    this.now = DateTime.now,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) async {
    final body = ClockInRequestDto.fromJson(jsonDecode(operation.payload));
    AttendanceDto? dto;
    final result = await OperationResult.from(
      () async => dto = await api.clockIn(body),
      alreadyApplied: (e) => e.httpStatus == 409,
    );
    if (result is! Applied) return result;

    final membershipId = (await session.getSession())?.membershipId;
    if (membershipId == null) return result;
    final saved = dto;
    await AttendanceCache.quietly(() async {
      if (saved != null) {
        await cache.save(saved, membershipId);
      } else {
        // 409 no trae la jornada: se recarga el día para que la caché no quede vieja.
        final capturedAt = DateTime.tryParse(body.clockInTime ?? '') ?? now();
        await cache.refreshDay(membershipId, BusinessTime.limaDate(capturedAt));
      }
    });
    return result;
  }
}
