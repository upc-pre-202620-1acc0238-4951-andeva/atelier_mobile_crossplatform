import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/core/data/remote/json_decimal.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/inventory_dtos.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';
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

  Future<PartDetailDto> getItem(String id) async {
    return PartDetailDto.fromJson(await client.get('$_base/items/$id'));
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

  Future<List<StockAlertDto>> getAlerts() async {
    final List list = await client.get('$_base/alerts');
    return list
        .map((e) => StockAlertDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Decimal?> getValuation() async {
    final Map<String, dynamic> json = await client.get('$_base/items/valuation');
    return decimalFromJson(json['valuation']);
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

  Future<PurchaseOrderDto> receivePurchaseOrder(
    String id,
    ReceivePurchaseOrderRequestDto body,
  ) async {
    return PurchaseOrderDto.fromJson(
      await client.put('$_base/purchase-orders/$id/receive', body: body.toJson()),
    );
  }
}
