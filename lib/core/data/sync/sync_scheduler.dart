import 'package:workmanager/workmanager.dart';

/// Trabajo en segundo plano. Solo es una mejora: en iOS puede tardar horas o no ocurrir (H42).
class SyncScheduler {
  static const uniqueName = 'atelier-sync';
  static const retryName = 'atelier-sync-retry';

  /// En iOS es el id de BGTaskScheduler: debe estar en `BGTaskSchedulerPermittedIdentifiers`
  /// y registrarse en `AppDelegate.swift`.
  static const periodicName = taskName;
  static const taskName = 'atelier.sync';

  final Workmanager workmanager;

  SyncScheduler({Workmanager? workmanager})
    : workmanager = workmanager ?? Workmanager();

  Future<void> requestSync() {
    return workmanager.registerOneOffTask(
      uniqueName,
      taskName,
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  /// Reintento tras el backoff. Usa otro nombre para no bloquear un envío inmediato con `keep`.
  Future<void> requestSyncAt(int epochMillis, [DateTime? now]) {
    final millis = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return workmanager.registerOneOffTask(
      retryName,
      taskName,
      initialDelay: Duration(
        milliseconds: (epochMillis - millis).clamp(0, 1 << 62),
      ),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  Future<void> schedulePeriodic() {
    return workmanager.registerPeriodicTask(
      periodicName,
      taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
