import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_repository.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/tenant_fiscal_profile.dart';

/// Obtiene la información fiscal del taller (`GET /api/v1/tenants/current`, US42).
class GetTenantFiscalProfileUseCase {
  final CashierRepository repository;

  const GetTenantFiscalProfileUseCase({required this.repository});

  Future<TenantFiscalProfile> execute() => repository.getTenantFiscalProfile();
}
