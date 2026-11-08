// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher_dao.dart';

// ignore_for_file: type=lint
mixin _$VoucherDaoMixin on DatabaseAccessor<AppDatabase> {
  $VouchersTable get vouchers => attachedDatabase.vouchers;
  VoucherDaoManager get managers => VoucherDaoManager(this);
}

class VoucherDaoManager {
  final _$VoucherDaoMixin _db;
  VoucherDaoManager(this._db);
  $$VouchersTableTableManager get vouchers =>
      $$VouchersTableTableManager(_db.attachedDatabase, _db.vouchers);
}
