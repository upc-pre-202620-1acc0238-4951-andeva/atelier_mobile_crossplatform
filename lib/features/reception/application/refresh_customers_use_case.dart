import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Recarga la cartera de clientes del taller (`GET /customers`) y la guarda en Drift. Sin [force]
/// respeta la vigencia de 15 min. Sin red lanza `NetworkException` y la caché sigue visible.
class RefreshCustomersUseCase {
  final ReceptionRepository repository;

  const RefreshCustomersUseCase({required this.repository});

  Future<void> execute({bool force = false}) {
    return repository.refreshCustomers(force: force);
  }
}
