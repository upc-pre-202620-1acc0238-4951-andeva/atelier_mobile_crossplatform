import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Buscar al cliente por documento o nombre (US11 E1). Sin red busca en los clientes ya vistos.
class SearchCustomersUseCase {
  final ReceptionRepository repository;

  const SearchCustomersUseCase({required this.repository});

  Future<List<Customer>> execute(String query) {
    return repository.searchCustomers(query);
  }
}
