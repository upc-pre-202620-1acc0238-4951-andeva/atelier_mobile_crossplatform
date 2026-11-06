import 'package:drift/drift.dart';

@DataClassName('PartEntity')
@TableIndex(name: 'idx_parts_sku', columns: {#sku})
@TableIndex(name: 'idx_parts_category', columns: {#category})
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get category => text()();
  TextColumn get basePrice => text()();
  TextColumn get totalStock => text()();
  TextColumn get minimumStock => text()();
  TextColumn get unitOfMeasure => text()();
  TextColumn get status => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
