import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/predictive_alert_table.dart';
import 'package:drift/drift.dart';

part 'predictive_alert_dao.g.dart';

/// Caché `predictive_alerts` (06 §4, por vehículo · al abrir).
@DriftAccessor(tables: [PredictiveAlerts])
class PredictiveAlertDao extends DatabaseAccessor<AppDatabase>
    with _$PredictiveAlertDaoMixin {
  PredictiveAlertDao(super.attachedDatabase);

  Future<void> upsert(PredictiveAlertEntity alert) {
    return into(predictiveAlerts).insertOnConflictUpdate(alert);
  }

  Future<void> replaceForVehicle(
    String vehicleId,
    List<PredictiveAlertEntity> alerts,
  ) {
    return transaction(() async {
      await (delete(
        predictiveAlerts,
      )..where((t) => t.vehicleId.equals(vehicleId))).go();
      await batch((b) => b.insertAllOnConflictUpdate(predictiveAlerts, alerts));
    });
  }

  Stream<List<PredictiveAlertEntity>> watchForVehicle(String vehicleId) {
    return (select(predictiveAlerts)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }
}
