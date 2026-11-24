/// Proveedor homologado (`SupplierResource` de docs/api/inventory.md).
class Supplier {
  final String id;
  final String businessName;
  final String taxId;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final bool active;

  const Supplier({
    required this.id,
    required this.businessName,
    required this.taxId,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    required this.active,
  });
}
