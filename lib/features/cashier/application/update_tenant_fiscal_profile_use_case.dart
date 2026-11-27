import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';

/// Actualiza la información fiscal del taller (`PUT /api/v1/tenants/current`, US42). Nombre comercial de 1 a
/// 100 caracteres y razón social de 1 a 150; si no, `InvalidCashierInputException('tenantName' | 'tenantLegalName')`.
class UpdateTenantFiscalProfileUseCase {
  final CashierRepository repository;

  const UpdateTenantFiscalProfileUseCase({required this.repository});

  Future<TenantFiscalProfile> execute(String name, String legalName) {
    return repository.updateTenantFiscalProfile(name, legalName);
  }
}
