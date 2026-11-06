// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_metadata_dao.dart';

// ignore_for_file: type=lint
mixin _$CacheMetadataDaoMixin on DatabaseAccessor<AppDatabase> {
  $CacheMetadataTable get cacheMetadata => attachedDatabase.cacheMetadata;
  CacheMetadataDaoManager get managers => CacheMetadataDaoManager(this);
}

class CacheMetadataDaoManager {
  final _$CacheMetadataDaoMixin _db;
  CacheMetadataDaoManager(this._db);
  $$CacheMetadataTableTableManager get cacheMetadata =>
      $$CacheMetadataTableTableManager(_db.attachedDatabase, _db.cacheMetadata);
}
