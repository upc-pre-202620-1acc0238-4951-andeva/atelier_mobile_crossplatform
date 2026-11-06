import 'package:drift/drift.dart';

@DataClassName('CustomerEntity')
@TableIndex(name: 'idx_customers_tax_id', columns: {#taxId})
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();  // INDIVIDUAL | COMPANY
  TextColumn get displayName => text()();
  TextColumn get taxId => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get status => text()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
