import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/infrastructure/remote/part_item_dto.dart';

class InventoryApi {
  final ApiClient client;

  const InventoryApi({required this.client});

  Future<List<PartItemDto>> getItems({String? search}) async {
    final query = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final List list = await client.get(
      '/api/v1/inventory/items',
      query: query.isEmpty ? null : query,
    );
    return list
        .map((e) => PartItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
