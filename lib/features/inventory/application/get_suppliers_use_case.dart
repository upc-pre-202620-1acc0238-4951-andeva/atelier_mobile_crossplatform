import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';

/// Listado y búsqueda de proveedores homologados (`inventory:suppliers:manage`). En línea.
class GetSuppliersUseCase {
  final InventoryRepository repository;

  const GetSuppliersUseCase({required this.repository});

  Future<List<Supplier>> execute({String? search, String? status}) {
    return repository.getSuppliers(search: search, status: status);
  }
}
