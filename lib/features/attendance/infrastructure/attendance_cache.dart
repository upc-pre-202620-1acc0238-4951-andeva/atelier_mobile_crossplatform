import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';

/// Escrituras en la caché `attendances` que comparten el repositorio y los handlers de la cola.
class AttendanceCache {
  final AttendanceApi api;
  final AttendanceDao dao;
  final DateTime Function() now;

  const AttendanceCache({
    required this.api,
    required this.dao,
    this.now = DateTime.now,
  });

  /// Guarda la `AttendanceResource` que devolvió una escritura.
  Future<AttendanceEntity?> save(AttendanceDto dto, String membershipId) async {
    final row = dto.toEntity(membershipId, now().millisecondsSinceEpoch);
    if (row != null) await dao.upsert(row);
    return row;
  }

  /// Recarga los días de Lima [from]..[to] con `history` y devuelve lo que trajo.
  Future<List<AttendanceEntity>> refreshRange(
    String membershipId,
    String from,
    String to,
  ) async {
    final dtos = await api.history(membershipId, from, to);
    final syncedAt = now().millisecondsSinceEpoch;
    final rows = dtos
        .map((dto) => dto.toEntity(membershipId, syncedAt))
        .nonNulls
        .toList();
    await dao.replaceRange(
      membershipId,
      BusinessTime.startOfDay(from).millisecondsSinceEpoch,
      BusinessTime.startOfDay(BusinessTime.addDays(to, 1)).millisecondsSinceEpoch,
      rows,
    );
    return rows;
  }

  Future<List<AttendanceEntity>> refreshDay(String membershipId, String date) {
    return refreshRange(membershipId, date, date);
  }

  /// Para los handlers, tras `Applied`: si esto subiera, `SyncProcessor` reintentaría algo ya
  /// aplicado. La caché se corrige en el siguiente refresh.
  static Future<void> quietly(Future<void> Function() write) async {
    try {
      await write();
    } catch (e) {
      log('No se pudo actualizar la caché: $e', name: 'AttendanceCache');
    }
  }
}
