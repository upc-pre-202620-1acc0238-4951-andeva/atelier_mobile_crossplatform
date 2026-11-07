import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Catálogo del taller: da nombre a tareas y propuestas (H11). Sin permiso, lista vacía. En línea.
class GetServiceCatalogUseCase {
  final WorkOrderRepository repository;

  const GetServiceCatalogUseCase({required this.repository});

  Future<List<ServiceOption>> execute() {
    return repository.getServiceCatalog();
  }
}
