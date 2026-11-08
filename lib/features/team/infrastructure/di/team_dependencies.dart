import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_collaborator_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_repository.dart';
import 'package:atelier_mobile_crossplatform/features/team/infrastructure/remote/team_api.dart';
import 'package:atelier_mobile_crossplatform/features/team/infrastructure/team_repository_impl.dart';

void setupTeamDependencies() {
  getIt.registerLazySingleton<TeamApi>(
    () => TeamApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(
      api: getIt<TeamApi>(),
      attendanceApi: getIt<AttendanceApi>(),
      employeeApi: getIt<EmployeeApi>(),
      session: getIt<SessionManager>(),
    ),
  );
  getIt.registerLazySingleton<GetBranchDailyAttendanceUseCase>(
    () => GetBranchDailyAttendanceUseCase(repository: getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<GetPendingJustificationsUseCase>(
    () => GetPendingJustificationsUseCase(repository: getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<GetCollaboratorAttendanceUseCase>(
    () => GetCollaboratorAttendanceUseCase(repository: getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<ApproveJustificationUseCase>(
    () => ApproveJustificationUseCase(repository: getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<RejectJustificationUseCase>(
    () => RejectJustificationUseCase(repository: getIt<TeamRepository>()),
  );
}
