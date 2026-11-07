import 'package:atelier_mobile_crossplatform/features/reception/domain/affiliation_lookup.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';

/// Buscar el correo del conductor (US44): `nextStep` dice si ya es cliente, si se afilia su cuenta
/// o si se registra en persona. En línea.
class LookupAffiliationUseCase {
  final ReceptionRepository repository;

  const LookupAffiliationUseCase({required this.repository});

  Future<AffiliationLookup> execute(String email) async {
    if (!ReceptionValidation.isEmail(email)) {
      throw const InvalidReceptionInputException('email');
    }
    return repository.lookupAffiliation(email);
  }
}
