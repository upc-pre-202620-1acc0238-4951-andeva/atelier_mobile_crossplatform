import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_attendance_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_weekly_schedule_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/submit_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/location/geolocator_location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_in_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_out_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/justification_handler.dart';

void setupAttendanceDependencies() {
  getIt.registerLazySingleton<AttendanceDao>(
    () => getIt<AppDatabase>().attendanceDao,
  );
  getIt.registerLazySingleton<ShiftDao>(() => getIt<AppDatabase>().shiftDao);
  getIt.registerLazySingleton<BranchDao>(() => getIt<AppDatabase>().branchDao);
  getIt.registerLazySingleton<AttendanceApi>(
    () => AttendanceApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<AttendanceCache>(
    () => AttendanceCache(
      api: getIt<AttendanceApi>(),
      dao: getIt<AttendanceDao>(),
    ),
  );

  // Corre también en el worker: los handlers no dependen de nada que sea solo de la UI.
  final handlers = getIt<OperationHandlerRegistry>();
  handlers.register(
    ClockInHandler.type,
    () => ClockInHandler(
      api: getIt<AttendanceApi>(),
      cache: getIt<AttendanceCache>(),
      session: getIt<SessionManager>(),
    ),
  );
  handlers.register(
    ClockOutHandler.type,
    () => ClockOutHandler(
      api: getIt<AttendanceApi>(),
      cache: getIt<AttendanceCache>(),
      session: getIt<SessionManager>(),
    ),
  );
  handlers.register(
    JustificationHandler.type,
    () => JustificationHandler(
      api: getIt<AttendanceApi>(),
      cache: getIt<AttendanceCache>(),
      dao: getIt<AttendanceDao>(),
      session: getIt<SessionManager>(),
    ),
  );

  getIt.registerLazySingleton<LocationProvider>(
    () => const GeolocatorLocationProvider(),
  );
  getIt.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      api: getIt<AttendanceApi>(),
      branchApi: getIt<BranchApi>(),
      employeeApi: getIt<EmployeeApi>(),
      attendanceDao: getIt<AttendanceDao>(),
      shiftDao: getIt<ShiftDao>(),
      branchDao: getIt<BranchDao>(),
      cacheMetadataDao: getIt<CacheMetadataDao>(),
      pendingOperationDao: getIt<PendingOperationDao>(),
      queue: getIt<PendingOperationQueue>(),
      cache: getIt<AttendanceCache>(),
      session: getIt<SessionManager>(),
      connectivity: getIt<ConnectivityObserver>(),
    ),
  );

  getIt.registerLazySingleton<RefreshAttendanceUseCase>(
    () => RefreshAttendanceUseCase(repository: getIt<AttendanceRepository>()),
  );
  getIt.registerLazySingleton<ObserveTodayAttendanceUseCase>(
    () => ObserveTodayAttendanceUseCase(
      repository: getIt<AttendanceRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveAttendanceHistoryUseCase>(
    () => ObserveAttendanceHistoryUseCase(
      repository: getIt<AttendanceRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObserveWeeklyScheduleUseCase>(
    () => ObserveWeeklyScheduleUseCase(
      repository: getIt<AttendanceRepository>(),
    ),
  );
  getIt.registerLazySingleton<ClockInUseCase>(
    () => ClockInUseCase(
      repository: getIt<AttendanceRepository>(),
      locationProvider: getIt<LocationProvider>(),
    ),
  );
  getIt.registerLazySingleton<ClockOutUseCase>(
    () => ClockOutUseCase(repository: getIt<AttendanceRepository>()),
  );
  getIt.registerLazySingleton<SubmitJustificationUseCase>(
    () => SubmitJustificationUseCase(repository: getIt<AttendanceRepository>()),
  );
}
