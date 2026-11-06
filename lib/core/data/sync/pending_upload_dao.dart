import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_table.dart';
import 'package:drift/drift.dart';

part 'pending_upload_dao.g.dart';

@DriftAccessor(tables: [PendingUploads])
class PendingUploadDao extends DatabaseAccessor<AppDatabase>
    with _$PendingUploadDaoMixin {
  PendingUploadDao(super.attachedDatabase);

  Future<void> insert(PendingUploadsCompanion upload) {
    return into(pendingUploads).insertOnConflictUpdate(upload);
  }

  Future<PendingUploadEntity?> findById(String id) {
    return (select(
      pendingUploads,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteById(String id) {
    return (delete(pendingUploads)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<PendingUploadEntity>> watchByTarget(String target) {
    return (select(pendingUploads)..where((t) => t.target.equals(target)))
        .watch();
  }
}
