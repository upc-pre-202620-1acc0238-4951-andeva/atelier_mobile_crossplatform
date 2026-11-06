import 'package:atelier_mobile_crossplatform/features/tasks/domain/part_option.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_repository.dart';

/// Buscar en el catálogo el repuesto a imputar, con saldo y precio base (US23 E1, US31). En línea.
class SearchPartsUseCase {
  final TaskRepository repository;

  const SearchPartsUseCase({required this.repository});

  Future<List<PartOption>> execute(String query) =>
      repository.searchParts(query.trim());
}
