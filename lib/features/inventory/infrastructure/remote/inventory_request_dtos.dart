import 'package:decimal/decimal.dart';

/// `CreatePartResource` de docs/api/inventory.md.
class CreatePartRequestDto {
  final String name;
  final String sku;
  final String category;
  final Decimal basePrice;
  final Decimal minimumStock;
  final String? unitOfMeasure;

  const CreatePartRequestDto({
    required this.name,
    required this.sku,
    required this.category,
    required this.basePrice,
    required this.minimumStock,
    this.unitOfMeasure,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'category': category,
    'basePrice': basePrice.toDouble(),
    'minimumStock': minimumStock.toDouble(),
    'unitOfMeasure': ?unitOfMeasure,
  };
}

/// `UpdatePartResource` de docs/api/inventory.md.
class UpdatePartRequestDto {
  final String name;
  final String category;
  final Decimal basePrice;
  final Decimal minimumStock;
  final String? status;
  final String? unitOfMeasure;

  const UpdatePartRequestDto({
    required this.name,
    required this.category,
    required this.basePrice,
    required this.minimumStock,
    this.status,
    this.unitOfMeasure,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'basePrice': basePrice.toDouble(),
    'minimumStock': minimumStock.toDouble(),
    'status': ?status,
    'unitOfMeasure': ?unitOfMeasure,
  };
}

/// `RegisterSupplierResource` de docs/api/inventory.md.
class RegisterSupplierRequestDto {
  final String businessName;
  final String taxId;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;

  const RegisterSupplierRequestDto({
    required this.businessName,
    required this.taxId,
    this.contactName,
    this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'businessName': businessName,
    'taxId': taxId,
    'contactName': ?contactName,
    'phone': ?phone,
    'email': ?email,
    'address': ?address,
  };
}

/// `UpdateSupplierResource` de docs/api/inventory.md.
class UpdateSupplierRequestDto {
  final String? businessName;
  final String? contactName;
  final String? phone;
  final String? email;
  final String? address;
  final bool? active;

  const UpdateSupplierRequestDto({
    this.businessName,
    this.contactName,
    this.phone,
    this.email,
    this.address,
    this.active,
  });

  Map<String, dynamic> toJson() => {
    'businessName': ?businessName,
    'contactName': ?contactName,
    'phone': ?phone,
    'email': ?email,
    'address': ?address,
    'active': ?active,
  };
}

/// `CreatePurchaseOrderItemResource` de docs/api/inventory.md.
class CreatePurchaseOrderItemRequestDto {
  final String itemId;
  final Decimal quantity;
  final Decimal unitCost;

  const CreatePurchaseOrderItemRequestDto({
    required this.itemId,
    required this.quantity,
    required this.unitCost,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity.toDouble(),
    'unitCost': unitCost.toDouble(),
  };
}

/// `CreatePurchaseOrderResource` de docs/api/inventory.md.
class CreatePurchaseOrderRequestDto {
  final String branchId;
  final String supplierId;
  final List<CreatePurchaseOrderItemRequestDto> items;
  final String? orderNumber;
  final String? expectedDeliveryDate;
  final String? notes;

  const CreatePurchaseOrderRequestDto({
    required this.branchId,
    required this.supplierId,
    required this.items,
    this.orderNumber,
    this.expectedDeliveryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'branchId': branchId,
    'supplierId': supplierId,
    'items': items.map((item) => item.toJson()).toList(),
    'orderNumber': ?orderNumber,
    'expectedDeliveryDate': ?expectedDeliveryDate,
    'notes': ?notes,
  };
}

/// `CancelPurchaseOrderResource` de docs/api/inventory.md.
class CancelPurchaseOrderRequestDto {
  final String? reason;

  const CancelPurchaseOrderRequestDto({this.reason});

  Map<String, dynamic> toJson() => {'reason': ?reason};
}

/// `ReceiveBatchResource` de docs/api/inventory.md.
class ReceiveBatchRequestDto {
  final String itemId;
  final String batchNumber;
  final Decimal quantity;
  final Decimal unitCost;
  final DateTime? arrivalDate;
  final String? supplierId;

  const ReceiveBatchRequestDto({
    required this.itemId,
    required this.batchNumber,
    required this.quantity,
    required this.unitCost,
    this.arrivalDate,
    this.supplierId,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'batchNumber': batchNumber,
    'quantity': quantity.toDouble(),
    'unitCost': unitCost.toDouble(),
    if (arrivalDate != null)
      'arrivalDate': arrivalDate!.toUtc().toIso8601String(),
    'supplierId': ?supplierId,
  };
}

/// `DispatchBatchFifoResource` de docs/api/inventory.md.
class DispatchBatchFifoRequestDto {
  final String itemId;
  final Decimal quantity;
  final String? taskId;
  final String? workOrderId;

  const DispatchBatchFifoRequestDto({
    required this.itemId,
    required this.quantity,
    this.taskId,
    this.workOrderId,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity.toDouble(),
    'taskId': ?taskId,
    'workOrderId': ?workOrderId,
  };
}

/// `RestoreBatchResource` de docs/api/inventory.md.
class RestoreBatchRequestDto {
  final String itemId;
  final Decimal quantity;
  final String? batchId;
  final String? reason;
  final String? workOrderId;

  const RestoreBatchRequestDto({
    required this.itemId,
    required this.quantity,
    this.batchId,
    this.reason,
    this.workOrderId,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'quantity': quantity.toDouble(),
    'batchId': ?batchId,
    'reason': ?reason,
    'workOrderId': ?workOrderId,
  };
}
