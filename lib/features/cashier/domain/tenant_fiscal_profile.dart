/// Perfil fiscal del taller (`TenantResource` de `GET / PUT /api/v1/tenants/current`, US42).
class TenantFiscalProfile {
  final String id;
  final String name;
  final String legalName;
  final String taxId;
  final String? status;

  const TenantFiscalProfile({
    required this.id,
    required this.name,
    this.legalName = '',
    this.taxId = '',
    this.status,
  });
}
