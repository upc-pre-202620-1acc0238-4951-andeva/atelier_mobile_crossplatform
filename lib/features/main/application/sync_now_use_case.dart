import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_repository.dart';

/// "Sincronizar ahora" de la pantalla Pendientes de sincronizar.
class SyncNowUseCase {
  final PendingOperationRepository repository;

  const SyncNowUseCase({required this.repository});

  Future<void> execute() => repository.syncNow();
}
