import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/week_day.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/work_shift.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/work_shift_dto.dart';

DateTime _utc(int millis) {
  return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
}

extension AttendanceDtoMapper on AttendanceDto {
  /// `null` si el backend no envió la hora de ingreso: no se puede ubicar en el día.
  AttendanceEntity? toEntity(String fallbackMembershipId, int syncedAt) {
    final clockIn = this.clockIn;
    if (clockIn == null) return null;
    final clockOut = this.clockOut;
    return AttendanceEntity(
      id: id,
      branchId: branchId ?? '',
      membershipId: membershipId ?? fallbackMembershipId,
      shiftId: shiftId ?? '',
      clockIn: DateTime.parse(clockIn).millisecondsSinceEpoch,
      clockOut: clockOut == null
          ? null
          : DateTime.parse(clockOut).millisecondsSinceEpoch,
      status: status ?? '',
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      distanceToBranchMeters: distanceToBranchMeters ?? 0,
      workedMinutes: workedMinutes,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      justificationReason: justificationReason,
      justificationStatus: justificationStatus,
      syncedAt: syncedAt,
    );
  }
}

extension AttendanceEntityMapper on AttendanceEntity {
  Attendance toDomain() {
    final clockOut = this.clockOut;
    return Attendance(
      id: AttendanceId(id),
      branchId: branchId,
      shiftId: shiftId,
      clockIn: _utc(clockIn),
      clockOut: clockOut == null ? null : _utc(clockOut),
      status: AttendanceStatus.fromApi(status),
      distanceToBranchMeters: distanceToBranchMeters,
      workedMinutes: workedMinutes,
      regularMinutes: regularMinutes,
      overtimeMinutes: overtimeMinutes,
      justificationReason: justificationReason,
      justificationStatus: JustificationStatus.fromApi(justificationStatus),
      syncedAt: _utc(syncedAt),
    );
  }
}

extension WorkShiftDtoMapper on WorkShiftDto {
  ShiftEntity toEntity(int syncedAt) {
    return ShiftEntity(
      id: id,
      name: name ?? '',
      startTime: startTime,
      endTime: endTime,
      gracePeriodMinutes: gracePeriodMinutes ?? 0,
      workDays: workDays.join(','),
      restDays: restDays.join(','),
      isActive: isActive ?? true,
      syncedAt: syncedAt,
    );
  }
}

extension ShiftEntityMapper on ShiftEntity {
  WorkShift toDomain() {
    return WorkShift(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      gracePeriodMinutes: gracePeriodMinutes,
      workDays: _days(workDays),
      restDays: _days(restDays),
      isActive: isActive,
    );
  }

  Set<WeekDay> _days(String value) {
    return value
        .split(',')
        .map((day) => WeekDay.fromApi(day.trim()))
        .nonNulls
        .toSet();
  }
}

extension BranchDtoMapper on BranchDto {
  /// `null` si la sede no tiene coordenadas: no sirve para la geocerca.
  BranchEntity? toEntity(int syncedAt) {
    final latitude = this.latitude;
    final longitude = this.longitude;
    final radius = geofenceRadiusMeters;
    if (latitude == null || longitude == null || radius == null) return null;
    return BranchEntity(
      id: id,
      name: name ?? '',
      latitude: latitude,
      longitude: longitude,
      geofenceRadiusMeters: radius.toDouble(),
      isActive: isActive ?? true,
      syncedAt: syncedAt,
    );
  }
}

extension BranchEntityMapper on BranchEntity {
  Branch toDomain() {
    return Branch(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      geofenceRadiusMeters: geofenceRadiusMeters,
      isActive: isActive,
    );
  }
}
