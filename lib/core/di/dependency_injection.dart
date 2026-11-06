import 'dart:ui';

import 'package:atelier_mobile_crossplatform/core/config/app_config.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/cross_isolate_lock.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/local/session_store.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/authenticated_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/employee/employee_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/pdf_downloader.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/auth_refresh_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/session/device_token_api.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/token_refresher.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_maintenance_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/cache_metadata_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/local_change_notifier.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_queue.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_triggers.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/upload_file_handler.dart';
import 'package:atelier_mobile_crossplatform/core/media/photo_capture.dart';
import 'package:atelier_mobile_crossplatform/core/media/supabase_uploader.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/device_token_registrar.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_messaging_service.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

final getIt = GetIt.instance;

/// También corre en el worker. Todo es perezoso, así que allí no se crea nada que no se pida;
/// lo que dependa de la UI no debe construirse en un constructor.
void setupDependencies() {
  // En el worker no hay `context`.
  AppLocalizations strings() => lookupAppLocalizations(const Locale('es'));

  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  getIt.registerLazySingleton<SessionManager>(() => SessionManager());
  getIt.registerLazySingleton<SessionStore>(() => getIt<SessionManager>());
  getIt.registerLazySingleton<CrossIsolateLock>(
    () => CrossIsolateLock(database: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PendingOperationDao>(
    () => getIt<AppDatabase>().pendingOperationDao,
  );
  getIt.registerLazySingleton<PendingUploadDao>(
    () => getIt<AppDatabase>().pendingUploadDao,
  );
  getIt.registerLazySingleton<CacheMetadataDao>(
    () => getIt<AppDatabase>().cacheMetadataDao,
  );
  getIt.registerLazySingleton<CacheMaintenanceDao>(
    () => getIt<AppDatabase>().cacheMaintenanceDao,
  );

  // Sin sesión: refresh y Supabase. A Supabase no se le envía el JWT del backend.
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<TokenRefresher>(
    () => TokenRefresher(
      session: getIt<SessionStore>(),
      lock: getIt<CrossIsolateLock>(),
      refreshClient: getIt<http.Client>(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: AuthenticatedClient(
        inner: getIt<http.Client>(),
        session: getIt<SessionStore>(),
        refresher: getIt<TokenRefresher>(),
      ),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );
  getIt.registerLazySingleton<AuthRefreshApi>(
    () => AuthRefreshApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<DeviceTokenApi>(
    () => DeviceTokenApi(client: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EmployeeApi>(
    () => EmployeeApi(client: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<OperationHandlerRegistry>(
    () => OperationHandlerRegistry(),
  );
  getIt.registerLazySingleton<SyncScheduler>(() => SyncScheduler());
  getIt.registerLazySingleton<SyncProcessor>(
    () => SyncProcessor(
      dao: getIt<PendingOperationDao>(),
      session: getIt<SessionStore>(),
      lock: getIt<CrossIsolateLock>(),
      handlers: getIt<OperationHandlerRegistry>(),
      scheduler: getIt<SyncScheduler>(),
      maxAttemptsMessage: strings().syncFailedMaxAttempts,
      ensureFreshToken: getIt<TokenRefresher>().ensureFresh,
    ),
  );
  getIt.registerLazySingleton<PendingOperationQueue>(
    () => PendingOperationQueue(
      dao: getIt<PendingOperationDao>(),
      session: getIt<SessionManager>(),
      processor: getIt<SyncProcessor>(),
      scheduler: getIt<SyncScheduler>(),
    ),
  );

  getIt.registerLazySingleton<SupabaseUploader>(
    () => SupabaseUploader(
      client: getIt<http.Client>(),
      baseUrl: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      bucket: AppConfig.supabaseBucket,
      notConfiguredMessage: strings().errorStorageNotConfigured,
      uploadFailedMessage: strings().errorStorageUploadFailed,
    ),
  );
  getIt<OperationHandlerRegistry>().register(
    UploadFileHandler.type,
    () => UploadFileHandler(
      dao: getIt<PendingUploadDao>(),
      uploader: getIt<SupabaseUploader>(),
      supportDirectory: getApplicationSupportDirectory,
      missingPhotoMessage: strings().errorPendingPhotoMissing,
      uploadFailedMessage: strings().errorStorageUploadFailed,
    ),
  );
  getIt.registerLazySingleton<PhotoCapture>(
    () => PhotoCapture(
      uploader: getIt<SupabaseUploader>(),
      uploadDao: getIt<PendingUploadDao>(),
      queue: getIt<PendingOperationQueue>(),
      session: getIt<SessionManager>(),
      supportDirectory: getApplicationSupportDirectory,
    ),
  );
  getIt.registerLazySingleton<PdfDownloader>(
    () => const PdfDownloader(cacheDirectory: getTemporaryDirectory),
  );

  // Solo los pide la UI.
  getIt.registerLazySingleton<ConnectivityObserver>(
    () => ConnectivityObserver(
      changes: Connectivity().onConnectivityChanged,
      current: Connectivity().checkConnectivity,
    ),
  );
  getIt.registerLazySingleton<SyncTriggers>(
    () => SyncTriggers(
      connectivity: getIt<ConnectivityObserver>(),
      sync: getIt<SyncProcessor>().runDetached,
      refreshExternalChanges: () => LocalChangeNotifier.refresh(
        getIt<AppDatabase>(),
        getIt<SessionManager>(),
      ),
    ),
  );
  getIt.registerLazySingleton<PushInbox>(() => PushInbox());
  getIt.registerLazySingleton<DeviceTokenRegistrar>(
    () => DeviceTokenRegistrar(api: getIt<DeviceTokenApi>()),
  );
  getIt.registerLazySingleton<PushMessagingService>(
    () => PushMessagingService(
      inbox: getIt<PushInbox>(),
      registrar: getIt<DeviceTokenRegistrar>(),
      session: getIt<SessionManager>(),
      notifications: FlutterLocalNotificationsPlugin(),
      strings: strings(),
    ),
  );
}
