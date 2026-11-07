// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_dao.dart';

// ignore_for_file: type=lint
mixin _$PartDaoMixin on DatabaseAccessor<AppDatabase> {
  $PartsTable get parts => attachedDatabase.parts;
  PartDaoManager get managers => PartDaoManager(this);
}

class PartDaoManager {
  final _$PartDaoMixin _db;
  PartDaoManager(this._db);
  $$PartsTableTableManager get parts =>
      $$PartsTableTableManager(_db.attachedDatabase, _db.parts);
}
