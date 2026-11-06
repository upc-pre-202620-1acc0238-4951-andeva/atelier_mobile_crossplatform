import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/infrastructure/local/branch_table.dart';
import 'package:drift/drift.dart';

part 'branch_dao.g.dart';

@DriftAccessor(tables: [Branches])
class BranchDao extends DatabaseAccessor<AppDatabase> with _$BranchDaoMixin {
  BranchDao(super.attachedDatabase);

  Future<void> replaceAll(List<BranchEntity> rows) {
    return transaction(() async {
      await delete(branches).go();
      await batch((b) => b.insertAll(branches, rows));
    });
  }

  Future<BranchEntity?> findById(String id) {
    return (select(
      branches,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<BranchEntity?> watchById(String id) {
    return (select(
      branches,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }
}
