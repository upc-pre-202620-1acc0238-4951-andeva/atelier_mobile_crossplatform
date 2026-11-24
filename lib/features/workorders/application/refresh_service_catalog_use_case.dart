import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Recarga el catálogo de servicios desde el servidor sin usar la copia en memoria. Sin permiso, lista
/// vacía. En línea.
class RefreshServiceCatalogUseCase {
  final WorkOrderRepository repository;

  const RefreshServiceCatalogUseCase({required this.repository});

  Future<List<ServiceOption>> execute() => repository.refreshServiceCatalog();
}
