import 'package:drift/drift.dart';

@DataClassName('PendingOperationEntity')
@TableIndex(name: 'idx_pending_operations_dedupe_key', columns: {#dedupeKey}, unique: true)
@TableIndex(name: 'idx_pending_operations_status_next_attempt_at', columns: {#status, #nextAttemptAt})
@TableIndex(name: 'idx_pending_operations_user_id', columns: {#userId})
class PendingOperations extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get payload => text()();
  TextColumn get dedupeKey => text()();
  TextColumn get userId => text()();
  TextColumn get tenantId => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttemptAt => integer()();
  IntColumn get lastHttpStatus => integer().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get lastErrorMessage => text().nullable()();
  IntColumn get createdAt => integer()();
  TextColumn get dependsOn => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
