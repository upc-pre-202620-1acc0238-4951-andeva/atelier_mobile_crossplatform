import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';

/// Lo que solo usa la jefatura de docs/api/hr.md. El historial por colaborador es `AttendanceApi`.
class TeamApi {
  static const _base = '/api/v1/hr/attendances';

  final ApiClient client;

  const TeamApi({required this.client});

  Future<List<AttendanceDto>> getBranchDaily(
    String branchId,
    String date,
  ) async {
    final List list = await client.get(
      '$_base/branch/$branchId/daily',
      query: {'date': date},
    );
    return list
        .map((e) => AttendanceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AttendanceDto> approveJustification(String attendanceId) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$attendanceId/justification/approve',
    );
    return AttendanceDto.fromJson(json);
  }

  Future<AttendanceDto> rejectJustification(String attendanceId) async {
    final Map<String, dynamic> json = await client.post(
      '$_base/$attendanceId/justification/reject',
    );
    return AttendanceDto.fromJson(json);
  }
}
