import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/local/bay_table.dart';
import 'package:drift/drift.dart';

part 'bay_dao.g.dart';

@DriftAccessor(tables: [Bays])
class BayDao extends DatabaseAccessor<AppDatabase> with _$BayDaoMixin {
  BayDao(super.attachedDatabase);

  Future<void> replaceBranch(
    String branchId,
    List<BaysCompanion> newBays,
  ) async {
    await transaction(() async {
      await (delete(bays)..where((t) => t.branchId.equals(branchId))).go();
      for (final bay in newBays) {
        await into(bays).insertOnConflictUpdate(bay);
      }
    });
  }

  Future<BayEntity?> findById(String id) {
    return (select(bays)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
