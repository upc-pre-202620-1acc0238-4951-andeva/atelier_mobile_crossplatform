import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';

class ObservePartUseCase {
  final InventoryRepository repository;

  const ObservePartUseCase({required this.repository});

  Stream<Part?> execute(String id) => repository.observePart(id);
}
