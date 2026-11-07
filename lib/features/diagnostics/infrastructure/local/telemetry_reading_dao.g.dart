// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_reading_dao.dart';

// ignore_for_file: type=lint
mixin _$TelemetryReadingDaoMixin on DatabaseAccessor<AppDatabase> {
  $TelemetryReadingsTable get telemetryReadings =>
      attachedDatabase.telemetryReadings;
  $PendingOperationsTable get pendingOperations =>
      attachedDatabase.pendingOperations;
  TelemetryReadingDaoManager get managers => TelemetryReadingDaoManager(this);
}

class TelemetryReadingDaoManager {
  final _$TelemetryReadingDaoMixin _db;
  TelemetryReadingDaoManager(this._db);
  $$TelemetryReadingsTableTableManager get telemetryReadings =>
      $$TelemetryReadingsTableTableManager(
        _db.attachedDatabase,
        _db.telemetryReadings,
      );
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(
        _db.attachedDatabase,
        _db.pendingOperations,
      );
}
