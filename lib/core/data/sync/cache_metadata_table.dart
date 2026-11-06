import 'package:drift/drift.dart';

@DataClassName('CacheMetadataEntity')
class CacheMetadata extends Table {
  TextColumn get scope => text()();
  IntColumn get lastSyncedAt => integer()();
  IntColumn get recordCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {scope};
}
