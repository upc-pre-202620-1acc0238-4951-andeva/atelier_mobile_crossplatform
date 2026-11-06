import 'dart:io';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Punto de entrada del worker: otro motor, otro `getIt`, otra conexión a Drift.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    setupDependencies();
    return runSyncTask();
  });
}

/// Corre la cola una vez y deja el motor limpio. Requiere `setupDependencies()`.
Future<bool> runSyncTask() async {
  try {
    // iOS corta a los ~30 s sin avisar (H42): se procesa lo que alcance en menos de eso.
    await getIt<SyncProcessor>().run(
      budget: Platform.isIOS ? const Duration(seconds: 25) : null,
    );
    return true;
  } on Exception catch (e) {
    debugPrint('Sync falló: $e');
    return false;
  } finally {
    LocalChangeNotifier.notifyUi();
    await getIt<AppDatabase>().close(); // Si no, el motor deja el archivo abierto.
    await getIt.reset();
  }
}
