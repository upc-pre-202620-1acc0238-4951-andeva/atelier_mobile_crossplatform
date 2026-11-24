import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Trae a Drift los vehículos y clientes que órdenes o citas referencian y aún no están en caché (o
/// vencieron). Nunca falla: sin red o sin permiso se sigue con la caché.
class EnrichReceptionReferencesUseCase {
  final ReceptionRepository repository;

  const EnrichReceptionReferencesUseCase({required this.repository});

  Future<void> execute(
    Iterable<String> vehicleIds,
    Iterable<String> customerIds,
  ) {
    return repository.enrichReferences(vehicleIds, customerIds);
  }
}
