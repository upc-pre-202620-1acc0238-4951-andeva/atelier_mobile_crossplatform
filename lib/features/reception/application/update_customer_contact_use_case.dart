import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Actualizar teléfono y correo de un cliente (`PUT /customers/{id}/contact`,
/// `crm:customers:update`). En línea.
class UpdateCustomerContactUseCase {
  final ReceptionRepository repository;

  const UpdateCustomerContactUseCase({required this.repository});

  Future<Customer> execute(String customerId, {String? email, String? phone}) {
    if (customerId.trim().isEmpty) {
      throw const InvalidReceptionInputException('customerId');
    }
    if (!ReceptionValidation.isOptionalEmail(email)) {
      throw const InvalidReceptionInputException('email');
    }
    if (!ReceptionValidation.isOptionalPhone(phone)) {
      throw const InvalidReceptionInputException('phone');
    }
    return repository.updateCustomerContact(
      customerId,
      email: email,
      phone: phone,
    );
  }
}
