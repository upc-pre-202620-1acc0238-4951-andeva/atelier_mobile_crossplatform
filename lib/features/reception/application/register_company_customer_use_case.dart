import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Alta de empresa con RUC en primer ingreso (US11 E2). En línea.
class RegisterCompanyCustomerUseCase {
  final ReceptionRepository repository;

  const RegisterCompanyCustomerUseCase({required this.repository});

  Future<Customer> execute(NewCompanyCustomer customer) async {
    final String? invalid;
    if (!ReceptionValidation.isCompanyName(customer.companyName)) {
      invalid = 'companyName';
    } else if (!ReceptionValidation.isCompanyTaxId(customer.taxId)) {
      invalid = 'taxId';
    } else if (!ReceptionValidation.isOptionalEmail(customer.email)) {
      invalid = 'email';
    } else if (!ReceptionValidation.isOptionalPhone(customer.phone)) {
      invalid = 'phone';
    } else {
      invalid = null;
    }
    if (invalid != null) throw InvalidReceptionInputException(invalid);
    return repository.registerCompany(customer);
  }
}
