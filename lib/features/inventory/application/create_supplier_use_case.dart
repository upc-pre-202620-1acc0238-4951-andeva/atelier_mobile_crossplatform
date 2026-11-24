import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';

/// Alta de un proveedor homologado con su RUC o documento (`inventory:suppliers:manage`).
class CreateSupplierUseCase {
  final InventoryRepository repository;

  const CreateSupplierUseCase({required this.repository});

  Future<Supplier> execute({
    required String businessName,
    required String taxId,
    String? contactName,
    String? phone,
    String? email,
    String? address,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(businessName)
        ? 'businessName'
        : !InventoryValidation.isTaxId(taxId)
        ? 'taxId'
        : !InventoryValidation.isOptionalEmail(email)
        ? 'email'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.createSupplier(
      businessName: businessName,
      taxId: taxId,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
    );
  }
}
