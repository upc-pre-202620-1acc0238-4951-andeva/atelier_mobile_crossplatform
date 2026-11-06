import 'dart:async';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_triggers.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_worker.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_messaging_service.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  final session = getIt<SessionManager>();
  await _bestEffort('Limpieza tras reinstalar', session.clearIfReinstalled);

  // Antes de programar el worker: así la migración no compite con él por el archivo.
  final database = getIt<AppDatabase>();
  await database.customSelect('SELECT 1').get();

  // Sin `google-services.json` esto falla, y la app debe abrir igual, como la nativa.
  await _bestEffort('Firebase', Firebase.initializeApp);
  await _bestEffort('Push', getIt<PushMessagingService>().start);
  await _bestEffort('Worker', () async {
    await Workmanager().initialize(callbackDispatcher);
    await getIt<SyncScheduler>().schedulePeriodic();
  });
  LocalChangeNotifier.listenInUi(
    database,
    session,
    sync: getIt<SyncProcessor>().runDetached,
  );
  await _bestEffort('Disparadores', getIt<SyncTriggers>().start);

  runApp(MainApp(session: session));
}

/// Nada de esto debe impedir abrir la app: lo capturado sin red sigue guardado en la cola.
Future<void> _bestEffort(String step, Future<void> Function() run) async {
  try {
    await run();
  } on Exception catch (e) {
    log('$step no arrancó: $e', name: 'main');
  }
}

class MainApp extends StatelessWidget {
  final SessionManager session;

  const MainApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: AppRoot(session: session),
    );
  }
}
