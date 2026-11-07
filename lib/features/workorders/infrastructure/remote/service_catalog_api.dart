import 'package:atelier_mobile_crossplatform/core/data/remote/api_client.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/infrastructure/remote/work_order_reference_dtos.dart';

/// Catálogo de servicios del taller (`operations:services:read`).
class ServiceCatalogApi {
  final ApiClient client;

  const ServiceCatalogApi({required this.client});

  Future<List<ServiceDto>> getServices() async {
    final List list = await client.get('/api/v1/services');
    return list
        .map((e) => ServiceDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
