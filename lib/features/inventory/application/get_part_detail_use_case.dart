import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

/// Ficha con sus lotes en orden FIFO (US32). Destino del push `LOW_STOCK`.
class GetPartDetailUseCase {
  final InventoryRepository repository;

  const GetPartDetailUseCase({required this.repository});

  Future<PartDetail> execute(String id) => repository.getPartDetail(id);
}
