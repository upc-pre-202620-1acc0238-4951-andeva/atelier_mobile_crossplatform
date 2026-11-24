import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_request_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/stock_allocation_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/supplier_dto.dart';
import 'package:decimal/decimal.dart';

class InventoryApi {
  static const _base = '/api/v1/inventory';

  final ApiClient client;

  const InventoryApi({required this.client});

  Future<List<PartItemDto>> getItems({
    String? search,
    String? category,
    int? page,
    int? size,
  }) async {
    final query = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      'category': ?category,
      if (page != null) 'page': '$page',
      if (size != null) 'size': '$size',
    };
    final List list = await client.get(
      '$_base/items',
      query: query.isEmpty ? null : query,
    );
    return list
        .map((e) => PartItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PartItemDto> createItem(CreatePartRequestDto body) async {
    return PartItemDto.fromJson(
      await client.post('$_base/items', body: body.toJson()),
    );
  }

  Future<PartDetailDto> getItem(String id) async {
    return PartDetailDto.fromJson(await client.get('$_base/items/$id'));
  }

  Future<PartItemDto> updateItem(String id, UpdatePartRequestDto body) async {
    return PartItemDto.fromJson(
      await client.put('$_base/items/$id', body: body.toJson()),
    );
  }

  /// [sku] ya normalizado: `^[A-Z0-9_-]{3,50}$` no necesita codificarse en la ruta.
  Future<PartItemDto> getBySku(String sku) async {
    return PartItemDto.fromJson(await client.get('$_base/items/by-sku/$sku'));
  }

  Future<List<BatchDto>> getBatches(String itemId) async {
    final List list = await client.get('$_base/items/$itemId/batches');
    return list
        .map((e) => BatchDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BatchDto> receiveBatch(ReceiveBatchRequestDto body) async {
    return BatchDto.fromJson(
      await client.post('$_base/batches/receive', body: body.toJson()),
    );
  }

  Future<StockAllocationDto> dispatchBatchFifo(
    DispatchBatchFifoRequestDto body,
  ) async {
    return StockAllocationDto.fromJson(
      await client.post('$_base/batches/dispatch', body: body.toJson()),
    );
  }

  Future<RestoreBatchResponseDto> restoreBatch(
    RestoreBatchRequestDto body,
  ) async {
    return RestoreBatchResponseDto.fromJson(
      await client.post('$_base/batches/restore', body: body.toJson()),
    );
  }

  Future<List<StockAlertDto>> getAlerts() async {
    final List list = await client.get('$_base/alerts');
    return list
        .map((e) => StockAlertDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Decimal?> getValuation() async {
    final Map<String, dynamic> json = await client.get(
      '$_base/items/valuation',
    );
    return decimalFromJson(json['valuation']);
  }

  Future<List<SupplierDto>> getSuppliers({
    String? search,
    String? status,
  }) async {
    final query = <String, String>{'search': ?search, 'status': ?status};
    final List list = await client.get(
      '$_base/suppliers',
      query: query.isEmpty ? null : query,
    );
    return list
        .map((e) => SupplierDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SupplierDto> createSupplier(RegisterSupplierRequestDto body) async {
    return SupplierDto.fromJson(
      await client.post('$_base/suppliers', body: body.toJson()),
    );
  }

  Future<SupplierDto> updateSupplier(
    String id,
    UpdateSupplierRequestDto body,
  ) async {
    return SupplierDto.fromJson(
      await client.put('$_base/suppliers/$id', body: body.toJson()),
    );
  }

  Future<List<PurchaseOrderDto>> getPurchaseOrders({String? status}) async {
    final List list = await client.get(
      '$_base/purchase-orders',
      query: status == null ? null : {'status': status},
    );
    return list
        .map((e) => PurchaseOrderDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PurchaseOrderDto> getPurchaseOrder(String id) async {
    return PurchaseOrderDto.fromJson(
      await client.get('$_base/purchase-orders/$id'),
    );
  }

  Future<PurchaseOrderDto> createPurchaseOrder(
    CreatePurchaseOrderRequestDto body,
  ) async {
    return PurchaseOrderDto.fromJson(
      await client.post('$_base/purchase-orders', body: body.toJson()),
    );
  }

  Future<PurchaseOrderDto> addPurchaseOrderItem(
    String id,
    CreatePurchaseOrderItemRequestDto body,
  ) async {
    return PurchaseOrderDto.fromJson(
      await client.post(
        '$_base/purchase-orders/$id/items',
        body: body.toJson(),
      ),
    );
  }

  Future<PurchaseOrderDto> issuePurchaseOrder(String id) async {
    return PurchaseOrderDto.fromJson(
      await client.put('$_base/purchase-orders/$id/issue'),
    );
  }

  Future<PurchaseOrderDto> cancelPurchaseOrder(
    String id,
    CancelPurchaseOrderRequestDto body,
  ) async {
    return PurchaseOrderDto.fromJson(
      await client.put(
        '$_base/purchase-orders/$id/cancel',
        body: body.toJson(),
      ),
    );
  }

  Future<PurchaseOrderDto> receivePurchaseOrder(
    String id,
    ReceivePurchaseOrderRequestDto body,
  ) async {
    return PurchaseOrderDto.fromJson(
      await client.put(
        '$_base/purchase-orders/$id/receive',
        body: body.toJson(),
      ),
    );
  }
}
