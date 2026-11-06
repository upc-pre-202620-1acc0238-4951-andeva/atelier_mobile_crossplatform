// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_upload_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingUploadDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingUploadsTable get pendingUploads => attachedDatabase.pendingUploads;
  PendingUploadDaoManager get managers => PendingUploadDaoManager(this);
}

class PendingUploadDaoManager {
  final _$PendingUploadDaoMixin _db;
  PendingUploadDaoManager(this._db);
  $$PendingUploadsTableTableManager get pendingUploads =>
      $$PendingUploadsTableTableManager(
        _db.attachedDatabase,
        _db.pendingUploads,
      );
}
