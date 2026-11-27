import 'dart:async';
import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/auth_deep_link_source.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/navigation/presentation_setup.dart';
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
  await _bestEffort(
    'Enlaces de autenticación',
    AuthDeepLinkSource(inbox: getIt<AuthDeepLinkInbox>()).start,
  );

  setupPresentation();

  runApp(
    MainApp(
      session: session,
      pushInbox: getIt<PushInbox>(),
      authDeepLinks: getIt<AuthDeepLinkInbox>(),
    ),
  );
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
  final PushInbox? pushInbox;
  final AuthDeepLinkInbox? authDeepLinks;

  const MainApp({super.key, required this.session, this.pushInbox, this.authDeepLinks});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      // Claro y oscuro son esquemas completos; sin color dinámico, la paleta de marca es fija.
      theme: AtelierTheme.light,
      darkTheme: AtelierTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) => AtelierSystemUiScope(child: child ?? const SizedBox.shrink()),
      home: AppRoot(session: session, pushInbox: pushInbox, authDeepLinks: authDeepLinks),
    );
  }
}
