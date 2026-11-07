import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Afiliar al taller una cuenta de la app de clientes (US44 E1); sus vehículos quedan vinculados.
/// El documento es obligatorio. En línea.
class AffiliateCustomerUseCase {
  final ReceptionRepository repository;

  const AffiliateCustomerUseCase({required this.repository});

  Future<Customer> execute(String email, String taxId, {String? phone}) async {
    if (!ReceptionValidation.isEmail(email)) {
      throw const InvalidReceptionInputException('email');
    }
    if (!ReceptionValidation.isPersonTaxId(taxId)) {
      throw const InvalidReceptionInputException('taxId');
    }
    if (!ReceptionValidation.isOptionalPhone(phone)) {
      throw const InvalidReceptionInputException('phone');
    }
    return repository.affiliate(email, taxId, phone: phone);
  }
}
