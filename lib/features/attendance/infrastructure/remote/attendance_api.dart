import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_out_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/justify_attendance_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/work_shift_dto.dart';

class AttendanceApi {
  static const _base = '/api/v1/hr/attendances';

  final ApiClient client;

  const AttendanceApi({required this.client});

  Future<AttendanceDto> clockIn(ClockInRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/clock-in',
      body: body,
    );
    return AttendanceDto.fromJson(json);
  }

  Future<AttendanceDto> clockOut(ClockOutRequestDto body) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/clock-out',
      body: body,
    );
    return AttendanceDto.fromJson(json);
  }

  /// `null` si el backend responde 200 sin cuerpo. Sin jornada responde 404 (H2).
  Future<AttendanceDto?> statusToday(String membershipId) async {
    final Map<String, dynamic>? json = await client.get(
      '$_base/employee/$membershipId/status-today',
    );
    return json == null ? null : AttendanceDto.fromJson(json);
  }

  Future<List<AttendanceDto>> history(
    String membershipId,
    String startDate,
    String endDate,
  ) async {
    final List jsons = await client.get(
      '$_base/employee/$membershipId/history',
      query: {'startDate': startDate, 'endDate': endDate},
    );
    return jsons.map((e) => AttendanceDto.fromJson(e)).toList();
  }

  Future<AttendanceDto> submitJustification(
    String attendanceId,
    JustifyAttendanceRequestDto body,
  ) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$attendanceId/justification',
      body: body,
    );
    return AttendanceDto.fromJson(json);
  }

  Future<WorkShiftDto> getWorkShift(String shiftId) async {
    final Map<String, dynamic> json = await client.get(
      '/api/v1/hr/work-shifts/$shiftId',
    );
    return WorkShiftDto.fromJson(json);
  }
}
