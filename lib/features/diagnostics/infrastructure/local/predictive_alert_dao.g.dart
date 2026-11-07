// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predictive_alert_dao.dart';

// ignore_for_file: type=lint
mixin _$PredictiveAlertDaoMixin on DatabaseAccessor<AppDatabase> {
  $PredictiveAlertsTable get predictiveAlerts =>
      attachedDatabase.predictiveAlerts;
  PredictiveAlertDaoManager get managers => PredictiveAlertDaoManager(this);
}

class PredictiveAlertDaoManager {
  final _$PredictiveAlertDaoMixin _db;
  PredictiveAlertDaoManager(this._db);
  $$PredictiveAlertsTableTableManager get predictiveAlerts =>
      $$PredictiveAlertsTableTableManager(
        _db.attachedDatabase,
        _db.predictiveAlerts,
      );
}
