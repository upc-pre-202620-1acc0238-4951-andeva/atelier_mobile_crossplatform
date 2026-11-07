import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Qué sigue tras buscar el correo (US44): ya es cliente, afiliar su cuenta o registrarlo en persona.
enum AffiliationStep {
  alreadyCustomer('ALREADY_CUSTOMER'),
  affiliate('AFFILIATE'),
  registerWalkIn('REGISTER_WALK_IN');

  final String value;
  const AffiliationStep(this.value);

  static AffiliationStep? fromString(String? raw) {
    for (final step in values) {
      if (step.value == raw) return step;
    }
    return null;
  }
}

/// Cuenta de la app de clientes con ese correo.
class PlatformAccount {
  final String userId;
  final String email;
  final String? fullName;
  final String? status;

  const PlatformAccount({
    required this.userId,
    required this.email,
    this.fullName,
    this.status,
  });
}

/// Respuesta de `GET /customers/affiliation-lookup`: [vehicles] son los que la cuenta ya registró.
class AffiliationLookup {
  final Customer? workshopCustomer;
  final PlatformAccount? platformAccount;
  final List<Vehicle> vehicles;
  final AffiliationStep? nextStep;

  const AffiliationLookup({
    this.workshopCustomer,
    this.platformAccount,
    this.vehicles = const [],
    this.nextStep,
  });
}
