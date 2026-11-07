import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';

class ObserveCustomerUseCase {
  final ReceptionRepository repository;

  const ObserveCustomerUseCase({required this.repository});

  Stream<Customer?> execute(String id) => repository.observeCustomer(id);
}
