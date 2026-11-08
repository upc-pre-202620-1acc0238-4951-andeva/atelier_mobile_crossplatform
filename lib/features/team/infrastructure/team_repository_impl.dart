import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/missing_branch_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/justification_status.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';
import 'package:atelier_mobile_crossplatform/features/team/infrastructure/remote/team_api.dart';

class TeamRepositoryImpl implements TeamRepository {
  static const collaboratorLookbackDays = 30;

  final TeamApi api;
  final AttendanceApi attendanceApi;
  final EmployeeApi employeeApi;
  final SessionManager session;
  final BusinessTime time;

  const TeamRepositoryImpl({
    required this.api,
    required this.attendanceApi,
    required this.employeeApi,
    required this.session,
    this.time = const BusinessTime(),
  });

  @override
  Future<List<TeamAttendance>> getBranchDaily(String date) async {
    final current = await session.getSession();
    if (current == null || !current.has(Permission.attendanceAuditAll)) {
      return const [];
    }
    final branchId = _branch(current);
    final titles = _jobTitles(current, branchId);
    final rows = await _readDay(branchId, date)
      ..sort(_recentFirst);
    return _withTitles(rows, await titles);
  }

  @override
  Future<PendingJustifications> getPendingJustifications(int days) async {
    if (days < 1) throw ArgumentError.value(days, 'days', 'Debe ser >= 1');
    final current = await session.getSession();
    if (current == null || !current.has(Permission.attendanceAuditAll)) {
      return const PendingJustifications(items: [], failedDates: []);
    }
    final branchId = _branch(current);
    final today = time.today();
    final dates = [
      for (var i = 0; i < days; i++) BusinessTime.addDays(today, -i),
    ];
    final titles = _jobTitles(current, branchId);
    final results = await Future.wait([
      for (final date in dates)
        _readDay(
          branchId,
          date,
        ).then<Object>((rows) => rows, onError: (Object e) => e),
    ]);
    final failedDates = [
      for (var i = 0; i < dates.length; i++)
        if (results[i] is! List<TeamAttendance>) dates[i],
    ];
    if (failedDates.length == dates.length) throw results.first;
    final items = [
      for (final result in results)
        if (result is List<TeamAttendance>)
          ...(result.where((row) => row.awaitsReview).toList()
            ..sort(_recentFirst)),
    ];
    return PendingJustifications(
      items: _withTitles(items, await titles),
      failedDates: failedDates,
    );
  }

  @override
  Future<TeamAttendance?> getCollaboratorAttendance(
    String membershipId,
    String attendanceId,
  ) async {
    final today = time.today();
    final dtos = await attendanceApi.history(
      membershipId,
      BusinessTime.addDays(today, -(collaboratorLookbackDays - 1)),
      today,
    );
    for (final dto in dtos) {
      if (dto.id == attendanceId) return _toTeam(dto);
    }
    return null;
  }

  @override
  Future<TeamAttendance> approveJustification(String attendanceId) async {
    return _toTeam(await api.approveJustification(attendanceId));
  }

  @override
  Future<TeamAttendance> rejectJustification(String attendanceId) async {
    return _toTeam(await api.rejectJustification(attendanceId));
  }

  String _branch(Session current) {
    return current.branchId ?? (throw const MissingBranchException());
  }

  /// Un cuerpo ilegible o una fila mal formada hacen fallar el día entero.
  Future<List<TeamAttendance>> _readDay(String branchId, String date) async {
    final dtos = await api.getBranchDaily(branchId, date);
    return dtos.map(_toTeam).toList();
  }

  /// Solo con `iam:members:read` (H32); si falla, sin títulos.
  Future<Map<String, String>> _jobTitles(
    Session current,
    String branchId,
  ) async {
    if (!current.has(Permission.membersRead)) return const {};
    try {
      return {
        for (final profile in await employeeApi.getByBranch(branchId))
          if (profile.membershipId case final id? when id.trim().isNotEmpty)
            if (profile.jobTitle case final title? when title.trim().isNotEmpty)
              id: title,
      };
    } catch (_) {
      return const {};
    }
  }

  List<TeamAttendance> _withTitles(
    List<TeamAttendance> rows,
    Map<String, String> titles,
  ) {
    if (titles.isEmpty) return rows;
    return [for (final row in rows) row.withJobTitle(titles[row.membershipId])];
  }

  /// El más reciente primero; sin hora de ingreso, al final.
  static int _recentFirst(TeamAttendance a, TeamAttendance b) {
    final left = a.clockIn;
    final right = b.clockIn;
    if (left == null) return right == null ? 0 : 1;
    if (right == null) return -1;
    return right.compareTo(left);
  }

  TeamAttendance _toTeam(AttendanceDto dto) {
    final membershipId = dto.membershipId;
    final branchId = dto.branchId;
    if (dto.id.trim().isEmpty ||
        membershipId == null ||
        membershipId.trim().isEmpty ||
        branchId == null ||
        branchId.trim().isEmpty) {
      throw FormatException('Asistencia sin id, colaborador o sede: ${dto.id}');
    }
    return TeamAttendance(
      id: dto.id,
      membershipId: membershipId,
      branchId: branchId,
      shiftId: dto.shiftId,
      clockIn: _instant(dto.clockIn),
      clockOut: _instant(dto.clockOut),
      status: AttendanceStatus.fromApi(dto.status),
      distanceToBranchMeters: dto.distanceToBranchMeters,
      workedMinutes: dto.workedMinutes,
      overtimeMinutes: dto.overtimeMinutes,
      justificationReason: dto.justificationReason,
      justificationStatus: JustificationStatus.fromApi(dto.justificationStatus),
      reviewedBy: dto.justificationReviewedBy,
      reviewedAt: _instant(dto.justificationReviewedAt),
    );
  }

  /// Una fecha presente pero ilegible lanza: mejor fallar que mostrar otra hora.
  static DateTime? _instant(String? raw) =>
      raw == null ? null : DateTime.parse(raw);
}
