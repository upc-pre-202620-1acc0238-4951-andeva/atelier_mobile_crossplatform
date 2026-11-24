import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_errors.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_validation.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/supplier.dart';

/// Actualiza un proveedor (`inventory:suppliers:manage`). Lo que va en `null` no se envía.
class UpdateSupplierUseCase {
  final InventoryRepository repository;

  const UpdateSupplierUseCase({required this.repository});

  Future<Supplier> execute(
    String id, {
    String? businessName,
    String? contactName,
    String? phone,
    String? email,
    String? address,
    bool? active,
  }) async {
    final invalid = !InventoryValidation.isNonEmptyText(id)
        ? 'id'
        : businessName != null &&
              !InventoryValidation.isNonEmptyText(businessName)
        ? 'businessName'
        : !InventoryValidation.isOptionalEmail(email)
        ? 'email'
        : null;
    if (invalid != null) throw InvalidInventoryInputException(invalid);
    return repository.updateSupplier(
      id,
      businessName: businessName,
      contactName: contactName,
      phone: phone,
      email: email,
      address: address,
      active: active,
    );
  }
}
