import 'package:atelier_mobile_crossplatform/features/auth/domain/auth_repository.dart';

/// Conteo neutro de operaciones pendientes guardadas en el dispositivo para advertir en el login cuando
/// una sesión expiró o se cerró con trabajo local sin sincronizar (US04, docs/06-offline-sync.md).
class GetDevicePendingOperationCountUseCase {
  final AuthRepository repository;

  const GetDevicePendingOperationCountUseCase({required this.repository});

  Future<int> execute() => repository.devicePendingOperationCount();
}
