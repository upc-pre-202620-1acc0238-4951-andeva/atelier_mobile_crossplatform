import 'package:drift/drift.dart';

@DataClassName('BatchEntity')
@TableIndex(name: 'idx_batches_item_id', columns: {#itemId})
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get batchNumber => text()();
  TextColumn get remainingQty => text()();
  TextColumn get unitCost => text()();
  IntColumn get arrivalDate => integer()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
