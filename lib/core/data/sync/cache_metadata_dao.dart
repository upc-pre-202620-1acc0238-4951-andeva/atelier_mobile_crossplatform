import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_table.dart';
import 'package:drift/drift.dart';

part 'cache_metadata_dao.g.dart';

@DriftAccessor(tables: [CacheMetadata])
class CacheMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$CacheMetadataDaoMixin {
  CacheMetadataDao(super.attachedDatabase);

  Future<void> upsert(CacheMetadataCompanion metadata) {
    return into(cacheMetadata).insertOnConflictUpdate(metadata);
  }

  Future<CacheMetadataEntity?> get(String scope) {
    return (select(
      cacheMetadata,
    )..where((t) => t.scope.equals(scope))).getSingleOrNull();
  }
}
