import 'dart:developer';

import 'package:atelier_mobile_crossplatform/core/data/local/session_manager.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_operation_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/pending_upload_dao.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_processor.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/sync_scheduler.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/notifications/push_inbox.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/consume_push_destination_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/discard_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operations_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_destination_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/retry_pending_operation_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/push_destination_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/session_repository.dart';
import 'package:atelier_mobile_crossplatform/features/main/infrastructure/pending_operation_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/main/infrastructure/push_destination_repository_impl.dart';
import 'package:atelier_mobile_crossplatform/features/main/infrastructure/session_repository_impl.dart';
import 'package:path_provider/path_provider.dart';

void setupMainDependencies() {
  getIt.registerLazySingleton<PendingOperationRepository>(
    () => PendingOperationRepositoryImpl(
      dao: getIt<PendingOperationDao>(),
      uploadDao: getIt<PendingUploadDao>(),
      session: getIt<SessionManager>(),
      supportDirectory: getApplicationSupportDirectory,
      requestSync: _requestSync,
    ),
  );
  getIt.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(session: getIt<SessionManager>()),
  );
  getIt.registerLazySingleton<PushDestinationRepository>(
    () => PushDestinationRepositoryImpl(inbox: getIt<PushInbox>()),
  );

  getIt.registerLazySingleton<ObserveSessionUseCase>(
    () => ObserveSessionUseCase(repository: getIt<SessionRepository>()),
  );
  getIt.registerLazySingleton<ObservePendingOperationCountUseCase>(
    () => ObservePendingOperationCountUseCase(
      repository: getIt<PendingOperationRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObservePendingOperationsUseCase>(
    () => ObservePendingOperationsUseCase(
      repository: getIt<PendingOperationRepository>(),
    ),
  );
  getIt.registerLazySingleton<RetryPendingOperationUseCase>(
    () => RetryPendingOperationUseCase(
      repository: getIt<PendingOperationRepository>(),
    ),
  );
  getIt.registerLazySingleton<DiscardPendingOperationUseCase>(
    () => DiscardPendingOperationUseCase(
      repository: getIt<PendingOperationRepository>(),
    ),
  );
  getIt.registerLazySingleton<ObservePushDestinationUseCase>(
    () => ObservePushDestinationUseCase(
      repository: getIt<PushDestinationRepository>(),
    ),
  );
  getIt.registerLazySingleton<ConsumePushDestinationUseCase>(
    () => ConsumePushDestinationUseCase(
      repository: getIt<PushDestinationRepository>(),
    ),
  );
}

Future<void> _requestSync() async {
  getIt<SyncProcessor>().runDetached();
  try {
    await getIt<SyncScheduler>().requestSync();
  } on Exception catch (e) {
    // Ya quedó reactivada: un fallo al programar no debe parecer que el reintento falló.
    log('No se pudo programar el sync: $e', name: 'MainDependencies');
  }
}
