import 'package:drift/drift.dart';

@DataClassName('VoucherEntity')
@TableIndex(name: 'idx_vouchers_work_order_id', columns: {#workOrderId})
class Vouchers extends Table {
  TextColumn get id => text()();
  TextColumn get workOrderId => text().nullable()();
  TextColumn get voucherType => text()();  // 01 FACTURA | 03 BOLETA | 07 NOTA_CREDITO
  TextColumn get serie => text()();
  IntColumn get number => integer()();
  TextColumn get totalAmount => text()();
  TextColumn get paidAmount => text()();
  TextColumn get pendingBalance => text()();
  TextColumn get paymentStatus => text()();  // PENDING | PARTIAL | PAID
  TextColumn get status => text()();  // DRAFT | ISSUED | ACCEPTED_SUNAT | REJECTED_SUNAT | VOIDED
  TextColumn get pdfUrl => text().nullable()();
  IntColumn get syncedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
