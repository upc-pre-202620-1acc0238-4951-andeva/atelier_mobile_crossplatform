import 'package:atelier_mobile_crossplatform/core/data/combine_latest.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/domain/api_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_repository.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc_catalog.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/telemetry.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/diagnostics_dedupe_keys.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/diagnostics_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/telemetry_reading_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/register_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/resolve_fault_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/sync/telemetry_batch_handler.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Instalación del escáner en línea; lecturas y fallas capturadas sin red y enviadas por la cola (06 §6,
/// "US16–US19 — OBD-II en foso"); fallas activas y alertas offline-first.
class DiagnosticsRepositoryImpl implements DiagnosticsRepository {
  /// Lecturas por `TELEMETRY_BATCH` (04 §4).
  static const batchSize = 200;
  static const _readingsRetention = Duration(days: 7);

  final IotApi api;
  final TelemetryReadingDao readingDao;
  final VehicleFaultDao faultDao;
  final PredictiveAlertDao alertDao;
  final PendingOperationDao pendingOperationDao;
  final PendingOperationQueue queue;
  final SessionManager session;
  final DateTime Function() now;

  const DiagnosticsRepositoryImpl({
    required this.api,
    required this.readingDao,
    required this.faultDao,
    required this.alertDao,
    required this.pendingOperationDao,
    required this.queue,
    required this.session,
    this.now = DateTime.now,
  });

  int get _nowMillis => now().millisecondsSinceEpoch;

  @override
  Future<List<ObdDevice>> getDevices({DeviceStatus? status}) async {
    final devices = await api.getDevices(status: status?.value);
    return devices.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<DeviceInstallation?> getActiveInstallation(String vehicleId) async {
    try {
      return (await api.getActiveInstallation(vehicleId)).toDomain();
    } on ApiException catch (e) {
      if (e.httpStatus == 404) return null;
      rethrow;
    }
  }

  @override
  Future<DeviceInstallation> installDevice({
    required String deviceId,
    required String vehicleId,
    int? currentOdometerKm,
  }) async {
    final dto = await api.install(
      deviceId: deviceId,
      vehicleId: vehicleId,
      currentOdometerKm: currentOdometerKm,
    );
    return dto.toDomain();
  }

  @override
  Future<DeviceInstallation> uninstallDevice(
    String installationId, {
    int? finalOdometerKm,
  }) async {
    final dto = await api.uninstall(
      installationId,
      finalOdometerKm: finalOdometerKm,
    );
    return dto.toDomain();
  }

  @override
  Future<bool> saveReading(
    String vehicleId,
    TelemetrySample sample, {
    double? latitude,
    double? longitude,
  }) async {
    final engineTemp = sample.engineTempCelsius;
    if (engineTemp == null) return false;
    return readingDao.insertReading(
      TelemetryReadingsCompanion.insert(
        id: const Uuid().v4(),
        vehicleId: vehicleId,
        timestamp: sample.timestamp.millisecondsSinceEpoch,
        engineTempCelsius: engineTemp,
        engineRpm: Value(sample.engineRpm),
        speedKmh: Value(sample.speedKmh),
        batteryVoltage: Value(sample.batteryVoltage),
        fuelPercentage: Value(sample.fuelPercentage),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
  }

  /// Si el lote ya estaba en cola (se cortó entre encolar y marcar las filas) se reutiliza su operación por la
  /// `dedupe_key`, así ninguna lectura queda sin lote ni viaja dos veces.
  @override
  Future<int> enqueueUnbatchedReadings({required bool onlyFull}) async {
    if (await session.getSession() == null) return 0;
    var batches = 0;
    for (final vehicleId in await readingDao.vehiclesWithUnbatched()) {
      while (true) {
        final rows = await readingDao.unbatched(vehicleId, batchSize);
        if (rows.isEmpty || (onlyFull && rows.length < batchSize)) break;
        final dedupeKey = DiagnosticsDedupeKeys.telemetryBatch(
          vehicleId,
          rows.first.timestamp,
          rows.last.timestamp,
        );
        final body = TelemetryBatchRequestDto(
          vehicleId: vehicleId,
          readings: [for (final row in rows) row.toItemDto()],
        );
        final operationId =
            await queue.enqueue(
              type: TelemetryBatchHandler.type,
              payload: body.toJson(),
              dedupeKey: dedupeKey,
            ) ??
            (await pendingOperationDao.findByDedupeKey(dedupeKey))?.id;
        if (operationId == null) break;
        await readingDao.assignBatch([
          for (final row in rows) row.id,
        ], operationId);
        batches++;
      }
    }
    return batches;
  }

  @override
  Future<void> purgeConfirmedReadings() async {
    await readingDao.purgeConfirmed(
      now().subtract(_readingsRetention).millisecondsSinceEpoch,
    );
  }

  @override
  Stream<DiagnosticsSyncState> watchSyncState(String vehicleId) {
    return combineLatest2(
      readingDao.watchPendingCount(vehicleId),
      faultDao.watchPendingCount(vehicleId),
      (readings, faults) => DiagnosticsSyncState(
        pendingReadings: readings,
        pendingFaults: faults,
      ),
    );
  }

  /// Las fallas con un `RESOLVE_FAULT` en cola siguen activas en el backend, pero en la app ya están borradas.
  @override
  Future<void> refreshActiveFaults(String vehicleId) async {
    final current = await session.getSession();
    if (current == null || !current.has(Permission.faultsRead)) return;
    final millis = _nowMillis;
    final dtos = await api.getActiveFaults(vehicleId);
    final operations = await pendingOperationDao
        .watchByTypeAndDedupePrefix(
          ResolveFaultHandler.type,
          DiagnosticsDedupeKeys.resolveFaultPrefix,
        )
        .first;
    final resolving = {
      for (final operation in operations)
        operation.dedupeKey.substring(
          DiagnosticsDedupeKeys.resolveFaultPrefix.length,
        ),
    };
    await faultDao.replaceRemote(vehicleId, [
      for (final dto in dtos)
        resolving.contains(dto.id)
            ? dto
                  .toEntity(vehicleId, millis)
                  .copyWith(isResolved: true, resolvedAt: Value(millis))
            : dto.toEntity(vehicleId, millis),
    ]);
  }

  @override
  Stream<List<VehicleFault>> watchActiveFaults(String vehicleId) {
    return faultDao
        .watchActive(vehicleId)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<List<VehicleFault>> registerDetectedFaults(
    String vehicleId,
    List<Dtc> dtcs,
    String sessionId,
  ) async {
    final active = await faultDao.findActive(vehicleId);
    return [
      for (final dtc in dtcs.toSet())
        _activeWith(active, dtc)?.toDomain() ??
            await _queueFault(vehicleId, dtc, sessionId),
    ];
  }

  VehicleFaultEntity? _activeWith(List<VehicleFaultEntity> active, Dtc dtc) {
    for (final fault in active) {
      if (fault.dtcCode == dtc.code) return fault;
    }
    return null;
  }

  /// La fila local se guarda antes de encolar: el worker puede enviar el registro de inmediato y debe
  /// encontrarla para reemplazarla por la del backend.
  Future<VehicleFault> _queueFault(
    String vehicleId,
    Dtc dtc,
    String sessionId,
  ) async {
    final entry = DtcCatalog.describe(dtc);
    final operationId = const Uuid().v4();
    final local = VehicleFaultEntity(
      id: '${VehicleFault.localPrefix}$operationId',
      vehicleId: vehicleId,
      dtcCode: dtc.code,
      severity: entry.severity.value,
      description: entry.description,
      detectedAt: _nowMillis,
      isResolved: false,
    );
    await faultDao.upsert(local);
    final dedupeKey = DiagnosticsDedupeKeys.registerFault(
      vehicleId,
      dtc.code,
      sessionId,
    );
    final queued = await queue.enqueue(
      type: RegisterFaultHandler.type,
      payload: RegisterFaultRequestDto(
        vehicleId: vehicleId,
        dtcCode: dtc.code,
        severity: entry.severity.value,
        description: entry.description,
      ).toJson(),
      dedupeKey: dedupeKey,
      id: operationId,
    );
    if (queued != null) return local.toDomain();

    // Ya estaba en cola en esta sesión: se devuelve esa falla.
    await faultDao.deleteById(local.id);
    final existing = await pendingOperationDao.findByDedupeKey(dedupeKey);
    if (existing == null) return local.toDomain();
    final row = await faultDao.findById(
      '${VehicleFault.localPrefix}${existing.id}',
    );
    return (row ?? local).toDomain();
  }

  @override
  Future<ClearFaultsResult> applyClearedFaults(
    String vehicleId,
    List<Dtc> remaining,
    String sessionId,
  ) async {
    final remainingCodes = {for (final dtc in remaining) dtc.code};
    final moment = now();
    final cleared = <VehicleFault>[];
    for (final fault in await faultDao.findActive(vehicleId)) {
      if (remainingCodes.contains(fault.dtcCode)) continue;
      if (VehicleFault.isLocalId(fault.id)) {
        await _discardLocal(fault);
      } else {
        await _queueResolve(fault);
      }
      cleared.add(fault.toDomain().resolvedOn(moment.toUtc()));
    }
    return ClearFaultsResult(
      cleared: cleared,
      persistent: await registerDetectedFaults(
        vehicleId,
        remaining,
        sessionId,
      ),
    );
  }

  /// Una falla que nunca llegó al backend se descarta junto con su `REGISTER_FAULT` (06 §6). Si ese registro ya
  /// se está enviando, se resuelve después de él. En una sola sentencia: el worker es otra conexión (06 §3).
  Future<void> _discardLocal(VehicleFaultEntity fault) async {
    final operationId = fault.id.substring(VehicleFault.localPrefix.length);
    final discarded = await pendingOperationDao.discardUnlessSyncing([
      operationId,
    ]);
    if (discarded ||
        await pendingOperationDao.findById(operationId) == null) {
      await faultDao.deleteById(fault.id);
    } else {
      await _queueResolve(fault, dependsOn: operationId);
    }
  }

  Future<void> _queueResolve(
    VehicleFaultEntity fault, {
    String? dependsOn,
  }) async {
    await faultDao.markResolved(fault.id, _nowMillis);
    await queue.enqueue(
      type: ResolveFaultHandler.type,
      payload: ResolveFaultPayload(
        faultId: fault.id,
        vehicleId: fault.vehicleId,
        dtcCode: fault.dtcCode,
      ).toJson(),
      dedupeKey: DiagnosticsDedupeKeys.resolveFault(fault.id),
      dependsOn: dependsOn,
    );
  }

  @override
  Future<void> refreshPredictiveAlerts(String vehicleId) async {
    final current = await session.getSession();
    if (current == null || !current.has(Permission.predictiveAlertsRead)) {
      return;
    }
    final millis = _nowMillis;
    final dtos = await api.getVehicleAlerts(vehicleId);
    await alertDao.replaceForVehicle(vehicleId, [
      for (final dto in dtos) dto.toEntity(vehicleId, millis),
    ]);
  }

  @override
  Stream<List<PredictiveAlert>> watchPredictiveAlerts(String vehicleId) {
    return alertDao
        .watchForVehicle(vehicleId)
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  @override
  Future<PredictiveAlert> acknowledgePredictiveAlert(String id) async {
    final dto = await api.acknowledgeAlert(id);
    final vehicleId = dto.vehicleId ?? '';
    if (vehicleId.isNotEmpty) {
      await alertDao.upsert(dto.toEntity(vehicleId, _nowMillis));
    }
    return dto.toDomain(vehicleId);
  }
}
