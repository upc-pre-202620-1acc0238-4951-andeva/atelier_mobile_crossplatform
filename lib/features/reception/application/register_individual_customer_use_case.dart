import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Alta de persona natural en primer ingreso o walk-in (US11 E2, US44 E2). En línea.
class RegisterIndividualCustomerUseCase {
  final ReceptionRepository repository;

  const RegisterIndividualCustomerUseCase({required this.repository});

  Future<Customer> execute(NewIndividualCustomer customer) async {
    final String? invalid;
    if (!ReceptionValidation.isName(customer.firstName)) {
      invalid = 'firstName';
    } else if (!ReceptionValidation.isName(customer.lastName)) {
      invalid = 'lastName';
    } else if (!ReceptionValidation.isPersonTaxId(customer.taxId)) {
      invalid = 'taxId';
    } else if (!ReceptionValidation.isOptionalEmail(customer.email)) {
      invalid = 'email';
    } else if (!ReceptionValidation.isOptionalPhone(customer.phone)) {
      invalid = 'phone';
    } else {
      invalid = null;
    }
    if (invalid != null) throw InvalidReceptionInputException(invalid);
    return repository.registerIndividual(customer);
  }
}
