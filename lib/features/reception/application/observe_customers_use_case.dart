import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

/// Observa la cartera de clientes del taller guardada en Drift, ordenada por nombre.
class ObserveCustomersUseCase {
  final ReceptionRepository repository;

  const ObserveCustomersUseCase({required this.repository});

  Stream<List<Customer>> execute() => repository.observeCustomers();
}
