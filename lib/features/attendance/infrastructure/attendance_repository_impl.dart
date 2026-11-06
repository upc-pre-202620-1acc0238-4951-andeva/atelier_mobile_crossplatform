import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/branch/branch_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/branch.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_cache.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_dedupe_keys.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/attendance_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/attendance_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/shift_dao.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_api.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/attendance_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_in_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/clock_out_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/remote/justify_attendance_request_dto.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_in_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/clock_out_handler.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/sync/justification_handler.dart';
import 'package:drift/drift.dart' show Value;

/// Offline-first (docs/06-offline-sync.md §4 y §6): la UI observa Drift; las marcaciones y descargos
/// van directo con red y a la cola `pending_operations` sin ella.
class AttendanceRepositoryImpl implements AttendanceRepository {
  static const historyDays = 30;
  static const scopeBranches = 'branches';
  static const referenceTtl = Duration(hours: 24);

  final AttendanceApi api;
  final BranchApi branchApi;
  final EmployeeApi employeeApi;
  final AttendanceDao attendanceDao;
  final ShiftDao shiftDao;
  final BranchDao branchDao;
  final CacheMetadataDao cacheMetadataDao;
  final PendingOperationDao pendingOperationDao;
  final PendingOperationQueue queue;
  final AttendanceCache cache;
  final SessionManager session;
  final ConnectivityObserver connectivity;
  final DateTime Function() now;

  const AttendanceRepositoryImpl({
    required this.api,
    required this.branchApi,
    required this.employeeApi,
    required this.attendanceDao,
    required this.shiftDao,
    required this.branchDao,
    required this.cacheMetadataDao,
    required this.pendingOperationDao,
    required this.queue,
    required this.cache,
    required this.session,
    required this.connectivity,
    this.now = DateTime.now,
  });

  static String shiftScope(String shiftId) => 'shifts:$shiftId';

  String _today() => BusinessTime.limaDate(now());

  @override
  Stream<TodayAttendance> watchToday() {
    return session.switchOn<(String, String)?, TodayAttendance>(
      (current) {
        final membershipId = current?.membershipId;
        return current == null || membershipId == null
            ? null
            : (current.userId, membershipId);
      },
      (key) {
        if (key == null) return Stream.value(const NotClockedIn());
        final (userId, membershipId) = key;
        return _combine(
          attendanceDao.watchLatest(membershipId),
          pendingOperationDao.watchForUser(userId),
          (latest, operations) {
            // El día se calcula aquí: la pantalla puede seguir abierta tras la medianoche.
            final today = _today();
            return todayOf(
              latest?.toDomain(),
              queuedClockInOf(operations, membershipId, today),
              _withKey(
                operations,
                AttendanceDedupeKeys.clockOut(membershipId, today),
              ),
              today,
            );
          },
        );
      },
    );
  }

  @override
  Stream<List<Attendance>> watchHistory() {
    return session.switchOn<String?, List<Attendance>>(
      (current) => current?.membershipId,
      (membershipId) {
        if (membershipId == null) return Stream.value(const []);
        final from = BusinessTime.startOfDay(
          BusinessTime.addDays(_today(), -historyDays),
        ).millisecondsSinceEpoch;
        return attendanceDao
            .watchSince(membershipId, from)
            .map((rows) => rows.map((row) => row.toDomain()).toList());
      },
    );
  }

  @override
  Stream<WeeklySchedule?> watchSchedule() {
    return session.switchOn<(String?, String?), WeeklySchedule?>(
      (current) => (current?.branchId, current?.shiftId),
      (key) {
        final (branchId, shiftId) = key;
        if (shiftId == null) return Stream.value(null);
        return _combine(
          shiftDao.watchById(shiftId),
          branchId == null
              ? Stream<BranchEntity?>.value(null)
              : branchDao.watchById(branchId),
          (shift, branch) => shift == null
              ? null
              : WeeklySchedule(
                  branchId: branchId,
                  shiftId: shiftId,
                  shift: shift.toDomain(),
                  branch: branch?.toDomain(),
                ),
        );
      },
    );
  }

  @override
  Future<void> refresh() async {
    final started = await session.getSession();
    final membershipId = started?.membershipId;
    if (started == null || membershipId == null) {
      throw const MissingAssignmentException();
    }

    // Sede y turno pueden haber cambiado, o el login fue sin red.
    if (started.has(Permission.attendanceReadOwn)) {
      await _refreshAssignment(membershipId);
    }
    final current = await session.getSession() ?? started;

    if (current.has(Permission.branchesRead)) await _refreshBranches();
    final shiftId = current.shiftId;
    if (shiftId != null && current.has(Permission.shiftsRead)) {
      await _refreshShift(shiftId);
    }
    if (!current.has(Permission.attendanceReadOwn)) return;

    try {
      final today = _today();
      await cache.refreshRange(
        membershipId,
        BusinessTime.addDays(today, -historyDays),
        today,
      );
      await _refreshActive(membershipId);
    } on NetworkException {
      // Sin red: la UI sigue con la caché.
    }
  }

  /// La jornada activa puede haber empezado antes del rango. H2: solo el 404 es "sin jornada"; un
  /// 401, 403 o 5xx no debe mostrarse como tal.
  Future<void> _refreshActive(String membershipId) async {
    try {
      final active = await api.statusToday(membershipId);
      if (active != null) await cache.save(active, membershipId);
    } on ApiException catch (e) {
      if (e.httpStatus != 404) rethrow;
    }
  }

  @override
  Future<Branch?> findBranch(String branchId) async {
    return (await branchDao.findById(branchId))?.toDomain();
  }

  @override
  Future<SubmitOutcome> clockIn(
    String branchId,
    String shiftId,
    DeviceLocation location,
  ) async {
    final membershipId = await _membershipId();
    final capturedAt = now().toUtc();
    final body = ClockInRequestDto(
      branchId: branchId,
      shiftId: shiftId,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return _submit(
      membershipId: membershipId,
      online: () => api.clockIn(body),
      type: ClockInHandler.type,
      payload: ClockInRequestDto(
        branchId: branchId,
        shiftId: shiftId,
        latitude: location.latitude,
        longitude: location.longitude,
        clockInTime: capturedAt.toIso8601String(),
      ),
      dedupeKey: AttendanceDedupeKeys.clockIn(
        membershipId,
        BusinessTime.limaDate(capturedAt),
      ),
    );
  }

  @override
  Future<SubmitOutcome> clockOut() async {
    final current = await session.getSession();
    final membershipId = current?.membershipId;
    if (current == null || membershipId == null) {
      throw const MissingAssignmentException();
    }
    final capturedAt = now().toUtc();
    final today = BusinessTime.limaDate(capturedAt);
    final openId = (await attendanceDao.findOpen(membershipId))?.id;

    final queued = queuedClockInOf(
      await pendingOperationDao.findForUserByType(
        current.userId,
        ClockInHandler.type,
      ),
      membershipId,
      today,
    );
    // Un ingreso FAILED no impide cerrar una jornada que sí está abierta.
    final waitsFor = queued?.status == 'FAILED' && openId != null
        ? null
        : queued?.id;

    return _submit(
      membershipId: membershipId,
      online: () => api.clockOut(ClockOutRequestDto(attendanceId: openId)),
      type: ClockOutHandler.type,
      payload: ClockOutRequestDto(
        attendanceId: openId,
        clockOutTime: capturedAt.toIso8601String(),
      ),
      dedupeKey: AttendanceDedupeKeys.clockOut(membershipId, today),
      dependsOn: waitsFor,
    );
  }

  @override
  Future<SubmitOutcome> submitJustification(
    AttendanceId id,
    String reason,
  ) async {
    final membershipId = await _membershipId();
    final trimmed = reason.trim();
    return _submit(
      membershipId: membershipId,
      online: () => api.submitJustification(
        id.value,
        JustifyAttendanceRequestDto(reason: trimmed),
      ),
      type: JustificationHandler.type,
      payload: {'attendanceId': id.value, 'reason': trimmed},
      dedupeKey: AttendanceDedupeKeys.justification(id.value),
    );
  }

  /// Con red se envía directo y un error de negocio sube con el `message` del backend. Sin red, o si
  /// la llamada se corta, se encola: el reintento es seguro por la tabla de 06 §3.
  Future<SubmitOutcome> _submit({
    required String membershipId,
    required Future<AttendanceDto> Function() online,
    required String type,
    required Object payload,
    required String dedupeKey,
    String? dependsOn,
  }) async {
    if (dependsOn == null && connectivity.isOnline) {
      try {
        final saved = await cache.save(await online(), membershipId);
        if (saved == null) {
          throw const FormatException('AttendanceResource sin clockIn');
        }
        return Recorded(saved.toDomain());
      } on NetworkException {
        // Pudo haber llegado: `CLOCK_*` tolera el reintento.
      }
    }
    final id = await queue.enqueue(
      type: type,
      payload: payload,
      dedupeKey: dedupeKey,
      dependsOn: dependsOn,
    );
    return id == null ? const AlreadyQueued() : const Queued();
  }

  Future<String> _membershipId() async {
    final membershipId = (await session.getSession())?.membershipId;
    if (membershipId == null) throw const MissingAssignmentException();
    return membershipId;
  }

  Future<void> _refreshAssignment(String membershipId) async {
    try {
      final profile = await employeeApi.getByMembership(membershipId);
      await session.updateAssignment(profile.branchId, profile.assignedShiftId);
    } on NetworkException {
      // Conserva lo guardado.
    } on ApiException catch (e) {
      // Sin perfil laboral no hay sede ni turno. Otros errores conservan lo guardado.
      if (e.httpStatus == 404) await session.updateAssignment(null, null);
    }
  }

  Future<void> _refreshBranches() async {
    if (!await _isStale(scopeBranches)) return;
    try {
      final millis = now().millisecondsSinceEpoch;
      final dtos = await branchApi.getAll();
      final rows = dtos.map((dto) => dto.toEntity(millis)).nonNulls.toList();
      await branchDao.replaceAll(rows);
      await _markSynced(scopeBranches, millis, rows.length);
    } on NetworkException {
      // Sigue la caché.
    } on ApiException {
      // Solo es referencia: no impide leer la asistencia.
    }
  }

  Future<void> _refreshShift(String shiftId) async {
    final scope = shiftScope(shiftId);
    if (!await _isStale(scope)) return;
    try {
      final millis = now().millisecondsSinceEpoch;
      final dto = await api.getWorkShift(shiftId);
      await shiftDao.upsert(dto.toEntity(millis));
      await _markSynced(scope, millis, 1);
    } on NetworkException {
      // Sigue la caché.
    } on ApiException {
      // Solo es referencia: no impide leer la asistencia.
    }
  }

  Future<bool> _isStale(String scope) async {
    final metadata = await cacheMetadataDao.get(scope);
    if (metadata == null) return true;
    final age = now().millisecondsSinceEpoch - metadata.lastSyncedAt;
    return age >= referenceTtl.inMilliseconds;
  }

  Future<void> _markSynced(String scope, int millis, int count) {
    return cacheMetadataDao.upsert(
      CacheMetadataCompanion(
        scope: Value(scope),
        lastSyncedAt: Value(millis),
        recordCount: Value(count),
      ),
    );
  }

  /// La cola manda sobre la caché: lo encolado es más nuevo que lo último que vino del backend.
  static TodayAttendance todayOf(
    Attendance? latest,
    PendingOperationEntity? queuedClockIn,
    PendingOperationEntity? queuedClockOut,
    String today,
  ) {
    final open = latest != null && latest.isOpen ? latest : null;
    if (queuedClockOut != null) {
      return ClockOutQueued(open, _utc(queuedClockOut.createdAt));
    }
    if (open != null) return ClockedIn(open);
    if (queuedClockIn != null) {
      return ClockInQueued(_utc(queuedClockIn.createdAt));
    }
    if (latest != null && BusinessTime.limaDate(latest.clockIn) == today) {
      return Completed(latest);
    }
    return const NotClockedIn();
  }

  /// El de hoy en cualquier estado o, si no hay, el más reciente de otro día que aún se va a enviar:
  /// una salida de madrugada espera al ingreso de anoche, y un FAILED olvidado no estorba.
  static PendingOperationEntity? queuedClockInOf(
    List<PendingOperationEntity> operations,
    String membershipId,
    String today,
  ) {
    final todayKey = AttendanceDedupeKeys.clockIn(membershipId, today);
    final prefix = AttendanceDedupeKeys.clockIn(membershipId, '');
    PendingOperationEntity? older;
    for (final operation in operations) {
      if (operation.dedupeKey == todayKey) return operation;
      if (!operation.dedupeKey.startsWith(prefix)) continue;
      if (operation.status == 'FAILED') continue;
      if (older == null || operation.createdAt > older.createdAt) {
        older = operation;
      }
    }
    return older;
  }

  static PendingOperationEntity? _withKey(
    List<PendingOperationEntity> operations,
    String key,
  ) {
    for (final operation in operations) {
      if (operation.dedupeKey == key) return operation;
    }
    return null;
  }

  static DateTime _utc(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  /// Emite cuando cualquiera cambia, una vez que ambos tienen valor. Sin `rxdart` (05 §2).
  static Stream<R> _combine<A, B, R>(
    Stream<A> first,
    Stream<B> second,
    R Function(A, B) combine,
  ) {
    return Stream.multi((controller) {
      late A a;
      late B b;
      var hasA = false;
      var hasB = false;
      void emit() {
        if (hasA && hasB) controller.add(combine(a, b));
      }

      final subscriptions = [
        first.listen((value) {
          a = value;
          hasA = true;
          emit();
        }, onError: controller.addError),
        second.listen((value) {
          b = value;
          hasB = true;
          emit();
        }, onError: controller.addError),
      ];
      controller.onCancel = () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      };
    });
  }
}
