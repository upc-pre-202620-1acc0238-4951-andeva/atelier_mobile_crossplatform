// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bay_dao.dart';

// ignore_for_file: type=lint
mixin _$BayDaoMixin on DatabaseAccessor<AppDatabase> {
  $BaysTable get bays => attachedDatabase.bays;
  BayDaoManager get managers => BayDaoManager(this);
}

class BayDaoManager {
  final _$BayDaoMixin _db;
  BayDaoManager(this._db);
  $$BaysTableTableManager get bays =>
      $$BaysTableTableManager(_db.attachedDatabase, _db.bays);
}
